import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../data/models/order_model.dart';
import '../../../domain/providers/admin_order_providers.dart';
import '../../widgets/glass/liquid_glass_card.dart';
import '../../widgets/glass/liquid_glass_app_bar.dart';
import '../../widgets/glass/liquid_glass_status_badge.dart';
import '../../widgets/glass/admin_background.dart';

class AdminOrdersScreen extends ConsumerWidget {
  const AdminOrdersScreen({super.key});

  static const _filters = [
    _FilterOpt('all', 'All Orders'),
    _FilterOpt('cod_pending', 'COD Pending'),
    _FilterOpt('pending_confirmation', 'Awaiting Confirm'),
    _FilterOpt('confirmed', 'Confirmed'),
    _FilterOpt('processing', 'Processing'),
    _FilterOpt('shipped', 'Shipped'),
    _FilterOpt('delivered', 'Delivered'),
    _FilterOpt('cancelled', 'Cancelled'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeFilter = ref.watch(orderFilterProvider);
    final ordersAsync = ref.watch(activeOrdersProvider);

    return Scaffold(
      backgroundColor: AppColors.mrfBlack,
      body: AdminBackground(
          child: Column(children: [
        LiquidGlassAppBar(title: 'Customer Orders', isDark: true, actions: [
          Consumer(builder: (ctx, r, _) {
            final total = r.watch(codOutstandingTotalProvider);
            return total.maybeWhen(
                data: (amt) => amt == 0
                    ? const SizedBox.shrink()
                    : Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                            color: Colors.amber.shade800,
                            borderRadius: BorderRadius.circular(12)),
                        child: Text('COD ₹${amt.toStringAsFixed(0)}',
                            style: AppTextStyles.labelCaps
                                .copyWith(color: Colors.white))),
                orElse: () => const SizedBox.shrink());
          }),
        ]),
        _buildFilterRow(context, ref, activeFilter),
        Expanded(
            child: ordersAsync.when(
                loading: () => const Center(
                    child: CircularProgressIndicator(color: AppColors.mrfRed)),
                error: (e, _) => _ErrorPanel(
                    message: e.toString(),
                    onRetry: () => ref.refresh(allOrdersStreamProvider)),
                data: (orders) {
                  if (orders.isEmpty)
                    return Center(
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.receipt_long_outlined,
                          size: 64, color: Colors.white24),
                      const SizedBox(height: 12),
                      Text(
                          'No ${activeFilter == 'all' ? '' : activeFilter.replaceAll('_', ' ')} orders',
                          style: AppTextStyles.body1
                              .copyWith(color: Colors.white54)),
                    ]));
                  return RefreshIndicator(
                      color: AppColors.mrfRed,
                      backgroundColor: AppColors.mrfBlack,
                      onRefresh: () async =>
                          ref.refresh(allOrdersStreamProvider),
                      child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                          itemCount: orders.length,
                          itemBuilder: (ctx, i) => _OrderCard(
                              order: orders[i],
                              onTap: () => context.push(
                                  AppRoutes.adminOrderDetail,
                                  extra: orders[i].orderId))));
                })),
      ])),
    );
  }

  Widget _buildFilterRow(
      BuildContext context, WidgetRef ref, String activeFilter) {
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
            children: _filters.map((f) {
          final sel = activeFilter == f.value;
          final color = _filterColor(f.value);
          return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                  label: Text(f.label,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                          color: sel ? color : Colors.grey.shade400)),
                  selected: sel,
                  onSelected: (_) =>
                      ref.read(orderFilterProvider.notifier).state = f.value,
                  backgroundColor: AppColors.glassDark,
                  selectedColor: color.withValues(alpha: 0.18),
                  side: BorderSide(color: sel ? color : Colors.transparent),
                  checkmarkColor: color,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20))));
        }).toList()));
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onTap;
  const _OrderCard({required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isCodPending = order.isCodPending;
    return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: LiquidGlassCard(
            onTap: onTap,
            isDark: true,
            borderRadius: 16,
            blurStrength: 12,
            redAccent: isCodPending,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text('#${order.orderId.substring(0, 8).toUpperCase()}',
                          style: AppTextStyles.mono
                              .copyWith(color: AppColors.adminTextPrimary)),
                      const SizedBox(height: 2),
                      Text(
                          order.customerName.isNotEmpty
                              ? order.customerName
                              : 'Customer',
                          style: AppTextStyles.body2
                              .copyWith(color: AppColors.adminTextSec)),
                      if (order.customerPhone.isNotEmpty)
                        Text(order.customerPhone,
                            style: AppTextStyles.body2.copyWith(
                                color: AppColors.adminTextTert, fontSize: 11)),
                    ])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('₹${order.finalAmountRupees.toStringAsFixed(0)}',
                      style:
                          AppTextStyles.h2.copyWith(color: AppColors.mrfRed)),
                  const SizedBox(height: 4),
                  LiquidGlassStatusBadge(
                      label: order.orderStatus.replaceAll('_', ' '),
                      color: _orderStatusColor(order.orderStatus)),
                ]),
              ]),
              Divider(height: 16, color: AppColors.glassDarkBorder),
              Text('${order.items.length} item(s)',
                  style: AppTextStyles.body2
                      .copyWith(color: AppColors.adminTextTert)),
              const SizedBox(height: 6),
              Row(children: [
                LiquidGlassStatusBadge(
                    label: order.paymentMethod == 'cod' ? 'COD' : 'ONLINE',
                    color: order.paymentMethod == 'cod'
                        ? Colors.amber
                        : Colors.lightBlue),
                const SizedBox(width: 6),
                LiquidGlassStatusBadge(
                    label: order.paymentStatus,
                    color: _payStatusColor(order.paymentStatus)),
                if (isCodPending) ...[
                  const SizedBox(width: 6),
                  LiquidGlassStatusBadge(
                      label: 'CASH DUE', color: Colors.orange)
                ],
                const Spacer(),
                Text(
                    '${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}',
                    style: AppTextStyles.body2.copyWith(
                        color: AppColors.adminTextTert, fontSize: 10)),
              ]),
            ])));
  }
}

