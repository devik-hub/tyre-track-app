import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/routes/app_routes.dart';
import 'dart:math';

class ServicesHomeScreen extends StatelessWidget {
  const ServicesHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final services = [
      {'title': 'Retreading', 'icon': Icons.sync, 'desc': 'Extend the life of your tyre with premium MRF treading.'},
      {'title': 'Remoulding', 'icon': Icons.layers, 'desc': 'Complete tyre rebuild for superior safety.'},
      {'title': 'Inspection', 'icon': Icons.search, 'desc': 'Detailed 25-point safety check.'},
      {'title': 'New Fitment', 'icon': Icons.build, 'desc': 'Professional installation of new tyres.'},
      {'title': 'Balancing', 'icon': Icons.balance, 'desc': 'Prevent uneven wear and vibration.'},
      {'title': 'Rotation', 'icon': Icons.autorenew, 'desc': 'Maximize tyre lifespan with regular rotation.'},
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go(AppRoutes.home)),
        title: const Text('Services'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: services.length,
        itemBuilder: (context, index) {
          final service = services[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                backgroundColor: AppColors.mrfRed.withOpacity(0.1),
                radius: 30,
                child: Icon(service['icon'] as IconData, color: AppColors.mrfRed, size: 30),
              ),
              title: Text(service['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(service['desc'] as String),
              ),
              trailing: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(80, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: const Text('Book'),
              ),
            ),
          );
        },
      ),
    );
  }
}
