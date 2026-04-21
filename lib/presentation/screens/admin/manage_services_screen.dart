import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_colors.dart';
import '../../../domain/providers/service_availability_provider.dart';
import '../../../data/repositories/service_availability_repository.dart';

class ManageServicesScreen extends ConsumerWidget {
  const ManageServicesScreen({super.key});

  static const Map<String, Map<String, dynamic>> _serviceDetails = {
    'retreading': {'title': 'Retreading', 'icon': Icons.sync, 'desc': 'Extend the life of tyres with premium MRF treading'},
    'remoulding': {'title': 'Remoulding', 'icon': Icons.layers, 'desc': 'Complete tyre rebuild for superior safety'},
    'inspection': {'title': 'Inspection', 'icon': Icons.search, 'desc': 'Detailed 25-point safety check'},
    'new_fitment': {'title': 'New Fitment', 'icon': Icons.build, 'desc': 'Professional installation of new tyres'},
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final availabilityAsync = ref.watch(serviceAvailabilityProvider);
    final today = DateFormat('EEEE, MMM d, yyyy').format(DateTime.now());

    return Scaffold(
      backgroundColor: AppColors.mrfBlack,
      appBar: AppBar(
        title: const Text('Service Availability',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E1E1E), Color(0xFF2C2C2C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.mrfRed.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.calendar_today, color: AppColors.mrfRed, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Today\'s Schedule',
                            style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 4),
                        Text(today,
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('TOGGLE SERVICES',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.grey)),
            const SizedBox(height: 4),
            Text('Disable services based on today\'s workload. Changes reflect instantly for customers.',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            const SizedBox(height: 16),

            // Service toggles
            availabilityAsync.when(
              loading: () => const Center(
                  child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(color: AppColors.mrfRed))),
              error: (e, _) => Center(
                  child: Text('Error loading: $e', style: const TextStyle(color: Colors.red))),
              data: (availability) {
                return Column(
                  children: _serviceDetails.entries.map((entry) {
                    final key = entry.key;
                    final details = entry.value;
                    final isEnabled = availability[key] ?? true;

                    return _buildServiceToggleTile(
                      ref: ref,
                      serviceKey: key,
                      title: details['title'] as String,
                      description: details['desc'] as String,
                      icon: details['icon'] as IconData,
                      isEnabled: isEnabled,
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceToggleTile({
    required WidgetRef ref,
    required String serviceKey,
    required String title,
    required String description,
    required IconData icon,
    required bool isEnabled,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isEnabled ? Colors.green.withValues(alpha: 0.3) : Colors.red.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (isEnabled ? Colors.green : Colors.red).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: isEnabled ? Colors.green : Colors.red, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(description,
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: (isEnabled ? Colors.green : Colors.red).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    isEnabled ? 'ACTIVE' : 'DISABLED',
                    style: TextStyle(
                      color: isEnabled ? Colors.greenAccent : Colors.redAccent,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isEnabled,
            onChanged: (value) {
              ref.read(serviceAvailabilityRepositoryProvider).toggleService(serviceKey, value);
            },
            activeColor: Colors.green,
            inactiveThumbColor: Colors.red,
            inactiveTrackColor: Colors.red.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }
}
