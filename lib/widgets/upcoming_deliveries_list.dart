import 'package:flutter/material.dart';
import '../models/order.dart';

class UpcomingDeliveriesList extends StatelessWidget {
  final List<Order> orders;

  const UpcomingDeliveriesList({super.key, required this.orders});

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return const Center(child: Text('No upcoming deliveries'));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        final isOverdue = order.deliveryDate.isBefore(DateTime.now());

        return ListTile(
          leading: Icon(
            Icons.schedule,
            color: isOverdue ? Colors.red : Colors.orange,
          ),
          title: Text(
            order.invoiceNumber,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            'Delivery: ${_formatDate(order.deliveryDate)}',
            style: TextStyle(
              color: isOverdue ? Colors.red : null,
              fontWeight: isOverdue ? FontWeight.bold : null,
            ),
          ),
          trailing: Chip(
            label: Text(
              order.status.name,
              style: const TextStyle(fontSize: 12),
            ),
            backgroundColor: _getStatusColor(order.status),
          ),
        );
      },
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange.withOpacity(0.2);
      case OrderStatus.inProgress:
        return Colors.blue.withOpacity(0.2);
      case OrderStatus.completed:
        return Colors.green.withOpacity(0.2);
      case OrderStatus.delivered:
        return Colors.purple.withOpacity(0.2);
      case OrderStatus.cancelled:
        return Colors.red.withOpacity(0.2);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
