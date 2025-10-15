import 'package:flutter/foundation.dart';
import '../models/customer.dart';
import '../models/garment_type.dart';
import '../models/order.dart';
import '../services/database_service.dart';

class TailorShopProvider with ChangeNotifier {
  List<Customer> _customers = [];
  List<GarmentType> _garmentTypes = [];
  List<Order> _orders = [];

  List<Customer> get customers => _customers;
  List<GarmentType> get garmentTypes => _garmentTypes;
  List<Order> get orders => _orders;

  Future<void> loadData() async {
    _customers = DatabaseService.getAllCustomers();
    _garmentTypes = DatabaseService.getAllGarmentTypes();
    _orders = DatabaseService.getAllOrders();
    notifyListeners();
  }

  // Customer operations
  Future<void> addCustomer(Customer customer) async {
    await DatabaseService.addCustomer(customer);
    _customers = DatabaseService.getAllCustomers();
    notifyListeners();
  }

  Future<void> updateCustomer(Customer customer) async {
    await DatabaseService.updateCustomer(customer);
    _customers = DatabaseService.getAllCustomers();
    notifyListeners();
  }

  Future<void> deleteCustomer(String customerId) async {
    await DatabaseService.deleteCustomer(customerId);
    _customers = DatabaseService.getAllCustomers();
    notifyListeners();
  }

  List<Customer> searchCustomers(String query) {
    if (query.isEmpty) return _customers;
    return DatabaseService.searchCustomers(query);
  }

  Customer? getCustomerById(String id) {
    return DatabaseService.getCustomer(id);
  }

  // Garment type operations
  Future<void> addGarmentType(GarmentType garmentType) async {
    await DatabaseService.addGarmentType(garmentType);
    _garmentTypes = DatabaseService.getAllGarmentTypes();
    notifyListeners();
  }

  Future<void> updateGarmentType(GarmentType garmentType) async {
    await DatabaseService.updateGarmentType(garmentType);
    _garmentTypes = DatabaseService.getAllGarmentTypes();
    notifyListeners();
  }

  Future<void> deleteGarmentType(String garmentTypeId) async {
    await DatabaseService.deleteGarmentType(garmentTypeId);
    _garmentTypes = DatabaseService.getAllGarmentTypes();
    notifyListeners();
  }

  GarmentType? getGarmentTypeById(String id) {
    return DatabaseService.getGarmentType(id);
  }

  // Order operations
  Future<void> addOrder(Order order) async {
    await DatabaseService.addOrder(order);
    _orders = DatabaseService.getAllOrders();
    notifyListeners();
  }

  Future<void> updateOrder(Order order) async {
    await DatabaseService.updateOrder(order);
    _orders = DatabaseService.getAllOrders();
    notifyListeners();
  }

  Future<void> deleteOrder(String orderId) async {
    await DatabaseService.deleteOrder(orderId);
    _orders = DatabaseService.getAllOrders();
    notifyListeners();
  }

  List<Order> searchOrdersByInvoice(String invoiceNumber) {
    if (invoiceNumber.isEmpty) return _orders;
    return DatabaseService.searchOrdersByInvoice(invoiceNumber);
  }

  List<Order> searchOrders(String query) {
    if (query.isEmpty) return _orders;
    return DatabaseService.searchOrders(query);
  }

  List<Order> getOrdersByCustomerId(String customerId) {
    return DatabaseService.getOrdersByCustomerId(customerId);
  }

  Order? getOrderById(String id) {
    return DatabaseService.getOrder(id);
  }

  String generateInvoiceNumber() {
    return DatabaseService.generateInvoiceNumber();
  }

  // Dashboard statistics
  int get totalCustomers => _customers.length;
  int get totalOrders => _orders.length;
  int get pendingOrders =>
      _orders.where((order) => order.status == OrderStatus.pending).length;
  int get completedOrders =>
      _orders.where((order) => order.status == OrderStatus.completed).length;

  double get totalRevenue {
    return _orders
        .where(
          (order) =>
              order.status == OrderStatus.completed ||
              order.status == OrderStatus.delivered,
        )
        .fold(0.0, (sum, order) => sum + order.totalPrice);
  }

  List<Order> get recentOrders {
    final sortedOrders = List<Order>.from(_orders);
    sortedOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sortedOrders.take(10).toList();
  }

  List<Order> get upcomingDeliveries {
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    final nextFourDays = today.add(const Duration(days: 4));

    // Get orders that need attention for delivery
    final deliveriesToShow =
        _orders.where((order) {
          // Include orders that are not yet delivered or cancelled
          final isRelevantStatus =
              order.status != OrderStatus.delivered &&
              order.status != OrderStatus.cancelled;

          // Include orders due today, overdue, or due in the next 4 days
          final isRelevantDate =
              order.deliveryDate.isBefore(nextFourDays) ||
              order.deliveryDate.isAtSameMomentAs(nextFourDays);

          return isRelevantStatus && isRelevantDate;
        }).toList();

    // Sort by delivery date (overdue first, then upcoming)
    deliveriesToShow.sort((a, b) {
      // Overdue orders first
      final aOverdue = a.deliveryDate.isBefore(startOfToday);
      final bOverdue = b.deliveryDate.isBefore(startOfToday);

      if (aOverdue && !bOverdue) return -1;
      if (!aOverdue && bOverdue) return 1;

      // Then sort by delivery date
      return a.deliveryDate.compareTo(b.deliveryDate);
    });

    return deliveriesToShow.take(15).toList(); // Show up to 15 deliveries
  }
}
