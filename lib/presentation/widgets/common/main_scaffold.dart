import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/routes/app_routes.dart';
import '../glass/liquid_glass_bottom_nav.dart';
import '../glass/customer_background.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;
  const MainScaffold({super.key, required this.child});

  static const _navItems = [
    LiquidNavItem(icon: LucideIcons.home, activeIcon: LucideIcons.home, label: 'Home'),
    LiquidNavItem(icon: LucideIcons.shoppingBag, activeIcon: LucideIcons.shoppingBag, label: 'Tyres'),
    LiquidNavItem(icon: LucideIcons.wrench, activeIcon: LucideIcons.wrench, label: 'Services'),
    LiquidNavItem(icon: LucideIcons.disc, activeIcon: LucideIcons.disc, label: 'Casing'),
    LiquidNavItem(icon: LucideIcons.user, activeIcon: LucideIcons.user, label: 'Account'),
  ];

  int _routeIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/tyres')) return 1;
    if (location.startsWith('/services')) return 2;
    if (location.startsWith('/casings')) return 3;
    if (location.startsWith('/account')) return 4;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.home);
        break;
      case 1:
        context.go(AppRoutes.tyres);
        break;
      case 2:
        context.go(AppRoutes.services);
        break;
      case 3:
        context.go(AppRoutes.casings);
        break;
      case 4:
        context.go(AppRoutes.account);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _routeIndex(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomerBackground(child: child),
      bottomNavigationBar: LiquidGlassBottomNav(
        currentIndex: currentIndex,
        onTap: (index) => _onTap(context, index),
        items: _navItems,
      ),
    );
  }
}