class _ErrorPanel extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorPanel({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
      child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.error_outline, color: AppColors.mrfRed, size: 56),
            const SizedBox(height: 16),
            Text('Failed to load orders',
                style: AppTextStyles.h2.copyWith(color: Colors.white)),
            const SizedBox(height: 8),
            Text(message,
                textAlign: TextAlign.center,
                style: AppTextStyles.body2
                    .copyWith(color: AppColors.adminTextTert)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
                style:
                    ElevatedButton.styleFrom(backgroundColor: AppColors.mrfRed),
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry')),
          ])));
}

class _FilterOpt {
  final String value;
  final String label;
  const _FilterOpt(this.value, this.label);
}

Color _filterColor(String v) {
  switch (v) {
    case 'cod_pending':
      return Colors.amber;
    case 'pending_confirmation':
      return Colors.orange;
    case 'confirmed':
      return Colors.lightBlue;
    case 'processing':
      return Colors.purple;
    case 'shipped':
      return Colors.indigo;
    case 'delivered':
      return Colors.green;
    case 'cancelled':
      return Colors.red;
    default:
      return Colors.white;
  }
}

Color _orderStatusColor(String s) {
  switch (s) {
    case 'pending_confirmation':
      return Colors.orange;
    case 'confirmed':
      return Colors.lightBlueAccent;
    case 'processing':
      return Colors.purpleAccent;
    case 'shipped':
      return Colors.indigoAccent;
    case 'delivered':
      return Colors.greenAccent;
    case 'cancelled':
      return Colors.redAccent;
    default:
      return Colors.grey;
  }
}

Color _payStatusColor(String s) {
  switch (s) {
    case 'paid':
    case 'collected':
      return Colors.green;
    case 'pending':
      return Colors.orange;
    case 'failed':
      return Colors.red;
    case 'refunded':
      return Colors.blue;
    default:
      return Colors.grey;
  }
}
