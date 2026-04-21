import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../data/models/order_model.dart';
import '../../../domain/providers/admin_order_providers.dart';

class AdminOrdersScreen extends ConsumerWidget {
  const AdminOrdersScreen({super.key});

  static const _filters = [
    _FilterOpt('all',                  'All Orders'),
    _FilterOpt('cod_pending',          'COD Pending'),
    _FilterOpt('pending_confirmation', 'Awaiting Confirm'),
    _FilterOpt('confirmed',            'Confirmed'),
    _FilterOpt('processing',           'Processing'),
    _FilterOpt('shipped',              'Shipped'),
    _FilterOpt('delivered',            'Delivered'),
    _FilterOpt('cancelled',            'Cancelled'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeFilter = ref.watch(orderFilterProvider);
    final ordersAsync  = ref.watch(activeOrdersProvider);

    return Scaffold(
      backgroundColor: AppColors.mrfBlack,
      appBar: AppBar(
        title: const Text('Customer Orders', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Consumer(builder: (ctx, r, _) {
            final total = r.watch(codOutstandingTotalProvider);
            return total.maybeWhen(
              data: (amt) => amt == 0 ? const SizedBox.shrink() : Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.amber.shade800, borderRadius: BorderRadius.circular(12)),
                child: Text('COD ₹${amt.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              orElse: () => const SizedBox.shrink(),
            );
          }),
        ],
      ),
      body: Column(
        children: [
          _buildFilterRow(context, ref, activeFilter),
          Expanded(
            child: ordersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.mrfRed)),
              error: (e, _) => _ErrorPanel(message: e.toString(), onRetry: () => ref.refresh(allOrdersStreamProvider)),
              data: (orders) {
                if (orders.isEmpty) {
                  return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.receipt_long_outlined, size: 64, color: Colors.white24),
                    const SizedBox(height: 12),
                    Text('No ${activeFilter == 'all' ? '' : activeFilter.replaceAll('_', ' ')} orders', style: const TextStyle(color: Colors.white54, fontSize: 16)),
                  ]));
                }
                return RefreshIndicator(
                  color: AppColors.mrfRed,
                  backgroundColor: AppColors.mrfBlack,
                  onRefresh: () async => ref.refresh(allOrdersStreamProvider),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                    itemCount: orders.length,
                    itemBuilder: (ctx, i) => _OrderCard(
                      order: orders[i],
                      onTap: () => context.push(AppRoutes.adminOrderDetail, extra: orders[i].orderId),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow(BuildContext context, WidgetRef ref, String activeFilter) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: _filters.map((f) {
          final isSelected = activeFilter == f.value;
          final color = _filterColor(f.value);
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(f.label, style: TextStyle(fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? color : Colors.grey.shade400)),
              selected: isSelected,
              onSelected: (_) => ref.read(orderFilterProvider.notifier).state = f.value,
              backgroundColor: const Color(0xFF2C2C2C),
              selectedColor: color.withValues(alpha: 0.18),
              side: BorderSide(color: isSelected ? color : Colors.transparent),
              checkmarkColor: color,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onTap;
  const _OrderCard({required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isCodPending = order.isCodPending;
    final statusColor  = _orderStatusColor(order.orderStatus);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isCodPending ? Colors.amber.withValues(alpha: 0.4) : Colors.white10),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('#${order.orderId.substring(0, 8).toUpperCase()}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1)),
                  const SizedBox(height: 2),
                  Text(order.customerName.isNotEmpty ? order.customerName : 'Customer', style: TextStyle(color: Colors.grey.shade300, fontSize: 13)),
                  if (order.customerPhone.isNotEmpty)
                    Text(order.customerPhone, style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                ])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('₹${order.finalAmountRupees.toStringAsFixed(0)}', style: const TextStyle(color: AppColors.mrfRed, fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 4),
                  _pill(order.orderStatus.replaceAll('_', ' ').toUpperCase(), statusColor),
                ]),
              ],
            ),
            const Divider(height: 16, color: Colors.white10),
            Text('${order.items.length} item(s)', style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
            const SizedBox(height: 6),
            Row(children: [
              _pill(order.paymentMethod == 'cod' ? 'COD' : 'ONLINE', order.paymentMethod == 'cod' ? Colors.amber : Colors.lightBlue),
              const SizedBox(width: 6),
              _pill(order.paymentStatus.toUpperCase(), _payStatusColor(order.paymentStatus)),
              if (isCodPending) ...[const SizedBox(width: 6), _pill('CASH DUE', Colors.orange)],
              const Spacer(),
              Text('${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}', style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _pill(String t, Color c) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(color: c.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6), border: Border.all(color: c.withValues(alpha: 0.4))),
    child: Text(t, style: TextStyle(fontSize: 9, color: c, fontWeight: FontWeight.bold)),
  );
}

class _ErrorPanel extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorPanel({required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
    const Icon(Icons.error_outline, color: AppColors.mrfRed, size: 56),
    const SizedBox(height: 16),
    const Text('Failed to load orders', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
    const SizedBox(height: 8),
    Text(message, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
    const SizedBox(height: 24),
    ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: AppColors.mrfRed), onPressed: onRetry, icon: const Icon(Icons.refresh), label: const Text('Retry')),
  ])));
}

class _FilterOpt {
  final String value;
  final String label;
  const _FilterOpt(this.value, this.label);
}

Color _filterColor(String v) {
  switch (v) {
    case 'cod_pending':          return Colors.amber;
    case 'pending_confirmation': return Colors.orange;
    case 'confirmed':            return Colors.lightBlue;
    case 'processing':           return Colors.purple;
    case 'shipped':              return Colors.indigo;
    case 'delivered':            return Colors.green;
    case 'cancelled':            return Colors.red;
    default:                     return Colors.white;
  }
}

Color _orderStatusColor(String s) {
  switch (s) {
    case 'pending_confirmation': return Colors.orange;
    case 'confirmed':            return Colors.lightBlueAccent;
    case 'processing':           return Colors.purpleAccent;
    case 'shipped':              return Colors.indigoAccent;
    case 'delivered':            return Colors.greenAccent;
    case 'cancelled':            return Colors.redAccent;
    default:                     return Colors.grey;
  }
}

Color _payStatusColor(String s) {
  switch (s) {
    case 'paid':      return Colors.green;
    case 'collected': return Colors.green;
    case 'pending':   return Colors.orange;
    case 'failed':    return Colors.red;
    case 'refunded':  return Colors.blue;
    default:          return Colors.grey;
  }
}
