import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../domain/providers/auth_provider.dart';

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
                  const SizedBox(height: 8),
                  Text(user?.phone ?? '+91 XXXXX XXXXX', style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (user?.role == 'admin') ...[
              _buildListTile(context, Icons.admin_panel_settings, 'Admin Dashboard', () => context.push('/admin')),
              const Divider(),
            ],
            _buildListTile(context, Icons.directions_car_outlined, 'My Vehicles', () => context.push('/vehicles')),
            _buildListTile(context, Icons.history, 'Order History', () => context.push('/orders')),
            _buildListTile(context, Icons.build_outlined, 'Service History', () {}),
            _buildListTile(context, Icons.notifications_none, 'Notification Preferences', () => context.push('/notifications')),
            _buildListTile(context, Icons.language, 'Language Settings', () {}),
            _buildListTile(context, Icons.headset_mic_outlined, 'Help & Support', () => context.push('/help')),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.mrfRed),
              title: const Text('Logout', style: TextStyle(color: AppColors.mrfRed, fontWeight: FontWeight.bold)),
              onTap: () async {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) context.go('/login');
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
}
