import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/routes/app_routes.dart';
import '../glass/liquid_glass_bottom_nav.dart';
import '../glass/admin_background.dart';

class AdminScaffold extends StatelessWidget {
  final Widget child;
  const AdminScaffold({super.key, required this.child});

  static const _navItems = [
    LiquidNavItem(icon: LucideIcons.layoutDashboard, activeIcon: LucideIcons.layoutDashboard, label: 'Dashboard'),
    LiquidNavItem(icon: LucideIcons.boxes, activeIcon: LucideIcons.boxes, label: 'Inventory'),
    LiquidNavItem(icon: LucideIcons.calendarCheck, activeIcon: LucideIcons.calendarCheck, label: 'Bookings'),
    LiquidNavItem(icon: LucideIcons.receipt, activeIcon: LucideIcons.receipt, label: 'Orders'),
    LiquidNavItem(icon: LucideIcons.settings, activeIcon: LucideIcons.settings, label: 'Settings'),
  ];

  int _routeIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/admin/inventory')) return 1;
    if (location.startsWith('/admin/bookings')) return 2;
    if (location.startsWith('/admin/orders')) return 3;
    if (location.startsWith('/admin/settings')) return 4;
    if (location.startsWith('/admin/services')) return 4;
    if (location.startsWith('/admin/categories')) return 4;
    if (location.startsWith('/admin/order-detail')) return 3;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.admin);
        break;
      case 1:
        context.go(AppRoutes.adminInventory);
        break;
      case 2:
        context.go(AppRoutes.adminBookings);
        break;
      case 3:
        context.go(AppRoutes.adminOrders);
        break;
      case 4:
        context.go(AppRoutes.adminSettings);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _routeIndex(context);
    return Scaffold(
      backgroundColor: AppColors.adminBg1,
      body: AdminBackground(child: child),
      bottomNavigationBar: LiquidGlassBottomNav(
        currentIndex: currentIndex,
        onTap: (i) => _onTap(context, i),
        items: _navItems,
        isDark: true,
      ),
    );
  }
}
