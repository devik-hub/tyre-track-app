import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../app/theme/app_colors.dart';
import '../../../data/models/business_info_model.dart';
import '../../../domain/providers/business_info_provider.dart';

class AdminSettingsScreen extends ConsumerStatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  ConsumerState<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends ConsumerState<AdminSettingsScreen> {
  final _phoneC     = TextEditingController();
  final _whatsappC  = TextEditingController();
  final _emailC     = TextEditingController();
  final _addressC   = TextEditingController();
  final _mapsUrlC   = TextEditingController();
  final _nameC      = TextEditingController();
  final _instaC     = TextEditingController();
  final _fbC        = TextEditingController();

  Map<String, DaySchedule> _hours = {};
  bool _loaded = false;
  bool _saving = false;

  void _populateFields(BusinessInfoModel info) {
    if (_loaded) return;
    _nameC.text     = info.businessName;
    _phoneC.text    = info.phone;
    _whatsappC.text = info.whatsapp;
    _emailC.text    = info.email;
    _addressC.text  = info.address;
    _mapsUrlC.text  = info.googleMapsUrl;
    _instaC.text    = info.socialLinks['instagram'] ?? '';
    _fbC.text       = info.socialLinks['facebook'] ?? '';
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
        businessName:  _nameC.text.trim(),
        phone:         _phoneC.text.trim(),
        whatsapp:      _whatsappC.text.trim(),
        email:         _emailC.text.trim(),
        address:       _addressC.text.trim(),
        googleMapsUrl: _mapsUrlC.text.trim(),
        businessHours: _hours,
        socialLinks: {
          if (_instaC.text.trim().isNotEmpty) 'instagram': _instaC.text.trim(),
          if (_fbC.text.trim().isNotEmpty)    'facebook':  _fbC.text.trim(),
        },
      );
      await FirebaseFirestore.instance.doc('config/businessInfo').set(model.toFirestore());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Business info saved — changes are live instantly.')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final infoAsync = ref.watch(businessInfoProvider);

    return Scaffold(
      backgroundColor: AppColors.mrfBlack,
      appBar: AppBar(
        title: const Text('Admin Settings', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: infoAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.mrfRed)),
        error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.red))),
        data: (info) {
          _populateFields(info);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('BUSINESS INFORMATION', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.grey)),
                const SizedBox(height: 16),
                _buildField(_nameC, 'Business Name', Icons.business),
                const SizedBox(height: 12),
                _buildField(_phoneC, 'Phone Number', Icons.phone),
                const SizedBox(height: 12),
                _buildField(_whatsappC, 'WhatsApp Number', Icons.message),
                const SizedBox(height: 12),
                _buildField(_emailC, 'Email Address', Icons.email),
                const SizedBox(height: 12),
                _buildField(_addressC, 'Full Address', Icons.location_on, maxLines: 2),
                const SizedBox(height: 12),
                _buildField(_mapsUrlC, 'Google Maps URL', Icons.map),

                const SizedBox(height: 32),
                const Text('BUSINESS HOURS', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.grey)),
                const SizedBox(height: 16),
                ..._buildHoursEditors(),

                const SizedBox(height: 32),
                const Text('SOCIAL LINKS', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.grey)),
                const SizedBox(height: 16),
                _buildField(_instaC, 'Instagram URL', Icons.camera_alt),
                const SizedBox(height: 12),
                _buildField(_fbC, 'Facebook URL', Icons.facebook),

                const SizedBox(height: 32),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.mrfRed, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('SAVE ALL CHANGES', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildField(TextEditingController c, String label, IconData icon, {int maxLines = 1}) {
    return TextField(
      controller: c,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
        prefixIcon: Icon(icon, color: Colors.grey.shade600, size: 20),
        filled: true,
        fillColor: const Color(0xFF2C2C2C),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.mrfRed, width: 1)),
      ),
    );
  }

  List<Widget> _buildHoursEditors() {
    final days = ['monday','tuesday','wednesday','thursday','friday','saturday','sunday'];
    return days.map((day) {
      final schedule = _hours[day] ?? DaySchedule(isOpen: false);
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            SizedBox(width: 90, child: Text(day[0].toUpperCase() + day.substring(1), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500))),
            Switch(
              value: schedule.isOpen,
              activeColor: AppColors.mrfRed,
              onChanged: (val) => setState(() => _hours[day] = DaySchedule(isOpen: val, openTime: schedule.openTime ?? '09:00', closeTime: schedule.closeTime ?? '19:00')),
            ),
            Text(schedule.isOpen ? 'Open' : 'Closed', style: TextStyle(color: schedule.isOpen ? Colors.greenAccent : Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold)),
            const Spacer(),
            if (schedule.isOpen) Text('${schedule.openTime ?? "09:00"} — ${schedule.closeTime ?? "19:00"}', style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
          ],
        ),
      );
    }).toList();
  }
}
