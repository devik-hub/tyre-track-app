import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TyreListScreen extends StatelessWidget {
  const TyreListScreen({super.key});

  void _navigateToDetail(BuildContext context, String tyreId) {
    Navigator.pushNamed(context, '/tyre_detail', arguments: tyreId);
  }

  @override
  Widget build(BuildContext context) {
    // No Scaffold here — this widget is embedded as a tab inside HomeScreen.
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('tyres').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.tire_repair_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No tyres added yet.\nTap + to add your first tyre.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
          );
        }

        final tyres = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: tyres.length,
          itemBuilder: (context, index) {
            final tyre = tyres[index];
            final data = tyre.data() as Map<String, dynamic>;
            final brand = data['brand']?.toString() ?? 'Unknown';
            final mileage = data['mileage']?.toString() ?? '0';
            final wornTread = data['wornTread'] == true;
            final cracks = data['cracks'] == true;
            final bulge = data['bulge'] == true;

            // Show a warning icon if any condition issue exists
            final hasIssue = wornTread || cracks || bulge;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: ListTile(
                leading: Icon(
                  Icons.tire_repair,
                  color: hasIssue ? Colors.orange : Colors.green,
                ),
                title: Text(
                  brand,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('Mileage: $mileage km'),
                trailing: hasIssue
                    ? const Icon(Icons.warning_amber, color: Colors.orange)
                    : const Icon(Icons.check_circle, color: Colors.green),
                onTap: () => _navigateToDetail(context, tyre.id),
              ),
            );
          },
        );
      },
    );
  }
}