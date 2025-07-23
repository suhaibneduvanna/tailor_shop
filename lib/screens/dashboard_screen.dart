import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tailor_shop_provider.dart';
import '../widgets/recent_orders_list.dart';
import '../widgets/upcoming_deliveries_list.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.dashboard, size: 24),
            SizedBox(width: 8),
            Text('Dashboard'),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: Chip(
              avatar: const Icon(Icons.access_time, size: 16),
              label: Text(
                _formatTime(DateTime.now()),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              backgroundColor: const Color(0xFF2E7D32).withOpacity(0.1),
              side: BorderSide.none,
            ),
          ),
        ],
      ),
      body: Consumer<TailorShopProvider>(
        builder: (context, provider, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF2E7D32).withOpacity(0.02),
                  Colors.white,
                ],
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2E7D32), Color(0xFF388E3C)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2E7D32).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.content_cut,
                          size: 40,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Welcome to Libasu Thaqwa',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'The advanced tailor shop management system',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Statistics Cards
                  LayoutBuilder(
                    builder: (context, constraints) {
                      // Determine number of columns based on available width
                      int crossAxisCount = 4;
                      if (constraints.maxWidth < 1200) {
                        crossAxisCount = 3;
                      }
                      if (constraints.maxWidth < 900) {
                        crossAxisCount = 2;
                      }
                      if (constraints.maxWidth < 600) {
                        crossAxisCount = 1;
                      }

                      return GridView.count(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio:
                            crossAxisCount == 1
                                ? 4
                                : 2.2, // Adjust aspect ratio for single column
                        children: [
                          _buildEnhancedDashboardCard(
                            title: 'Total Customers',
                            value: provider.totalCustomers.toString(),
                            icon: Icons.people_rounded,
                            color: const Color(0xFF1976D2),
                          ),
                          _buildEnhancedDashboardCard(
                            title: 'Total Orders',
                            value: provider.totalOrders.toString(),
                            icon: Icons.assignment_rounded,
                            color: const Color(0xFF388E3C),
                          ),
                          _buildEnhancedDashboardCard(
                            title: 'Pending Orders',
                            value: provider.pendingOrders.toString(),
                            icon: Icons.pending_actions_rounded,
                            color: const Color(0xFFF57C00),
                          ),
                          _buildEnhancedDashboardCard(
                            title: 'Total Revenue',
                            value:
                                'Rs. ${provider.totalRevenue.toStringAsFixed(0)}',
                            icon: Icons.monetization_on_rounded,
                            color: const Color(0xFF7B1FA2),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 32),

                  // Recent Activities Section
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth < 800) {
                        // Stack vertically on smaller screens
                        return Column(
                          children: [
                            _buildRecentOrdersCard(provider),
                            const SizedBox(height: 20),
                            _buildUpcomingDeliveriesCard(provider),
                          ],
                        );
                      } else {
                        // Side by side on larger screens
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildRecentOrdersCard(provider)),
                            const SizedBox(width: 20),
                            Expanded(
                              child: _buildUpcomingDeliveriesCard(provider),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEnhancedDashboardCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16), // Reduced from 20 to 16
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10), // Reduced from 12 to 10
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
              ],
            ),

            Text(
              value,
              style: TextStyle(
                fontSize: 29, // Reduced from 24 to 20
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),

            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Widget _buildRecentOrdersCard(TailorShopProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.history_rounded,
                    color: Color(0xFF2E7D32),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Recent Orders',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            RecentOrdersList(orders: provider.recentOrders),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingDeliveriesCard(TailorShopProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF57C00).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.schedule_rounded,
                    color: Color(0xFFF57C00),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Upcoming Deliveries',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFF57C00),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            UpcomingDeliveriesList(orders: provider.upcomingDeliveries),
          ],
        ),
      ),
    );
  }
}
