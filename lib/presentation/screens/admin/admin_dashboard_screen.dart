import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../app/routes/app_routes.dart';
import '../../../domain/providers/auth_provider.dart';
import '../../../domain/providers/admin_provider.dart';
import '../../widgets/glass/admin_background.dart';
import '../../widgets/glass/liquid_glass_card.dart';
import '../../widgets/glass/liquid_glass_app_bar.dart';
import '../../widgets/glass/liquid_glass_kpi_card.dart';
import '../../widgets/glass/liquid_glass_status_badge.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).userModel;
    final stats = ref.watch(adminStatsProvider);

    return Scaffold(
      backgroundColor: AppColors.adminBg1,
      appBar: LiquidGlassAppBar(
        title: 'MRF Operations Console',
        isDark: true,
        centerTitle: false,
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withValues(alpha: 0.15),
          ),
          child: const Icon(LucideIcons.shieldAlert, size: 18, color: AppColors.primary),
        ),
        actions: [
          GestureDetector(
            onTap: () => _confirmLogout(context, ref),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
              ),
              child: const Icon(LucideIcons.logOut, size: 16, color: AppColors.adminTextPrimary),
            ),
          ),
          const Gap(12),
        ],
      ),
      body: AdminBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome header
              Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryDark],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'A',
                        style: AppTextStyles.h1.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                  const Gap(16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome, ${user?.name ?? 'Admin'}',
                          style: AppTextStyles.h1.copyWith(color: AppColors.adminTextPrimary),
                        ),
                        const Gap(4),
                        Row(
                          children: [
                            const LiquidGlassStatusBadge(label: 'Live Console', color: AppColors.success, glow: true),
                            const Gap(8),
                            Text('Master Operator', style: AppTextStyles.body2.copyWith(color: AppColors.adminTextSec)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 300.ms),
              const Gap(28),
              Text(
                'SYSTEM METRICS & KPI',
                style: AppTextStyles.labelCaps.copyWith(color: AppColors.adminTextTert, letterSpacing: 1.2),
              ),
              const Gap(14),
              _buildStatGrid(stats).animate().fadeIn(duration: 350.ms, delay: 100.ms),
              const Gap(32),
              Text(
                'MANAGEMENT ACTIONS',
                style: AppTextStyles.labelCaps.copyWith(color: AppColors.adminTextTert, letterSpacing: 1.2),
              ),
              const Gap(14),
              _tile(context, LucideIcons.boxes, 'Manage Inventory', 'Add, edit, or remove MRF products & casings', AppRoutes.adminInventory),
              const Gap(12),
              _tile(context, LucideIcons.wrench, 'Service Bookings', 'Review & process customer service jobs', AppRoutes.adminBookings),
              const Gap(12),
              _tile(context, LucideIcons.fileSpreadsheet, 'Customer Orders', 'Track fulfillment, dispatch & delivery', AppRoutes.adminOrders),
              const Gap(12),
              _tile(context, LucideIcons.toggleRight, 'Service Availability', 'Enable/disable services and slot caps', AppRoutes.adminServices),
              const Gap(12),
              _tile(context, LucideIcons.layoutGrid, 'Vehicle Categories', 'Configure tyre dimension & vehicle groupings', AppRoutes.adminCategories),
              const Gap(12),
              _tile(context, LucideIcons.settings, 'Business Settings', 'Operating hours, contacts & bank details', AppRoutes.adminSettings),
              const Gap(40),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.adminCardBase,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
        ),
        title: Text('Log Out', style: AppTextStyles.h2.copyWith(color: AppColors.adminTextPrimary)),
        content: Text(
          'Are you sure you want to end your admin operations session?',
          style: AppTextStyles.body1.copyWith(color: AppColors.adminTextSec),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancel', style: AppTextStyles.button.copyWith(color: AppColors.adminTextSec)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Log Out', style: AppTextStyles.button.copyWith(color: AppColors.primary)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(authProvider.notifier).logout();
      if (context.mounted) context.go(AppRoutes.login);
    }
  }

  Widget _buildStatGrid(Map<String, dynamic> stats) {
    final codOutstanding = (stats['codOutstanding'] as double?) ?? 0.0;
    final codCount = (stats['codPendingCount'] as int?) ?? 0;

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 0.95,
      children: [
        LiquidGlassKpiCard(
          title: 'Total Revenue',
          value: '₹${stats['revenue'] ?? 0}',
          icon: LucideIcons.wallet,
          accentColor: AppColors.warning,
          isDark: true,
        ),
        LiquidGlassKpiCard(
          title: 'Pending Bookings',
          value: '${stats['pendingBookings'] ?? 0}',
          icon: LucideIcons.calendarClock,
          accentColor: const Color(0xFF3498DB),
          isDark: true,
        ),
        LiquidGlassKpiCard(
          title: 'Active Jobs',
          value: '${stats['activeRetreads'] ?? 0}',
          icon: LucideIcons.hardHat,
          accentColor: AppColors.success,
          isDark: true,
        ),
        LiquidGlassKpiCard(
          title: 'Low Stock Alert',
          value: '${stats['lowStock'] ?? 0}',
          icon: LucideIcons.alertTriangle,
          accentColor: AppColors.primary,
          isDark: true,
        ),
        LiquidGlassKpiCard(
          title: 'COD Due',
          value: '₹${codOutstanding.toStringAsFixed(0)}',
          subtitle: '$codCount pending',
          icon: LucideIcons.banknote,
          accentColor: AppColors.secondary,
          isDark: true,
        ),
      ],
    );
  }

  Widget _tile(BuildContext context, IconData icon, String title, String sub, String route) {
    return LiquidGlassCard(
      isDark: true,
      onTap: () => context.push(route),
      borderRadius: 22,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: AppColors.primary.withValues(alpha: 0.15),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.h3.copyWith(color: AppColors.adminTextPrimary, fontWeight: FontWeight.w600)),
                const Gap(4),
                Text(sub, style: AppTextStyles.body2.copyWith(color: AppColors.adminTextSec)),
              ],
            ),
          ),
          const Icon(LucideIcons.chevronRight, color: AppColors.adminTextTert, size: 20),
        ],
      ),
    );
  }
}
