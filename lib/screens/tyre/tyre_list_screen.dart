import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tyre_management/utils/tyre_utils.dart';

class TyreListScreen extends StatelessWidget {
  const TyreListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),

      // 🔥 StreamBuilder for real-time data
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tyres')
            .orderBy('createdAt', descending: true)
            .snapshots(),

        builder: (context, snapshot) {
          // 🔄 Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ❌ Error
          if (snapshot.hasError) {
            return const Center(child: Text("Error fetching tyres"));
          }

          // 📭 Empty state
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No tyres found"));
          }

          // 📦 Data
          final tyres = snapshot.data!.docs;

          return ListView.builder(
            itemCount: tyres.length,
            itemBuilder: (context, index) {
              final tyre = tyres[index];
              final data = tyre.data() as Map<String, dynamic>? ?? {};

              final brand = data['brand']?.toString() ?? 'Unknown';
              final mileageRaw = data['mileage'] ?? 0;
              final mileage = mileageRaw is int ? mileageRaw : int.tryParse(mileageRaw.toString()) ?? 0;
              
              final bool wornTread = data['wornTread'] == true;
              final bool cracks = data['cracks'] == true;
              final bool bulge = data['bulge'] == true;

              final healthScore = TyreUtils.calculateHealthScore(
                mileage: mileage,
                wornTread: wornTread,
                cracks: cracks,
                bulge: bulge,
              );

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text(brand),
                  subtitle: Text("Mileage: $mileage km\nHealth Score: $healthScore/100"),
                  isThreeLine: true,

                  // 👉 Tap → future detail screen
                  onTap: () {
                    Navigator.pushNamed(context, '/tyre_detail', arguments: tyre.id);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}