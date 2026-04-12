import 'package:flutter/material.dart';

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.tire_repair, size: 72),
            SizedBox(height: 16),
            Text(
              'Welcome to Tyre Track',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Use the tabs below to manage tyres, bookings, and your profile.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
