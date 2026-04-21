import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';

class CompanyGalleryScreen extends StatelessWidget {
  const CompanyGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final images = [
      {'title': 'Initial Inspection', 'path': 'assets/images/Initial Inspection.jpg'},
      {'title': 'Buffing Process', 'path': 'assets/images/Buffing.jpeg'},
      {'title': 'Applying Bonding Agent', 'path': 'assets/images/Applying Bonding Agent .jpg'},
      {'title': 'Tread Application', 'path': 'assets/images/Tread Application.jpg'},
      {'title': 'Vulcanization Process', 'path': 'assets/images/Vulcanization .jpg'},
      {'title': 'Final Inspection', 'path': 'assets/images/Final Inspection.jpg'},
      {'title': 'Our Facility', 'path': 'assets/images/IMG-20240626-WA0000.jpg'},
      {'title': 'Retreaded Tire', 'path': 'assets/images/IMG-20240628-WA0016.jpg'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gallery'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.8,
          ),
          itemCount: images.length,
          itemBuilder: (context, index) {
            return Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Image.asset(
                      images[index]['path']!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                    ),
                  ),
                  Container(
                    color: AppColors.mrfWhite,
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      images[index]['title']!,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
