import 'package:hive_flutter/hive_flutter.dart';
import '../models/customer.dart';
import '../models/garment_type.dart';
import '../models/order.dart';

class DatabaseService {
  static late Box<Customer> _customerBox;
  static late Box<GarmentType> _garmentTypeBox;
  static late Box<Order> _orderBox;

  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(CustomerAdapter());
    Hive.registerAdapter(GarmentTypeAdapter());
    Hive.registerAdapter(OrderAdapter());
    Hive.registerAdapter(OrderStatusAdapter());

    // Open boxes
    _customerBox = await Hive.openBox<Customer>('customers');
    _garmentTypeBox = await Hive.openBox<GarmentType>('garment_types');
    _orderBox = await Hive.openBox<Order>('orders');

    // Add default garment types if box is empty
    if (_garmentTypeBox.isEmpty) {
      await _addDefaultGarmentTypes();
    }
  }

  static Future<void> _addDefaultGarmentTypes() async {
    final defaultGarmentTypes = [
      GarmentType(
        id: 'shirt',
        name: 'Shirt',
        measurements: [
          'Chest',
          'Shoulder',
          'Sleeve Length',
          'Collar',
          'Length',
        ],
        basePrice: 500.0,
        createdAt: DateTime.now(),
      ),
      GarmentType(
        id: 'pant',
        name: 'Pant',
        measurements: ['Waist', 'Hip', 'Inseam', 'Outseam', 'Thigh'],
        basePrice: 400.0,
        createdAt: DateTime.now(),
      ),
      GarmentType(
        id: 'suit',
        name: 'Suit',
        measurements: [
          'Chest',
          'Shoulder',
          'Sleeve Length',
          'Waist',
          'Hip',
          'Jacket Length',
          'Pant Length',
        ],
        basePrice: 1500.0,
        createdAt: DateTime.now(),
      ),
    ];

    for (final garmentType in defaultGarmentTypes) {
      await _garmentTypeBox.put(garmentType.id, garmentType);
    }
  }

  // Customer operations
  static Future<void> addCustomer(Customer customer) async {
    await _customerBox.put(customer.id, customer);
  }

  static Customer? getCustomer(String id) {
    return _customerBox.get(id);
  }

  static List<Customer> getAllCustomers() {
    return _customerBox.values.toList();
  }

  static List<Customer> searchCustomers(String query) {
    final customers = _customerBox.values.toList();
    return customers.where((customer) {
      return customer.name.toLowerCase().contains(query.toLowerCase()) ||
          customer.phoneNumber.contains(query);
    }).toList();
  }

  static Future<void> updateCustomer(Customer customer) async {
    customer.updatedAt = DateTime.now();
    await _customerBox.put(customer.id, customer);
  }

  static Future<void> deleteCustomer(String id) async {
    await _customerBox.delete(id);
  }

  // Garment type operations
  static Future<void> addGarmentType(GarmentType garmentType) async {
    await _garmentTypeBox.put(garmentType.id, garmentType);
  }

  static GarmentType? getGarmentType(String id) {
    return _garmentTypeBox.get(id);
  }

  static List<GarmentType> getAllGarmentTypes() {
    return _garmentTypeBox.values.toList();
  }

  static Future<void> updateGarmentType(GarmentType garmentType) async {
    await _garmentTypeBox.put(garmentType.id, garmentType);
  }

  static Future<void> deleteGarmentType(String id) async {
    await _garmentTypeBox.delete(id);
  }

  // Order operations
  static Future<void> addOrder(Order order) async {
    await _orderBox.put(order.id, order);
  }

  static Order? getOrder(String id) {
    return _orderBox.get(id);
  }

  static List<Order> getAllOrders() {
    return _orderBox.values.toList();
  }

  static List<Order> searchOrdersByInvoice(String invoiceNumber) {
    final orders = _orderBox.values.toList();
    return orders.where((order) {
      return order.invoiceNumber.toLowerCase().contains(
        invoiceNumber.toLowerCase(),
      );
    }).toList();
  }

  static List<Order> searchOrders(String query) {
    if (query.isEmpty) return getAllOrders();

    final orders = _orderBox.values.toList();
    final customers = _customerBox.values.toList();

    return orders.where((order) {
      // Search by invoice number
      final matchesInvoice = order.invoiceNumber.toLowerCase().contains(
        query.toLowerCase(),
      );

      // Search by customer name and phone number
      final customer = customers.cast<Customer?>().firstWhere(
        (c) => c?.id == order.customerId,
        orElse: () => null,
      );

      if (customer == null) return matchesInvoice;

      final matchesCustomerName = customer.name.toLowerCase().contains(
        query.toLowerCase(),
      );

      final matchesCustomerPhone = customer.phoneNumber.contains(query);

      return matchesInvoice || matchesCustomerName || matchesCustomerPhone;
    }).toList();
  }

  static List<Order> getOrdersByCustomerId(String customerId) {
    final orders = _orderBox.values.toList();
    return orders.where((order) => order.customerId == customerId).toList();
  }

  static Future<void> updateOrder(Order order) async {
    order.updatedAt = DateTime.now();
    await _orderBox.put(order.id, order);
  }

  static Future<void> deleteOrder(String id) async {
    await _orderBox.delete(id);
  }

  static String generateInvoiceNumber() {
    final now = DateTime.now();
    final year = now.year.toString().substring(2);
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    final orderCount = _orderBox.length + 1;

    return 'INV$year$month$day${orderCount.toString().padLeft(4, '0')}';
  }

  static Future<void> close() async {
    await _customerBox.close();
    await _garmentTypeBox.close();
    await _orderBox.close();
  }
}
