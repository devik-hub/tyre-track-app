import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';

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
      case 0: context.go('/home'); break;
      case 1: context.go('/tyres'); break;
      case 2: context.go('/services'); break;
      case 3: context.go('/vehicles'); break;
      case 4: context.go('/account'); break;
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
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTap,
          selectedItemColor: AppColors.mrfRed,
          unselectedItemColor: AppColors.mrfMidGrey,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), activeIcon: Icon(Icons.shopping_bag), label: 'Buy Tires'),
            BottomNavigationBarItem(icon: Icon(Icons.build, color: Colors.transparent), label: 'Services'), // Placeholder for FAB
            BottomNavigationBarItem(icon: Icon(Icons.directions_car_outlined), activeIcon: Icon(Icons.directions_car), label: 'Vehicles'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Account'),
          ],
        ),
      ),
    );
  }
}
