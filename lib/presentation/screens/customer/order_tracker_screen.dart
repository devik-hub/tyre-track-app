import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../app/routes/app_routes.dart';
import '../../../data/models/order_model.dart';
import '../../../domain/providers/customer_order_providers.dart';
import '../../widgets/glass/liquid_glass_card.dart';
import '../../widgets/glass/liquid_glass_app_bar.dart';
import '../../widgets/glass/liquid_glass_button.dart';
import '../../widgets/glass/customer_background.dart';

class OrderTrackerScreen extends ConsumerWidget {
  final String orderId;
  const OrderTrackerScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(customerOrderDetailProvider(orderId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomerBackground(
        child: Column(
          children: [
            LiquidGlassAppBar(
              title: 'Order #${orderId.length >= 8 ? orderId.substring(0, 8).toUpperCase() : orderId}',
              showBrandSubtitle: true,
            ),
            Expanded(
              child: orderAsync.when(
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                error: (e, _) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(LucideIcons.alertTriangle, color: AppColors.error, size: 56),
                      const Gap(16),
                      Text('Unable to load order', style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary)),
                      const Gap(8),
                      Text(e.toString(), textAlign: TextAlign.center, style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary)),
                      const Gap(24),
                      LiquidGlassButton(
                        label: 'Go Back',
                        variant: GlassButtonVariant.secondary,
                        onPressed: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go(AppRoutes.orders);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                data: (order) {
                  if (order == null) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(LucideIcons.package, size: 64, color: AppColors.textTertiary),
                          const Gap(16),
                          Text('Order not found', style: AppTextStyles.h2.copyWith(color: AppColors.textSecondary)),
                          const Gap(16),
                          LiquidGlassButton(
                            label: 'Go Back',
                            variant: GlassButtonVariant.secondary,
                            onPressed: () {
                              if (context.canPop()) {
                                context.pop();
                              } else {
                                context.go(AppRoutes.orders);
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  }
                  return _OrderTrackerBody(order: order);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderTrackerBody extends StatelessWidget {
  final OrderModel order;
  const _OrderTrackerBody({required this.order});

  static const _statusSteps = ['pending_confirmation', 'confirmed', 'processing', 'shipped', 'delivered'];

  @override
  Widget build(BuildContext context) {
    final currentStep = _statusSteps.indexOf(order.orderStatus);
    final isCancelled = order.orderStatus == 'cancelled';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Live indicator
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                  ),
                  const Gap(8),
                  Text('LIVE TRACKING ACTIVE', style: AppTextStyles.labelCaps.copyWith(color: AppColors.success)),
                ],
              ),
            ),
          ),
          const Gap(20),

          if (!isCancelled) ...[
            Text('Order Timeline', style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary)),
            const Gap(16),
            ..._statusSteps.asMap().entries.map((entry) {
              final idx = entry.key;
              final status = entry.value;
              return _TimelineStep(
                label: status.replaceAll('_', ' ').toUpperCase(),
                subtitle: _stepSubtitle(status, order),
                done: currentStep >= idx,
                isCurrent: currentStep == idx,
                isLast: idx == _statusSteps.length - 1,
              );
            }),
          ] else ...[
            LiquidGlassCard(
              borderRadius: 20,
              redAccent: true,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(LucideIcons.xCircle, color: AppColors.error, size: 28),
                  const Gap(14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Order Cancelled', style: AppTextStyles.h3.copyWith(color: AppColors.error)),
                      if (order.cancelledAt != null)
                        Text('On ${_date(order.cancelledAt!)}', style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),
          ],
          const Gap(24),

          _infoCard('Payment Details', [
            _infoRow('Method', order.paymentMethod == 'cod' ? 'Cash on Delivery' : 'Online / UPI Payment'),
            _infoRow('Status', order.paymentStatus.toUpperCase()),
            _infoRow('Total Payable', '₹${order.finalAmountRupees.toStringAsFixed(0)}'),
          ]),
          const Gap(16),
          _infoCard('Order Items', [
            ...order.items.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Icon(LucideIcons.disc, size: 16, color: AppColors.primary),
                    const Gap(10),
                    Expanded(
                      child: Text(
                        '${item.productName.isNotEmpty ? item.productName : 'Item'} × ${item.quantity}',
                        style: AppTextStyles.body2.copyWith(color: AppColors.textPrimary),
                      ),
                    ),
                    Text(
                      '₹${item.totalPriceRupees.toStringAsFixed(0)}',
                      style: AppTextStyles.label1.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ]),
          const Gap(32),
        ],
      ),
    );
  }

  Widget _infoCard(String title, List<Widget> children) => LiquidGlassCard(
        borderRadius: 22,
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary)),
            const Divider(color: Color(0xFFE8DCDC), height: 20),
            ...children,
          ],
        ),
      );

  Widget _infoRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary)),
            Text(value, style: AppTextStyles.label1.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
          ],
        ),
      );

  String _stepSubtitle(String status, OrderModel order) {
    switch (status) {
      case 'pending_confirmation':
        return _date(order.createdAt);
      case 'confirmed':
        return order.confirmedAt != null ? _date(order.confirmedAt!) : '';
      case 'shipped':
        return order.shippedAt != null ? _date(order.shippedAt!) : '';
      case 'delivered':
        return order.deliveredAt != null ? _date(order.deliveredAt!) : '';
      default:
        return '';
    }
  }

  String _date(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

class _TimelineStep extends StatelessWidget {
  final String label, subtitle;
  final bool done, isCurrent, isLast;
  const _TimelineStep({
    required this.label,
    required this.subtitle,
    required this.done,
    required this.isCurrent,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done ? AppColors.primary : Colors.white,
                border: Border.all(
                  color: isCurrent ? AppColors.primary : const Color(0xFFE8DCDC),
                  width: isCurrent ? 2.5 : 1.5,
                ),
                boxShadow: isCurrent
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                done ? LucideIcons.check : LucideIcons.circle,
                size: 14,
                color: done ? Colors.white : AppColors.textTertiary,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 36,
                color: done ? AppColors.primary.withValues(alpha: 0.4) : const Color(0xFFE8DCDC),
              ),
          ],
        ),
        const Gap(14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.label1.copyWith(
                    fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                    color: done ? AppColors.textPrimary : AppColors.textSecondary,
                  ),
                ),
                if (subtitle.isNotEmpty)
                  Text(subtitle, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                const Gap(16),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
