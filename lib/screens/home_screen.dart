import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'customers_screen.dart';
import 'orders_screen.dart';
import 'garment_types_screen.dart';
import 'backup_management_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const CustomersScreen(),
    const OrdersScreen(),
    const GarmentTypesScreen(),
    const BackupManagementScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF2E7D32).withOpacity(0.05),
                  const Color(0xFF388E3C).withOpacity(0.02),
                ],
              ),
              border: Border(
                right: BorderSide(
                  color: Colors.grey.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              labelType: NavigationRailLabelType.all,
              backgroundColor: Colors.transparent,
              selectedIconTheme: const IconThemeData(
                color: Color(0xFF2E7D32),
                size: 28,
              ),
              unselectedIconTheme: IconThemeData(
                color: Colors.grey[600],
                size: 24,
              ),
              selectedLabelTextStyle: const TextStyle(
                color: Color(0xFF2E7D32),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelTextStyle: TextStyle(
                color: Colors.grey[600],
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              useIndicator: true,
              indicatorColor: const Color(0xFF2E7D32).withOpacity(0.12),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard),
                  label: Text('Dashboard'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.people_outlined),
                  selectedIcon: Icon(Icons.people),
                  label: Text('Customers'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.assignment_outlined),
                  selectedIcon: Icon(Icons.assignment),
                  label: Text('Orders'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.style_outlined),
                  selectedIcon: Icon(Icons.style),
                  label: Text('Garments'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.backup_outlined),
                  selectedIcon: Icon(Icons.backup),
                  label: Text('Backup'),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(color: Color(0xFFFAFAFA)),
              child: _screens[_selectedIndex],
            ),
          ),
        ],
      ),
    );
  }
}
