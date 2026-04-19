import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../domain/providers/auth_provider.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).userModel;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.mrfBlack,
        actions: [
          IconButton(icon: const Icon(Icons.exit_to_app), onPressed: () => context.go('/home')),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Welcome, ${user?.name ?? 'Admin'}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            _buildStatGrid(),
            const SizedBox(height: 32),
            const Text('Management Modules', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildAdminMenuCard(context, Icons.inventory, 'Manage Inventory', 'Add/Edit MRF Tyres and Pricing', '/admin/inventory'),
            _buildAdminMenuCard(context, Icons.build, 'Service Bookings', 'Update retreading queue statuses', '/admin/bookings'),
            _buildAdminMenuCard(context, Icons.shopping_bag, 'Customer Orders', 'Track shipping and delivery statuses', '/admin/orders'),
            _buildAdminMenuCard(context, Icons.campaign, 'Push Notifications', 'Send promotional alerts to App Users', '/admin/push'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard('Pending Bookings', '12', Icons.pending_actions, AppColors.mrfOrange),
        _buildStatCard('Active Retreads', '34', Icons.handyman, AppColors.mrfRed),
        _buildStatCard('Daily Revenue', '₹24k', Icons.currency_rupee, AppColors.mrfGreen),
        _buildStatCard('Low Stock Tyres', '8', Icons.warning, AppColors.mrfBlack),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: color),
            const SizedBox(height: 12),
            Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminMenuCard(BuildContext context, IconData icon, String title, String subtitle, String route) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: AppColors.mrfLightGrey,
          radius: 24,
          child: Icon(icon, color: AppColors.mrfBlack),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => context.push(route),
      ),
    );
  }
}
