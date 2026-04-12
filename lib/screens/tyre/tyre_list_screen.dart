import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TyreListScreen extends StatelessWidget {
  const TyreListScreen({super.key});

  void _navigateToDetail(BuildContext context, String tyreId) {
    Navigator.pushNamed(context, '/tyre_detail', arguments: tyreId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tyres'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add_tyre'),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('tyres').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching tyres'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No tyres found'));
          }

          final tyres = snapshot.data!.docs;

          return ListView.builder(
            itemCount: tyres.length,
            itemBuilder: (context, index) {
              final tyre = tyres[index];
              final data = tyre.data() as Map<String, dynamic>;
              final brand = data['brand'] ?? '';
              final mileage = data['mileage']?.toString() ?? '';

              return ListTile(
                title: Text('Brand: $brand'),
                subtitle: Text('Mileage: $mileage km'),
                onTap: () => _navigateToDetail(context, tyre.id),
              );
            },
          );
        },
      ),
    );
  }
}