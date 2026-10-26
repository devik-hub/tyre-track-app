import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../domain/providers/service_availability_provider.dart';
import '../../../data/repositories/service_availability_repository.dart';
import '../../widgets/glass/liquid_glass_card.dart';
import '../../widgets/glass/liquid_glass_app_bar.dart';
import '../../widgets/glass/liquid_glass_status_badge.dart';
import '../../widgets/glass/admin_background.dart';

class ManageServicesScreen extends ConsumerWidget {
  const ManageServicesScreen({super.key});

  static const Map<String, Map<String, dynamic>> _serviceDetails = {
    'retreading': {'title': 'Retreading', 'icon': Icons.sync, 'desc': 'Extend tyre life with premium MRF treading'},
    'remoulding': {'title': 'Remoulding', 'icon': Icons.layers, 'desc': 'Complete tyre rebuild for safety'},
    'inspection': {'title': 'Inspection', 'icon': Icons.search, 'desc': 'Detailed 25-point safety check'},
    'new_fitment': {'title': 'New Fitment', 'icon': Icons.build, 'desc': 'Professional installation of new tyres'},
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final availAsync = ref.watch(serviceAvailabilityProvider);
    final today = DateFormat('EEEE, MMM d, yyyy').format(DateTime.now());

    return Scaffold(backgroundColor: AppColors.mrfBlack,
      body: AdminBackground(child: Column(children: [
        const LiquidGlassAppBar(title: 'Service Availability', isDark: true),
        Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          LiquidGlassCard(isDark: true, borderRadius: 16, blurStrength: 12,
            child: Row(children: [
              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.mrfRed.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.calendar_today, color: AppColors.mrfRed, size: 24)),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text("Today's Schedule", style: AppTextStyles.body2.copyWith(color: AppColors.adminTextSec)),
                const SizedBox(height: 4),
                Text(today, style: AppTextStyles.h3.copyWith(color: AppColors.adminTextPrimary)),
              ])),
            ])),
          const SizedBox(height: 24),
          Text('TOGGLE SERVICES', style: AppTextStyles.labelCaps.copyWith(color: AppColors.adminTextTert)),
          const SizedBox(height: 4),
          Text('Changes reflect instantly for customers.', style: AppTextStyles.body2.copyWith(color: AppColors.adminTextTert)),
          const SizedBox(height: 16),
          availAsync.when(
            loading: () => const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(color: AppColors.mrfRed))),
            error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.red))),
            data: (availability) => Column(children: _serviceDetails.entries.map((entry) {
              final key = entry.key;
              final details = entry.value;
              final isEnabled = availability[key] ?? true;
              return _toggleTile(ref: ref, serviceKey: key, title: details['title'] as String,
                description: details['desc'] as String, icon: details['icon'] as IconData, isEnabled: isEnabled);
            }).toList())),
        ]))),
      ])),
    );
  }

  Widget _toggleTile({required WidgetRef ref, required String serviceKey, required String title,
    required String description, required IconData icon, required bool isEnabled}) {
    return Padding(padding: const EdgeInsets.only(bottom: 12),
      child: LiquidGlassCard(isDark: true, borderRadius: 16, blurStrength: 10,
        child: Row(children: [
          Container(padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: (isEnabled ? Colors.green : Colors.red).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: isEnabled ? Colors.green : Colors.red, size: 24)),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: AppTextStyles.h3.copyWith(color: AppColors.adminTextPrimary)),
            const SizedBox(height: 4),
            Text(description, style: AppTextStyles.body2.copyWith(color: AppColors.adminTextTert)),
            const SizedBox(height: 6),
            LiquidGlassStatusBadge(label: isEnabled ? 'ACTIVE' : 'DISABLED', color: isEnabled ? Colors.greenAccent : Colors.redAccent),
          ])),
          Switch(value: isEnabled, activeColor: Colors.green, inactiveThumbColor: Colors.red, inactiveTrackColor: Colors.red.withValues(alpha: 0.3),
            onChanged: (value) => ref.read(serviceAvailabilityRepositoryProvider).toggleService(serviceKey, value)),
        ])));
  }
}
