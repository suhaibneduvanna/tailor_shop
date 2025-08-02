import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tailor_shop_provider.dart';
import '../models/order.dart';
import '../models/customer.dart';
import '../models/garment_type.dart';
import '../services/printing_service.dart';
import 'add_edit_order_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Order> _filteredOrders = [];
  OrderStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterOrders);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterOrders() {
    final provider = Provider.of<TailorShopProvider>(context, listen: false);
    setState(() {
      _filteredOrders = provider.searchOrdersByInvoice(_searchController.text);
      if (_selectedStatus != null) {
        _filteredOrders =
            _filteredOrders
                .where((order) => order.status == _selectedStatus)
                .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.assignment_rounded, size: 24),
            SizedBox(width: 8),
            Text('Orders'),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              onPressed: () => _showAddOrderDialog(context),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.add_shopping_cart_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              tooltip: 'Add Order',
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Search orders...',
                      hintText: 'Enter invoice number',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                DropdownButton<OrderStatus?>(
                  value: _selectedStatus,
                  hint: const Text('Filter by Status'),
                  items: [
                    const DropdownMenuItem<OrderStatus?>(
                      value: null,
                      child: Text('All Statuses'),
                    ),
                    ...OrderStatus.values.map(
                      (status) => DropdownMenuItem(
                        value: status,
                        child: Text(status.name),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value;
                    });
                    _filterOrders();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<TailorShopProvider>(
              builder: (context, provider, child) {
                final orders =
                    _searchController.text.isEmpty && _selectedStatus == null
                        ? provider.orders
                        : _filteredOrders;

                if (orders.isEmpty) {
                  return const Center(child: Text('No orders found'));
                }

                return ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    final customer = provider.getCustomerById(order.customerId);
                    final garmentType = provider.getGarmentTypeById(
                      order.garmentTypeId,
                    );

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          backgroundColor: _getStatusColor(order.status),
                          child: Text(
                            order.invoiceNumber.substring(
                              order.invoiceNumber.length - 2,
                            ),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        title: Text(
                          order.invoiceNumber,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Customer: ${customer?.name ?? 'Unknown'}'),
                            Text('Garment: ${garmentType?.name ?? 'Unknown'}'),
                            Text(
                              'Amount: ₹${order.totalPrice.toStringAsFixed(2)}',
                            ),
                          ],
                        ),
                        trailing: Chip(
                          label: Text(order.status.name),
                          backgroundColor: _getStatusColor(order.status),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Order Date: ${_formatDate(order.orderDate)}',
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        'Delivery Date: ${_formatDate(order.deliveryDate)}',
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text('Quantity: ${order.quantity}'),
                                const SizedBox(height: 8),
                                // Payment Details
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Total Amount:',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            '₹${order.totalPrice.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (order.advancePayment != null &&
                                          order.advancePayment! > 0) ...[
                                        const SizedBox(height: 6),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              'Advance Payment:',
                                              style: TextStyle(fontSize: 14),
                                            ),
                                            Text(
                                              '₹${order.advancePayment!.toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.blue,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              'Balance Amount:',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Text(
                                              '₹${(order.totalPrice - order.advancePayment!).toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.orange,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                if (order.notes != null &&
                                    order.notes!.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text('Notes: ${order.notes}'),
                                ],
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    // Print Invoice Button
                                    ElevatedButton.icon(
                                      onPressed:
                                          () => _printInvoice(
                                            order,
                                            customer,
                                            garmentType,
                                          ),
                                      icon: const Icon(Icons.print, size: 18),
                                      label: const Text('Print Invoice'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                        foregroundColor:
                                            Theme.of(
                                              context,
                                            ).colorScheme.onPrimary,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // Print Measurements Button
                                    ElevatedButton.icon(
                                      onPressed:
                                          () => _printMeasurementSlip(
                                            order,
                                            customer,
                                            garmentType,
                                          ),
                                      icon: const Icon(
                                        Icons.straighten,
                                        size: 18,
                                      ),
                                      label: const Text('Print Measurements'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                        foregroundColor:
                                            Theme.of(
                                              context,
                                            ).colorScheme.onPrimary,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    PopupMenuButton(
                                      itemBuilder:
                                          (context) => [
                                            const PopupMenuItem(
                                              value: 'edit',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.edit),
                                                  SizedBox(width: 8),
                                                  Text('Edit'),
                                                ],
                                              ),
                                            ),
                                            const PopupMenuItem(
                                              value: 'status',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.update),
                                                  SizedBox(width: 8),
                                                  Text('Update Status'),
                                                ],
                                              ),
                                            ),
                                            const PopupMenuItem(
                                              value: 'delete',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.delete),
                                                  SizedBox(width: 8),
                                                  Text('Delete'),
                                                ],
                                              ),
                                            ),
                                          ],
                                      onSelected: (value) {
                                        switch (value) {
                                          case 'edit':
                                            _showEditOrderDialog(
                                              context,
                                              order,
                                            );
                                            break;
                                          case 'status':
                                            _showUpdateStatusDialog(
                                              context,
                                              order,
                                            );
                                            break;
                                          case 'delete':
                                            _showDeleteConfirmation(
                                              context,
                                              order,
                                            );
                                            break;
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddOrderDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddEditOrderScreen()),
    );
  }

  void _showEditOrderDialog(BuildContext context, Order order) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddEditOrderScreen(order: order)),
    );
  }

  void _printInvoice(
    Order order,
    Customer? customer,
    GarmentType? garmentType,
  ) async {
    if (customer == null || garmentType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Customer or garment type not found')),
      );
      return;
    }

    try {
      await PrintingService.printInvoice(order, customer, garmentType);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error printing invoice: ${e.toString()}')),
        );
      }
    }
  }

  void _printMeasurementSlip(
    Order order,
    Customer? customer,
    GarmentType? garmentType,
  ) async {
    if (customer == null || garmentType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Customer or garment type not found')),
      );
      return;
    }

    try {
      await PrintingService.printMeasurementSlip(order, customer, garmentType);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error printing measurement slip: ${e.toString()}'),
          ),
        );
      }
    }
  }

  void _showUpdateStatusDialog(BuildContext context, Order order) {
    OrderStatus? newStatus = order.status;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Update Order Status'),
            content: StatefulBuilder(
              builder:
                  (context, setState) => DropdownButtonFormField<OrderStatus>(
                    value: newStatus,
                    items:
                        OrderStatus.values
                            .map(
                              (status) => DropdownMenuItem(
                                value: status,
                                child: Text(status.name),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      setState(() {
                        newStatus = value;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                  ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  if (newStatus != null && newStatus != order.status) {
                    final provider = Provider.of<TailorShopProvider>(
                      context,
                      listen: false,
                    );
                    final updatedOrder = Order(
                      id: order.id,
                      invoiceNumber: order.invoiceNumber,
                      customerId: order.customerId,
                      garmentTypeId: order.garmentTypeId,
                      measurements: order.measurements,
                      quantity: order.quantity,
                      totalPrice: order.totalPrice,
                      orderDate: order.orderDate,
                      deliveryDate: order.deliveryDate,
                      status: newStatus!,
                      notes: order.notes,
                      createdAt: order.createdAt,
                      updatedAt: DateTime.now(),
                      advancePayment: order.advancePayment,
                    );

                    await provider.updateOrder(updatedOrder);

                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Order status updated successfully'),
                        ),
                      );
                    }
                  } else {
                    Navigator.pop(context);
                  }
                },
                child: const Text('Update'),
              ),
            ],
          ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Order order) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Order'),
            content: Text(
              'Are you sure you want to delete order ${order.invoiceNumber}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  final provider = Provider.of<TailorShopProvider>(
                    context,
                    listen: false,
                  );
                  await provider.deleteOrder(order.id);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Order deleted successfully'),
                      ),
                    );
                  }
                },
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.inProgress:
        return Colors.blue;
      case OrderStatus.completed:
        return Colors.green;
      case OrderStatus.delivered:
        return Colors.purple;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
