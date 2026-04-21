import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';

class AdminScaffold extends StatelessWidget {
  final Widget child;
  const AdminScaffold({super.key, required this.child});

  int _routeIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/admin/inventory')) return 1;
    if (location.startsWith('/admin/bookings')) return 2;
    if (location.startsWith('/admin/orders')) return 3;
    if (location.startsWith('/admin/services')) return 4;
    if (location.startsWith('/admin/categories')) return 4;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0: context.go('/admin'); break;
      case 1: context.go('/admin/inventory'); break;
      case 2: context.go('/admin/bookings'); break;
      case 3: context.go('/admin/orders'); break;
      case 4: context.go('/admin/services'); break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _routeIndex(context);
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: AppColors.mrfBlack.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (i) => _onTap(context, i),
          backgroundColor: AppColors.mrfBlack,
          selectedItemColor: AppColors.mrfRed,
          unselectedItemColor: Colors.grey.shade500,
          type: BottomNavigationBarType.fixed,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.dashboard_rounded)),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.inventory_2_rounded)),
              label: 'Inventory',
            ),
            BottomNavigationBarItem(
              icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.handyman_rounded)),
              label: 'Bookings',
            ),
            BottomNavigationBarItem(
              icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.receipt_long_rounded)),
              label: 'Orders',
            ),
            BottomNavigationBarItem(
              icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.miscellaneous_services_rounded)),
              label: 'Services',
            ),
          ],
        ),
      ),
    );
  }
}
