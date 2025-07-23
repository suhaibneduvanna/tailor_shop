import 'package:flutter/material.dart';
import '../models/order.dart';

class RecentOrdersList extends StatelessWidget {
  final List<Order> orders;

  const RecentOrdersList({super.key, required this.orders});

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return const Center(child: Text('No recent orders'));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: _getStatusColor(order.status),
            child: Text(
              order.invoiceNumber.substring(order.invoiceNumber.length - 2),
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          title: Text(
            order.invoiceNumber,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            '${_formatDate(order.orderDate)} - ${order.status.name}',
          ),
          trailing: Text(
            '₹${order.totalPrice.toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        );
      },
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
