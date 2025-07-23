import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tailor_shop_provider.dart';
import '../models/customer.dart';
import '../screens/add_edit_customer_screen.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Customer> _filteredCustomers = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterCustomers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCustomers() {
    final provider = Provider.of<TailorShopProvider>(context, listen: false);
    setState(() {
      _filteredCustomers = provider.searchCustomers(_searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.people_rounded, size: 24),
            SizedBox(width: 8),
            Text('Customers'),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              onPressed: () => _showAddCustomerDialog(context),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.person_add_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              tooltip: 'Add Customer',
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search customers...',
                hintText: 'Enter name or phone number',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: Consumer<TailorShopProvider>(
              builder: (context, provider, child) {
                final customers =
                    _searchController.text.isEmpty
                        ? provider.customers
                        : _filteredCustomers;

                if (customers.isEmpty) {
                  return const Center(child: Text('No customers found'));
                }

                return ListView.builder(
                  itemCount: customers.length,
                  itemBuilder: (context, index) {
                    final customer = customers[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            customer.name.isNotEmpty
                                ? customer.name[0].toUpperCase()
                                : 'C',
                          ),
                        ),
                        title: Text(
                          customer.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Phone: ${customer.phoneNumber}'),
                            if (customer.address != null)
                              Text('Address: ${customer.address}'),
                          ],
                        ),
                        trailing: PopupMenuButton(
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
                                  value: 'orders',
                                  child: Row(
                                    children: [
                                      Icon(Icons.assignment),
                                      SizedBox(width: 8),
                                      Text('View Orders'),
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
                                _showEditCustomerDialog(context, customer);
                                break;
                              case 'orders':
                                _showCustomerOrders(context, customer);
                                break;
                              case 'delete':
                                _showDeleteConfirmation(context, customer);
                                break;
                            }
                          },
                        ),
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

  void _showAddCustomerDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddEditCustomerScreen()),
    );
  }

  void _showEditCustomerDialog(BuildContext context, Customer customer) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditCustomerScreen(customer: customer),
      ),
    );
  }

  void _showCustomerOrders(BuildContext context, Customer customer) {
    final provider = Provider.of<TailorShopProvider>(context, listen: false);
    final orders = provider.getOrdersByCustomerId(customer.id);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('${customer.name}\'s Orders'),
            content: SizedBox(
              width: 400,
              height: 300,
              child:
                  orders.isEmpty
                      ? const Center(child: Text('No orders found'))
                      : ListView.builder(
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          final order = orders[index];
                          return ListTile(
                            title: Text(order.invoiceNumber),
                            subtitle: Text(
                              '${_formatDate(order.orderDate)} - ₹${order.totalPrice.toStringAsFixed(2)}',
                            ),
                            trailing: Chip(
                              label: Text(order.status.name),
                              backgroundColor: _getStatusColor(order.status),
                            ),
                          );
                        },
                      ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Customer customer) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Customer'),
            content: Text('Are you sure you want to delete ${customer.name}?'),
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
                  await provider.deleteCustomer(customer.id);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Customer deleted successfully'),
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

  Color _getStatusColor(dynamic status) {
    // This is a placeholder - you'll need to implement based on your OrderStatus enum
    return Colors.blue.withOpacity(0.2);
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
