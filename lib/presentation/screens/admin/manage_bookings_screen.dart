import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../data/models/booking_model.dart';
import '../../../data/repositories/booking_repository.dart';
import '../../../domain/providers/booking_provider.dart';
import '../../widgets/glass/liquid_glass_card.dart';
import '../../widgets/glass/liquid_glass_app_bar.dart';
import '../../widgets/glass/liquid_glass_button.dart';
import '../../widgets/glass/liquid_glass_status_badge.dart';
import '../../widgets/glass/admin_background.dart';

class ManageBookingsScreen extends ConsumerStatefulWidget {
  const ManageBookingsScreen({super.key});
  @override
  ConsumerState<ManageBookingsScreen> createState() => _ManageBookingsScreenState();
}

class _ManageBookingsScreenState extends ConsumerState<ManageBookingsScreen> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final bookingsAsync = ref.watch(allBookingsProvider);
    return Scaffold(backgroundColor: AppColors.mrfBlack,
      body: AdminBackground(child: Column(children: [
        const LiquidGlassAppBar(title: 'Service Bookings', isDark: true),
        _buildFilterChips(),
        Expanded(child: bookingsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.mrfRed)),
          error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.red))),
          data: (bookings) {
            final filtered = _filter == 'all' ? bookings : bookings.where((b) => b.status == _filter).toList();
            if (filtered.isEmpty) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(LucideIcons.wrench, size: 64, color: Colors.white24),
              const SizedBox(height: 16),
              Text('No bookings found', style: AppTextStyles.body1.copyWith(color: Colors.white70)),
            ]));
            return RefreshIndicator(color: AppColors.mrfRed, backgroundColor: AppColors.mrfBlack,
              onRefresh: () async => ref.refresh(allBookingsProvider),
              child: ListView.builder(padding: const EdgeInsets.all(16), itemCount: filtered.length,
                itemBuilder: (ctx, i) => _bookingCard(ctx, ref, filtered[i])));
          })),
      ])),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(children: ['all', 'pending', 'in_progress', 'completed', 'cancelled'].map((s) {
        final sel = _filter == s;
        return Padding(padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(label: Text(s.toUpperCase().replaceAll('_', ' ')), selected: sel,
            onSelected: (v) => setState(() => _filter = s),
            backgroundColor: AppColors.glassDark, selectedColor: AppColors.mrfRed.withValues(alpha: 0.2),
            labelStyle: TextStyle(color: sel ? AppColors.mrfRed : AppColors.adminTextTert, fontWeight: sel ? FontWeight.bold : FontWeight.normal, fontSize: 12),
            side: BorderSide(color: sel ? AppColors.mrfRed : Colors.transparent),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))));
      }).toList()));
  }

  Widget _bookingCard(BuildContext ctx, WidgetRef ref, BookingModel b) {
    final statusColor = _getStatusColor(b.status);
    return Padding(padding: const EdgeInsets.only(bottom: 12),
      child: LiquidGlassCard(isDark: true, borderRadius: 16, blurStrength: 10,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [
              const Icon(LucideIcons.ticket, color: Colors.white54, size: 16), const SizedBox(width: 8),
              Text('#${b.bookingId.substring(0, 8).toUpperCase()}', style: AppTextStyles.mono.copyWith(color: AppColors.adminTextPrimary)),
            ]),
            LiquidGlassStatusBadge(label: b.status.replaceAll('_', ' '), color: statusColor),
          ]),
          Divider(color: AppColors.glassDarkBorder, height: 20),
          _infoRow(LucideIcons.wrench, 'Service', b.serviceType),
          _infoRow(LucideIcons.calendar, 'Date', '${b.preferredDate.day}/${b.preferredDate.month}/${b.preferredDate.year} • ${b.preferredTimeSlot}'),
          if (b.assignedTechnician != null && b.assignedTechnician!.isNotEmpty) _infoRow(LucideIcons.hardHat, 'Technician', b.assignedTechnician!),
          if (b.adminNotes != null && b.adminNotes!.isNotEmpty) _infoRow(LucideIcons.fileText, 'Note', b.adminNotes!),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: LiquidGlassButton(label: 'MANAGE', icon: LucideIcons.edit3, variant: GlassButtonVariant.secondary, isDark: true, height: 40,
              onPressed: () => _showStatusSheet(ctx, ref, b))),
            const SizedBox(width: 8),
            GestureDetector(onTap: () => _confirmDelete(ctx, ref, b),
              child: Container(width: 44, height: 44, decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),
                color: Colors.red.withValues(alpha: 0.1), border: Border.all(color: Colors.red.withValues(alpha: 0.3))),
                child: const Icon(LucideIcons.trash2, color: Colors.redAccent, size: 18))),
          ]),
        ])));
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 16, color: AppColors.adminTextTert), const SizedBox(width: 12),
      SizedBox(width: 80, child: Text(label, style: AppTextStyles.body2.copyWith(color: AppColors.adminTextTert))),
      Expanded(child: Text(value, style: AppTextStyles.label1.copyWith(color: AppColors.adminTextPrimary))),
    ]));
  }

  Color _getStatusColor(String s) {
    switch (s) { case 'pending': return Colors.orangeAccent; case 'in_progress': return Colors.lightBlueAccent;
      case 'completed': return Colors.greenAccent; case 'cancelled': return Colors.redAccent; default: return Colors.grey; }
  }

  void _showStatusSheet(BuildContext ctx, WidgetRef ref, BookingModel b) {
    String selectedStatus = b.status;
    final notesC = TextEditingController(text: b.adminNotes ?? '');
    final techC = TextEditingController(text: b.assignedTechnician ?? '');
    showModalBottomSheet(context: ctx, isScrollControlled: true, backgroundColor: AppColors.glassDarkThick,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (c) => Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(c).viewInsets.bottom),
        child: StatefulBuilder(builder: (c, setModal) => Padding(padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.adminTextTert, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 24),
            Text('Manage Booking', style: AppTextStyles.h1.copyWith(color: Colors.white)),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(value: selectedStatus, dropdownColor: AppColors.glassDarkThick, style: TextStyle(color: AppColors.adminTextPrimary),
              decoration: InputDecoration(labelText: 'Status', labelStyle: TextStyle(color: AppColors.adminTextTert), filled: true, fillColor: AppColors.glassDark,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
              items: ['pending', 'in_progress', 'completed', 'cancelled'].map((s) => DropdownMenuItem(value: s, child: Text(s.toUpperCase().replaceAll('_', ' ')))).toList(),
              onChanged: (v) => setModal(() => selectedStatus = v!)),
            const SizedBox(height: 16),
            TextField(controller: techC, style: TextStyle(color: AppColors.adminTextPrimary),
              decoration: InputDecoration(labelText: 'Technician', labelStyle: TextStyle(color: AppColors.adminTextTert), prefixIcon: Icon(LucideIcons.hardHat, color: AppColors.adminTextTert),
                filled: true, fillColor: AppColors.glassDark, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
            const SizedBox(height: 16),
            TextField(controller: notesC, maxLines: 3, style: TextStyle(color: AppColors.adminTextPrimary),
              decoration: InputDecoration(labelText: 'Admin Notes', labelStyle: TextStyle(color: AppColors.adminTextTert),
                filled: true, fillColor: AppColors.glassDark, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
            const SizedBox(height: 24),
            LiquidGlassButton(label: 'SAVE CHANGES', isDark: true, onPressed: () async {
              await ref.read(bookingRepositoryProvider).updateBookingStatus(b.bookingId, selectedStatus,
                adminNotes: notesC.text.isNotEmpty ? notesC.text : null, technician: techC.text.isNotEmpty ? techC.text : null);
              if (c.mounted) Navigator.pop(c);
            }),
            const SizedBox(height: 16),
          ])))));
  }

  void _confirmDelete(BuildContext ctx, WidgetRef ref, BookingModel b) {
    showDialog(context: ctx, builder: (c) => AlertDialog(
      backgroundColor: AppColors.glassDarkThick, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Delete Booking', style: AppTextStyles.h2.copyWith(color: Colors.white)),
      content: Text('Remove #${b.bookingId.substring(0, 6).toUpperCase()} forever?', style: AppTextStyles.body1.copyWith(color: AppColors.adminTextSec)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c), child: Text('Cancel', style: TextStyle(color: AppColors.adminTextSec))),
        ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.mrfRed),
          onPressed: () async { await ref.read(bookingRepositoryProvider).deleteBooking(b.bookingId); if (c.mounted) Navigator.pop(c); },
          child: const Text('Delete', style: TextStyle(color: Colors.white))),
      ]));
  }
}
