import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../data/models/business_info_model.dart';
import '../../../domain/providers/business_info_provider.dart';
import '../../widgets/glass/liquid_glass_card.dart';
import '../../widgets/glass/liquid_glass_app_bar.dart';
import '../../widgets/glass/liquid_glass_button.dart';
import '../../widgets/glass/liquid_glass_text_field.dart';
import '../../widgets/glass/admin_background.dart';

class AdminSettingsScreen extends ConsumerStatefulWidget {
  const AdminSettingsScreen({super.key});
  @override
  ConsumerState<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends ConsumerState<AdminSettingsScreen> {
  final _phoneC = TextEditingController();
  final _whatsappC = TextEditingController();
  final _emailC = TextEditingController();
  final _addressC = TextEditingController();
  final _mapsUrlC = TextEditingController();
  final _nameC = TextEditingController();
  final _instaC = TextEditingController();
  final _fbC = TextEditingController();
  Map<String, DaySchedule> _hours = {};
  bool _loaded = false;
  bool _saving = false;

  void _populateFields(BusinessInfoModel info) {
    if (_loaded) return;
    _nameC.text = info.businessName;
    _phoneC.text = info.phone;
    _whatsappC.text = info.whatsapp;
    _emailC.text = info.email;
    _addressC.text = info.address;
    _mapsUrlC.text = info.googleMapsUrl;
    _instaC.text = info.socialLinks['instagram'] ?? '';
    _fbC.text = info.socialLinks['facebook'] ?? '';
    _hours = Map<String, DaySchedule>.from(info.businessHours);
    if (_hours.isEmpty) {
      for (final d in ['monday','tuesday','wednesday','thursday','friday','saturday']) {
        _hours[d] = DaySchedule(isOpen: true, openTime: '09:00', closeTime: '19:00');
      }
      _hours['sunday'] = DaySchedule(isOpen: false);
    }
    _loaded = true;
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final model = BusinessInfoModel(
        businessName: _nameC.text.trim(), phone: _phoneC.text.trim(), whatsapp: _whatsappC.text.trim(),
        email: _emailC.text.trim(), address: _addressC.text.trim(), googleMapsUrl: _mapsUrlC.text.trim(),
        businessHours: _hours, socialLinks: {
          if (_instaC.text.trim().isNotEmpty) 'instagram': _instaC.text.trim(),
          if (_fbC.text.trim().isNotEmpty) 'facebook': _fbC.text.trim(),
        });
      await FirebaseFirestore.instance.doc('config/businessInfo').set(model.toFirestore());
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Settings saved')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally { if (mounted) setState(() => _saving = false); }
  }

  @override
  Widget build(BuildContext context) {
    final infoAsync = ref.watch(businessInfoProvider);
    return Scaffold(backgroundColor: AppColors.mrfBlack,
      body: AdminBackground(child: Column(children: [
        const LiquidGlassAppBar(title: 'Admin Settings', isDark: true),
        Expanded(child: infoAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.mrfRed)),
          error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.red))),
          data: (info) {
            _populateFields(info);
            return SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text('BUSINESS INFORMATION', style: AppTextStyles.labelCaps.copyWith(color: AppColors.adminTextTert)),
              const SizedBox(height: 16),
              LiquidGlassTextField(controller: _nameC, labelText: 'Business Name', prefixIcon: Icons.business, isDark: true),
              const SizedBox(height: 12),
              LiquidGlassTextField(controller: _phoneC, labelText: 'Phone Number', prefixIcon: Icons.phone, isDark: true),
              const SizedBox(height: 12),
              LiquidGlassTextField(controller: _whatsappC, labelText: 'WhatsApp', prefixIcon: Icons.message, isDark: true),
              const SizedBox(height: 12),
              LiquidGlassTextField(controller: _emailC, labelText: 'Email', prefixIcon: Icons.email, isDark: true),
              const SizedBox(height: 12),
              LiquidGlassTextField(controller: _addressC, labelText: 'Address', prefixIcon: Icons.location_on, isDark: true, maxLines: 2),
              const SizedBox(height: 12),
              LiquidGlassTextField(controller: _mapsUrlC, labelText: 'Google Maps URL', prefixIcon: Icons.map, isDark: true),
              const SizedBox(height: 28),
              Text('BUSINESS HOURS', style: AppTextStyles.labelCaps.copyWith(color: AppColors.adminTextTert)),
              const SizedBox(height: 16),
              ..._buildHoursEditors(),
              const SizedBox(height: 28),
              Text('SOCIAL LINKS', style: AppTextStyles.labelCaps.copyWith(color: AppColors.adminTextTert)),
              const SizedBox(height: 16),
              LiquidGlassTextField(controller: _instaC, labelText: 'Instagram URL', prefixIcon: Icons.camera_alt, isDark: true),
              const SizedBox(height: 12),
              LiquidGlassTextField(controller: _fbC, labelText: 'Facebook URL', prefixIcon: Icons.facebook, isDark: true),
              const SizedBox(height: 28),
              LiquidGlassButton(label: 'SAVE ALL CHANGES', isDark: true, isLoading: _saving,
                onPressed: _saving ? null : _save),
              const SizedBox(height: 40),
            ]));
          })),
      ])),
    );
  }

  List<Widget> _buildHoursEditors() {
    return ['monday','tuesday','wednesday','thursday','friday','saturday','sunday'].map((day) {
      final schedule = _hours[day] ?? DaySchedule(isOpen: false);
      return Padding(padding: const EdgeInsets.only(bottom: 8),
        child: LiquidGlassCard(isDark: true, borderRadius: 12, blurStrength: 8, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(children: [
            SizedBox(width: 90, child: Text(day[0].toUpperCase() + day.substring(1), style: AppTextStyles.label1.copyWith(color: AppColors.adminTextPrimary))),
            Switch(value: schedule.isOpen, activeColor: AppColors.mrfRed,
              onChanged: (val) => setState(() => _hours[day] = DaySchedule(isOpen: val, openTime: schedule.openTime ?? '09:00', closeTime: schedule.closeTime ?? '19:00'))),
            Text(schedule.isOpen ? 'Open' : 'Closed', style: AppTextStyles.labelCaps.copyWith(color: schedule.isOpen ? Colors.greenAccent : Colors.redAccent)),
            const Spacer(),
            if (schedule.isOpen) Text('${schedule.openTime ?? "09:00"} — ${schedule.closeTime ?? "19:00"}', style: AppTextStyles.body2.copyWith(color: AppColors.adminTextTert)),
          ])));
    }).toList();
  }
}
