import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  String _formatDate(dynamic value) {
    if (value == null) return 'Date not set';
    try {
      if (value is Timestamp) {
        return DateFormat('dd MMM yyyy').format(value.toDate());
      }
    } catch (_) {}
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    // NOTE: No orderBy here — ordering requires a Firestore composite index.
    // Docs are returned in insertion order, which is fine for now.
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bookings')
          .snapshots(),
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
                Icon(Icons.event_busy, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No bookings yet.\nBook a service from the Tyres tab.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
          );
        }

        final docs = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final serviceType = data['serviceType']?.toString() ?? 'Service';
            final dateText = _formatDate(data['date']);
            final tyreId = data['tyreId']?.toString() ?? '';

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: ListTile(
                leading: const Icon(Icons.event_note, color: Colors.blue),
                title: Text(
                  serviceType,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('Date: $dateText'),
                trailing: tyreId.isNotEmpty
                    ? const Icon(Icons.tire_repair_outlined, color: Colors.grey)
                    : null,
              ),
            );
          },
        );
      },
    );
  }
}