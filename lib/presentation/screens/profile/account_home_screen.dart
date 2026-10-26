import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../app/theme/clay_decorations.dart';
import '../../../app/routes/app_routes.dart';
import '../../../domain/providers/auth_provider.dart';
import '../../../domain/providers/booking_provider.dart';
import '../../widgets/glass/customer_background.dart';
import '../../widgets/glass/liquid_glass_card.dart';
import '../../widgets/glass/liquid_glass_app_bar.dart';
import '../../widgets/glass/liquid_glass_button.dart';
import '../../widgets/glass/liquid_glass_status_badge.dart';
import '../../widgets/glass/liquid_glass_sheet.dart';

class AccountHomeScreen extends ConsumerWidget {
  const AccountHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).userModel;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const LiquidGlassAppBar(
        title: 'My Profile',
        showBrandSubtitle: true,
      ),
      body: CustomerBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              // Profile clay feature card
              LiquidGlassCard(
                redAccent: true,
                borderRadius: 28,
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.primary, AppColors.primaryDark],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.35),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(-2, -2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'U',
                          style: AppTextStyles.display1.copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                    const Gap(14),
                    Text(
                      user?.name ?? 'Valued Customer',
                      style: AppTextStyles.h1.copyWith(color: AppColors.textPrimary),
                    ),
                    const Gap(4),
                    if (user?.email.isNotEmpty == true)
                      Text(user!.email, style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary)),
                    const Gap(4),
                    Text(
                      user?.phone.isNotEmpty == true ? user!.phone : 'No phone linked',
                      style: AppTextStyles.body2.copyWith(
                        color: user?.phone.isNotEmpty == true ? AppColors.textSecondary : AppColors.warning,
                      ),
                    ),
                    const Gap(16),
                    SizedBox(
                      width: 160,
                      child: LiquidGlassButton(
                        label: 'Edit Profile',
                        icon: LucideIcons.edit3,
                        variant: GlassButtonVariant.secondary,
                        height: 42,
                        onPressed: () => _showEditProfile(context, ref, user),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0),
              const Gap(16),
              // Menu items
              if (user?.role == 'admin')
                _menuItem(context, LucideIcons.shieldAlert, 'Admin Dashboard', () => context.push(AppRoutes.admin), isSpecial: true),
              _menuItem(context, LucideIcons.packageCheck, 'My Orders', () => context.push(AppRoutes.orders)),
              _menuItem(context, LucideIcons.wrench, 'Service Bookings', () => _showServiceHistory(context, ref)),
              _menuItem(context, LucideIcons.truck, 'My Vehicles', () => context.push(AppRoutes.vehicles)),
              _menuItem(context, LucideIcons.bell, 'Notifications', () => context.push(AppRoutes.notifications)),
              _menuItem(context, LucideIcons.helpCircle, 'Help & Support', () => context.push(AppRoutes.help)),
              _menuItem(context, LucideIcons.info, 'About Jagadale Retreads', () => context.push(AppRoutes.about)),
              _menuItem(context, LucideIcons.phone, 'Contact & Locations', () => context.push(AppRoutes.contact)),
              const Gap(8),
              // Logout item
              LiquidGlassCard(
                onTap: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      title: Text('Log Out', style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary)),
                      content: Text(
                        'Are you sure you want to log out of your account?',
                        style: AppTextStyles.body1.copyWith(color: AppColors.textSecondary),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: Text('Cancel', style: AppTextStyles.button.copyWith(color: AppColors.textSecondary)),
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
                    if (context.mounted) context.go(AppRoutes.roleSelect);
                  }
                },
                borderRadius: 20,
                redAccent: true,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(LucideIcons.logOut, color: AppColors.primary, size: 20),
                    ),
                    const Gap(14),
                    Text(
                      'Logout',
                      style: AppTextStyles.label1.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 350.ms, delay: 200.ms),
              const Gap(32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuItem(BuildContext ctx, IconData icon, String title, VoidCallback onTap, {bool isSpecial = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: LiquidGlassCard(
        onTap: onTap,
        borderRadius: 20,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (isSpecial ? AppColors.primary : AppColors.surface),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSpecial ? AppColors.primary : const Color(0xFFE8DCDC),
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                color: isSpecial ? Colors.white : AppColors.primary,
                size: 20,
              ),
            ),
            const Gap(14),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.label1.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(LucideIcons.chevronRight, color: AppColors.textSecondary, size: 18),
          ],
        ),
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
        backgroundColor: AppColors.cardBase,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text('Edit Profile', style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameC,
              style: AppTextStyles.bodyMedium,
              decoration: ClayDecorations.inputDecoration(
                labelText: 'Full Name',
                prefixIcon: const Icon(LucideIcons.user, size: 18, color: AppColors.primary),
              ),
            ),
            const Gap(12),
            TextField(
              controller: phoneC,
              keyboardType: TextInputType.phone,
              style: AppTextStyles.bodyMedium,
              decoration: ClayDecorations.inputDecoration(
                labelText: 'Phone',
                prefixIcon: const Icon(LucideIcons.phone, size: 18, color: AppColors.primary),
              ),
            ),
            const Gap(12),
            TextField(
              controller: emailC,
              keyboardType: TextInputType.emailAddress,
              style: AppTextStyles.bodyMedium,
              decoration: ClayDecorations.inputDecoration(
                labelText: 'Email',
                prefixIcon: const Icon(LucideIcons.mail, size: 18, color: AppColors.primary),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: AppTextStyles.label1.copyWith(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () async {
              await ref.read(authProvider.notifier).registerUser(
                    nameC.text.trim(),
                    phoneC.text.trim().isNotEmpty
                        ? (phoneC.text.startsWith('+91') ? phoneC.text.trim() : '+91${phoneC.text.trim()}')
                        : '',
                    emailC.text.trim(),
                  );
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: Text('Save', style: AppTextStyles.label1.copyWith(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showServiceHistory(BuildContext context, WidgetRef ref) {
    showLiquidGlassSheet(
      context,
      child: Consumer(
        builder: (ctx, ref, _) {
          final bookingsAsync = ref.watch(userBookingsProvider);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Service History', style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary)),
              const Gap(16),
              bookingsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                error: (e, _) => Text('Error: $e', style: AppTextStyles.body2.copyWith(color: AppColors.error)),
                data: (bookings) {
                  if (bookings.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(
                          'No service bookings yet',
                          style: AppTextStyles.body1.copyWith(color: AppColors.textTertiary),
                        ),
                      ),
                    );
                  }
                  return Column(
                    children: bookings.map((b) {
                      final isCompleted = b.status == 'completed';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: LiquidGlassCard(
                          borderRadius: 20,
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: (isCompleted ? AppColors.success : AppColors.warning).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  LucideIcons.wrench,
                                  color: isCompleted ? AppColors.success : AppColors.warning,
                                  size: 20,
                                ),
                              ),
                              const Gap(14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      b.serviceType,
                                      style: AppTextStyles.label1.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                                    ),
                                    const Gap(2),
                                    Text(
                                      '${b.preferredDate.day}/${b.preferredDate.month}/${b.preferredDate.year}',
                                      style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                              LiquidGlassStatusBadge(
                                label: b.status,
                                color: isCompleted ? AppColors.success : AppColors.warning,
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
