import 'package:flutter/material.dart';
import 'package:tyre_management/screens/booking/bookings_screen.dart';
import 'package:tyre_management/screens/home/dashboard_tab.dart';
import 'package:tyre_management/screens/profile/profile_screen.dart';
import 'package:tyre_management/screens/tyre/tyre_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const _titles = ['Dashboard', 'Tyres', 'Bookings', 'Profile'];
  static const _tabs = [
    DashboardTab(),
    TyreListScreen(),
    BookingsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
      ),
      body: _tabs[_selectedIndex],
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton(
              onPressed: () => Navigator.pushNamed(context, '/add_tyre'),
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.tire_repair_outlined),
            activeIcon: Icon(Icons.tire_repair),
            label: 'Tyres',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

