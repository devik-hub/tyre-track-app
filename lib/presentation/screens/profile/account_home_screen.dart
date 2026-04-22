import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/routes/app_routes.dart';
import '../../../domain/providers/auth_provider.dart';
import '../../../domain/providers/booking_provider.dart';

class AccountHomeScreen extends ConsumerWidget {
  const AccountHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).userModel;

    return Scaffold(
      appBar: AppBar(title: const Text('My Account')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              color: AppColors.mrfWhite,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.mrfLightGrey,
                    child: Text(
                      user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'U',
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.mrfRed),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(user?.name ?? 'User', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  if (user?.email.isNotEmpty == true)
                    Text(user!.email, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(user?.phone.isNotEmpty == true ? user!.phone : 'No phone added', style: TextStyle(color: user?.phone.isNotEmpty == true ? Colors.grey : AppColors.mrfOrange)),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => _showEditProfile(context, ref, user),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Edit Profile'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (user?.role == 'admin') ...[
              _buildListTile(context, Icons.admin_panel_settings, 'Admin Dashboard', () => context.push(AppRoutes.admin)),
              const Divider(),
            ],
            _buildListTile(context, Icons.history, 'Order History', () => context.push(AppRoutes.orders)),
            _buildListTile(context, Icons.build_outlined, 'Service History', () => _showServiceHistory(context, ref)),
            _buildListTile(context, Icons.notifications_none, 'Notifications', () => context.push(AppRoutes.notifications)),
            _buildListTile(context, Icons.headset_mic_outlined, 'Help & Support', () => context.push(AppRoutes.help)),
            _buildListTile(context, Icons.info_outline, 'About Us', () => context.push(AppRoutes.about)),
            _buildListTile(context, Icons.phone, 'Contact Us', () => context.push(AppRoutes.contact)),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.mrfRed),
              title: const Text('Logout', style: TextStyle(color: AppColors.mrfRed, fontWeight: FontWeight.bold)),
              onTap: () async {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) context.go(AppRoutes.roleSelect);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return Container(
      color: AppColors.mrfWhite,
      child: ListTile(
        leading: Icon(icon, color: AppColors.mrfMidGrey),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  void _showEditProfile(BuildContext context, WidgetRef ref, dynamic user) {
    final nameC = TextEditingController(text: user?.name ?? '');
    final phoneC = TextEditingController(text: user?.phone ?? '');
    final emailC = TextEditingController(text: user?.email ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameC, decoration: const InputDecoration(labelText: 'Full Name')),
            const SizedBox(height: 8),
            TextField(controller: phoneC, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Phone Number', prefixText: '+91 ')),
            const SizedBox(height: 8),
            TextField(controller: emailC, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await ref.read(authProvider.notifier).registerUser(
                nameC.text.trim(),
                phoneC.text.trim().isNotEmpty ? (phoneC.text.startsWith('+91') ? phoneC.text.trim() : '+91${phoneC.text.trim()}') : '',
                emailC.text.trim(),
              );
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showServiceHistory(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (ctx, scrollController) {
          return Consumer(
            builder: (ctx, ref, _) {
              final bookingsAsync = ref.watch(userBookingsProvider);
              return Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Service History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  Expanded(
                    child: bookingsAsync.when(
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Center(child: Text('Error: $e')),
                      data: (bookings) {
                        if (bookings.isEmpty) {
                          return const Center(child: Text('No service bookings yet', style: TextStyle(color: Colors.grey)));
                        }
                        return ListView.builder(
                          controller: scrollController,
                          itemCount: bookings.length,
                          itemBuilder: (ctx, i) {
                            final b = bookings[i];
                            return ListTile(
                              leading: Icon(Icons.build, color: b.status == 'completed' ? Colors.green : Colors.orange),
                              title: Text(b.serviceType, style: const TextStyle(fontWeight: FontWeight.w600)),
                              subtitle: Text('${b.preferredDate.day}/${b.preferredDate.month}/${b.preferredDate.year} • ${b.status}'),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: b.status == 'completed' ? Colors.green.shade100 : Colors.orange.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(b.status.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold,
                                    color: b.status == 'completed' ? Colors.green : Colors.orange)),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
