import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/routes/app_routes.dart';
import '../../../domain/providers/auth_provider.dart';
import '../../../domain/providers/admin_provider.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).userModel;
    final stats = ref.watch(adminStatsProvider);

    return Scaffold(
      backgroundColor: AppColors.mrfBlack,
      appBar: AppBar(
        title: const Text('MRF Operations Command', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white, letterSpacing: 1.2)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white), 
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go(AppRoutes.login);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.mrfRed,
                  child: Text(user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'A', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Welcome back, ${user?.name ?? 'Admin'}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4)),
                          child: const Text('Live Sync Active', style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 8),
                        Text('Role: Administrator', style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text('OVERVIEW', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.grey)),
            const SizedBox(height: 16),
            _buildStatGrid(stats),
            const SizedBox(height: 32),
            const Text('QUICK ACTIONS', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.grey)),
            const SizedBox(height: 16),
            _buildActionTile(context, Icons.inventory_2_rounded, 'Manage Inventory', 'Add, edit, or remove MRF products from the mobile catalog', AppRoutes.adminInventory),
            const SizedBox(height: 16),
            _buildActionTile(context, Icons.build_rounded, 'Service Bookings', 'Process and assign technicians to customer service requests', AppRoutes.adminBookings),
            const SizedBox(height: 16),
            _buildActionTile(context, Icons.receipt_long_rounded, 'Customer Orders', 'Track fulfillment and dispatch new tyre orders', AppRoutes.adminOrders),
            const SizedBox(height: 16),
            _buildActionTile(context, Icons.settings_rounded, 'Settings', 'Update business info, hours, and contact details', AppRoutes.adminSettings),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatGrid(Map<String, dynamic> stats) {
    final codOutstanding = (stats['codOutstanding'] as double?) ?? 0.0;
    final codCount       = (stats['codPendingCount'] as int?) ?? 0;

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.3,
      children: [
        _buildGradientStatCard('Total Revenue', '₹${stats['revenue'] ?? 0}', [Colors.orange.shade800, Colors.deepOrange.shade600], Icons.account_balance_wallet_rounded),
        _buildGradientStatCard('Pending Bookings', '${stats['pendingBookings'] ?? 0}', [Colors.blue.shade800, Colors.blue.shade600], Icons.pending_actions_rounded),
        _buildGradientStatCard('Active Jobs', '${stats['activeRetreads'] ?? 0}', [Colors.green.shade800, Colors.green.shade600], Icons.engineering_rounded),
        _buildGradientStatCard('Low Stock Alerts', '${stats['lowStockCount'] ?? 0}', [const Color(0xFFC62828), AppColors.mrfRed], Icons.warning_rounded),
        _buildGradientStatCard('COD Due', '₹${codOutstanding.toStringAsFixed(0)}\n$codCount orders', [Colors.amber.shade800, Colors.amber.shade600], Icons.payments_rounded),
      ],
    );
  }

  Widget _buildGradientStatCard(String title, String value, List<Color> gradientColors, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradientColors, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: gradientColors.last.withValues(alpha: 0.4), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: Colors.white70, size: 28),
              const Icon(Icons.arrow_outward_rounded, color: Colors.white30, size: 20),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 4),
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(BuildContext context, IconData icon, String title, String subtitle, String route) {
    return InkWell(
      onTap: () => context.push(route),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
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
              child: Icon(icon, color: AppColors.mrfRed, size: 28),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
                  const SizedBox(height: 6),
                  Text(subtitle, style: TextStyle(color: Colors.grey.shade400, fontSize: 12, height: 1.4)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white30),
          ],
        ),
      ),
    );
  }
}
