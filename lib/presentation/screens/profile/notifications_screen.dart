import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../domain/providers/notification_provider.dart';
import '../../../data/repositories/notification_repository.dart';
import '../../widgets/glass/liquid_glass_card.dart';
import '../../widgets/glass/liquid_glass_app_bar.dart';
import '../../widgets/glass/customer_background.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationStream = ref.watch(notificationProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomerBackground(
        child: Column(
          children: [
            const LiquidGlassAppBar(
              title: 'Notifications',
              showBrandSubtitle: true,
            ),
            Expanded(
              child: notificationStream.when(
                data: (notifications) {
                  if (notifications.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.92),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.12),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: const Icon(LucideIcons.bellOff, size: 36, color: AppColors.textTertiary),
                          ),
                          const Gap(16),
                          Text('No notifications yet', style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary)),
                          const Gap(6),
                          Text(
                            'Status updates on orders and bookings will appear here.',
                            style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    itemCount: notifications.length,
                    itemBuilder: (ctx, i) {
                      final notif = notifications[i];
                      final isUnread = !notif.isRead;
                      final isAlert = notif.type == 'alert';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: LiquidGlassCard(
                          onTap: () {
                            if (isUnread) ref.read(notificationRepositoryProvider).markAsRead(notif.notifId);
                          },
                          borderRadius: 20,
                          redAccent: isUnread,
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: (isAlert ? AppColors.warning : AppColors.primary).withValues(alpha: 0.15),
                                  border: Border.all(
                                    color: (isAlert ? AppColors.warning : AppColors.primary).withValues(alpha: 0.25),
                                  ),
                                ),
                                child: Icon(
                                  isAlert ? LucideIcons.alertTriangle : LucideIcons.bell,
                                  color: isAlert ? AppColors.warning : AppColors.primary,
                                  size: 20,
                                ),
                              ),
                              const Gap(14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      notif.title,
                                      style: AppTextStyles.label1.copyWith(
                                        color: AppColors.textPrimary,
                                        fontWeight: isUnread ? FontWeight.w700 : FontWeight.w500,
                                      ),
                                    ),
                                    const Gap(4),
                                    Text(
                                      notif.body,
                                      style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const Gap(8),
                              Text(
                                _formatRelativeTime(notif.createdAt),
                                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiary),
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(duration: 250.ms, delay: (i * 40).ms).slideY(begin: 0.05, end: 0);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                error: (e, s) => Center(child: Text('Error: $e', style: AppTextStyles.body2.copyWith(color: AppColors.error))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatRelativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
