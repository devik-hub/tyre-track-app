import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/routes/app_routes.dart';

class MainScaffold extends StatefulWidget {
  final Widget child;
  const MainScaffold({super.key, required this.child});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  void _onTap(int index) {
    setState(() => _currentIndex = index);
    switch (index) {
      case 0: context.go(AppRoutes.home); break;
      case 1: context.go(AppRoutes.tyres); break;
      case 2: context.go(AppRoutes.services); break;
      case 3: context.go(AppRoutes.casings); break;
      case 4: context.go(AppRoutes.account); break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onTap(2),
        backgroundColor: AppColors.mrfRed,
        foregroundColor: Colors.white,
        child: const Icon(Icons.build),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        clipBehavior: Clip.antiAlias,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home_outlined, Icons.home, 'Home', 0),
            _buildNavItem(Icons.shopping_bag_outlined, Icons.shopping_bag, 'Buy Tyres', 1),
            const SizedBox(width: 48), // Gap for FAB
            _buildNavItem(Icons.circle_outlined, Icons.circle, 'Buy Casing', 3),
            _buildNavItem(Icons.person_outline, Icons.person, 'Account', 4),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, IconData activeIcon, String label, int index) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () => _onTap(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isSelected ? activeIcon : icon, color: isSelected ? AppColors.mrfRed : AppColors.mrfMidGrey, size: 24),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 10, color: isSelected ? AppColors.mrfRed : AppColors.mrfMidGrey, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}
