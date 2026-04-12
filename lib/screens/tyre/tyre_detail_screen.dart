import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TyreDetailScreen extends StatelessWidget {
  const TyreDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tyreId = ModalRoute.of(context)?.settings.arguments as String?;

    if (tyreId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Tyre Details')),
        body: const Center(child: Text('No tyre selected.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tyre Details'),
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: FirebaseFirestore.instance.collection('tyres').doc(tyreId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Error loading tyre details.'));
          }

          final data = snapshot.data!.data()!;
          final brand = (data['brand'] ?? '').toString();
          final mileage = data['mileage']?.toString() ?? 'N/A';
          final wornTread = data['wornTread'] == true;
          final cracks = data['cracks'] == true;
          final bulge = data['bulge'] == true;

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Brand: $brand', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Mileage: $mileage km', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 16),
                const Text('Condition:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text('• Worn tread: ${wornTread ? "Yes" : "No"}', style: const TextStyle(fontSize: 16)),
                Text('• Cracks: ${cracks ? "Yes" : "No"}', style: const TextStyle(fontSize: 16)),
                Text('• Bulge: ${bulge ? "Yes" : "No"}', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 24),
                const Text(
                  'Tip: Use Book Service to schedule inspection/replace visits.',
                  style: TextStyle(fontSize: 16, color: Colors.blue),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushNamed(
                      context,
                      '/book_service',
                      arguments: tyreId,
                    ),
                    child: const Text('Book Service'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}