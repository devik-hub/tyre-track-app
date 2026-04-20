import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../data/models/booking_model.dart';
import '../../../data/repositories/booking_repository.dart';
import '../../../domain/providers/booking_provider.dart';

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

    return Scaffold(
      backgroundColor: AppColors.mrfBlack,
      appBar: AppBar(
        title: const Text('Service Bookings', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: bookingsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.mrfRed)),
              error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.red))),
              data: (bookings) {
                final filteredBookings = _filter == 'all' ? bookings : bookings.where((b) => b.status == _filter).toList();
                
                if (filteredBookings.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.build_circle_outlined, size: 64, color: Colors.white24),
                        SizedBox(height: 16),
                        Text('No bookings found', style: TextStyle(fontSize: 18, color: Colors.white70)),
                      ],
                    ),
                  );
                }
                
                return RefreshIndicator(
                  color: AppColors.mrfRed,
                  backgroundColor: AppColors.mrfBlack,
                  onRefresh: () async => ref.refresh(allBookingsProvider),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredBookings.length,
                    itemBuilder: (context, index) => _buildBookingCard(context, ref, filteredBookings[index]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: ['all', 'pending', 'in_progress', 'completed', 'cancelled'].map((status) {
          final isSelected = _filter == status;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(status.toUpperCase().replaceAll('_', ' ')),
              selected: isSelected,
              onSelected: (val) => setState(() => _filter = status),
              backgroundColor: const Color(0xFF2C2C2C),
              selectedColor: AppColors.mrfRed.withValues(alpha: 0.2),
              labelStyle: TextStyle(
                color: isSelected ? AppColors.mrfRed : Colors.grey.shade500,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12
              ),
              side: BorderSide(color: isSelected ? AppColors.mrfRed : Colors.transparent),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBookingCard(BuildContext context, WidgetRef ref, BookingModel booking) {
    final statusColor = _getStatusColor(booking.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.confirmation_number_outlined, color: Colors.white54, size: 16),
                    const SizedBox(width: 8),
                    Text('#${booking.bookingId.substring(0, 8).toUpperCase()}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13, letterSpacing: 1)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12), border: Border.all(color: statusColor.withValues(alpha: 0.5))),
                  child: Text(booking.status.toUpperCase().replaceAll('_', ' '), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor, letterSpacing: 0.5)),
                ),
              ],
            ),
            const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1, color: Colors.white10)),
            _infoRow(Icons.build, 'Service', booking.serviceType),
            _infoRow(Icons.calendar_today, 'Date', '${booking.preferredDate.day}/${booking.preferredDate.month}/${booking.preferredDate.year} • ${booking.preferredTimeSlot}'),
            if (booking.assignedTechnician != null && booking.assignedTechnician!.isNotEmpty)
              _infoRow(Icons.engineering, 'Technician', booking.assignedTechnician!),
            if (booking.adminNotes != null && booking.adminNotes!.isNotEmpty)
              _infoRow(Icons.note_alt, 'Admin Note', booking.adminNotes!),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2C2C2C),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () => _showStatusBottomSheet(context, ref, booking),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('MANAGE STATUS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _confirmDelete(context, ref, booking),
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  style: IconButton.styleFrom(backgroundColor: Colors.red.withValues(alpha: 0.1), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          SizedBox(width: 80, child: Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 13))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: Colors.white))),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return Colors.orangeAccent;
      case 'in_progress': return Colors.lightBlueAccent;
      case 'completed': return Colors.greenAccent;
      case 'cancelled': return Colors.redAccent;
      default: return Colors.grey;
    }
  }

  void _showStatusBottomSheet(BuildContext context, WidgetRef ref, BookingModel booking) {
    String selectedStatus = booking.status;
    final notesC = TextEditingController(text: booking.adminNotes ?? '');
    final techC = TextEditingController(text: booking.assignedTechnician ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: StatefulBuilder(
          builder: (ctx, setModalState) => Container(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade600, borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 24),
                const Text('Manage Booking', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 24),
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  dropdownColor: const Color(0xFF2C2C2C),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Current Status',
                    labelStyle: TextStyle(color: Colors.grey.shade500),
                    filled: true,
                    fillColor: const Color(0xFF2C2C2C),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  items: ['pending', 'in_progress', 'completed', 'cancelled']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s.toUpperCase().replaceAll('_', ' '))))
                      .toList(),
                  onChanged: (v) => setModalState(() => selectedStatus = v!),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: techC,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Assigned Technician',
                    labelStyle: TextStyle(color: Colors.grey.shade500),
                    prefixIcon: Icon(Icons.engineering, color: Colors.grey.shade600),
                    filled: true,
                    fillColor: const Color(0xFF2C2C2C),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  )
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesC,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Internal Admin Notes',
                    labelStyle: TextStyle(color: Colors.grey.shade500),
                    filled: true,
                    fillColor: const Color(0xFF2C2C2C),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  )
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mrfRed,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                  ),
                  onPressed: () async {
                    await ref.read(bookingRepositoryProvider).updateBookingStatus(
                      booking.bookingId,
                      selectedStatus,
                      adminNotes: notesC.text.isNotEmpty ? notesC.text : null,
                      technician: techC.text.isNotEmpty ? techC.text : null,
                    );
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: const Text('SAVE CHANGES', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, BookingModel booking) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        title: const Text('Delete Booking', style: TextStyle(color: Colors.white)),
        content: Text('Remove booking #${booking.bookingId.substring(0, 6).toUpperCase()} forever?', style: TextStyle(color: Colors.grey.shade400)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Colors.white70))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.mrfRed),
            onPressed: () async {
              await ref.read(bookingRepositoryProvider).deleteBooking(booking.bookingId);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
