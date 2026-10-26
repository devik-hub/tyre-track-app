import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../domain/providers/order_provider.dart';
import '../../widgets/glass/liquid_glass_card.dart';
import '../../widgets/glass/liquid_glass_app_bar.dart';
import '../../widgets/glass/liquid_glass_status_badge.dart';
import '../../widgets/glass/customer_background.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(userOrdersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomerBackground(
        child: Column(
          children: [
            const LiquidGlassAppBar(
              title: 'Order History',
              showBrandSubtitle: true,
            ),
            Expanded(
              child: ordersAsync.when(
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                error: (e, _) => Center(
                  child: Text('Error: $e', style: AppTextStyles.body1.copyWith(color: AppColors.error)),
                ),
                data: (orders) {
                  if (orders.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 88,
                            height: 88,
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
                            child: const Icon(LucideIcons.packageSearch, size: 40, color: AppColors.textTertiary),
                          ),
                          const Gap(18),
                          Text('No Orders Yet', style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary)),
                          const Gap(8),
                          Text(
                            'Your tyre purchase and order history will appear here.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    itemCount: orders.length,
                    itemBuilder: (ctx, i) {
                      final order = orders[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: LiquidGlassCard(
                          onTap: () => context.push(AppRoutes.orderTracker, extra: order.orderId),
                          borderRadius: 24,
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(LucideIcons.hash, size: 16, color: AppColors.primary),
                                      const Gap(4),
                                      Text(
                                        order.orderId.substring(0, 8).toUpperCase(),
                                        style: AppTextStyles.mono.copyWith(
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  LiquidGlassStatusBadge(
                                    label: order.orderStatus.replaceAll('_', ' ').toUpperCase(),
                                    color: _statusColor(order.orderStatus),
                                  ),
                                ],
                              ),
                              const Divider(color: Color(0xFFE8DCDC), height: 24),
                              ...order.items.map(
                                (item) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      const Icon(LucideIcons.disc, size: 16, color: AppColors.primary),
                                      const Gap(10),
                                      Expanded(
                                        child: Text(
                                          '${item.productName.isNotEmpty ? item.productName : 'Tyre Product'} ×${item.quantity}',
                                          style: AppTextStyles.body2.copyWith(color: AppColors.textPrimary),
                                        ),
                                      ),
                                      Text(
                                        '₹${item.totalPriceRupees.toStringAsFixed(0)}',
                                        style: AppTextStyles.label1.copyWith(
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const Divider(color: Color(0xFFE8DCDC), height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}',
                                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                                  ),
                                  Text(
                                    '₹${order.finalAmountRupees.toStringAsFixed(0)}',
                                    style: AppTextStyles.h2.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                              const Gap(10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text('Payment: ', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                                      LiquidGlassStatusBadge(
                                        label: order.paymentStatus.toUpperCase(),
                                        color: order.paymentStatus == 'paid' || order.paymentStatus == 'collected'
                                            ? AppColors.success
                                            : AppColors.warning,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        'Track Order',
                                        style: AppTextStyles.label2.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
                                      ),
                                      const Gap(4),
                                      const Icon(LucideIcons.chevronRight, size: 14, color: AppColors.primary),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(duration: 300.ms, delay: (i * 60).ms).slideY(begin: 0.05, end: 0);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending_confirmation':
        return AppColors.warning;
      case 'confirmed':
      case 'processing':
      case 'shipped':
        return const Color(0xFF2980B9);
      case 'delivered':
        return AppColors.success;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }
}
