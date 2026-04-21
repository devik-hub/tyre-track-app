import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../data/models/order_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../domain/providers/admin_order_providers.dart';
import '../../../domain/providers/admin_customer_providers.dart';
import '../../../domain/providers/auth_provider.dart';

// ═══════════════════════════════════════════════════════════════════════════
// BUG #2 + BUG #4 FIX — Order detail: real-time, no direct .get(), COD workflow
// ═══════════════════════════════════════════════════════════════════════════

class OrderDetailScreen extends ConsumerWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderDetailProvider(orderId));

    return Scaffold(
      backgroundColor: AppColors.mrfBlack,
      appBar: AppBar(
        title: Text('Order #${orderId.substring(0, 8).toUpperCase()}',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: orderAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.mrfRed)),
        error: (e, _) => _errorBody(context, e.toString()),
        data: (order) {
          if (order == null) return _errorBody(context, 'Order not found.');
          return _OrderDetailBody(order: order);
        },
      ),
    );
  }

  Widget _errorBody(BuildContext context, String msg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.mrfRed, size: 64),
            const SizedBox(height: 16),
            const Text('Unable to load order', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(msg, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.mrfRed),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderDetailBody extends ConsumerWidget {
  final OrderModel order;
  const _OrderDetailBody({required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // BUG #2 fix: watch customer — returns null if not found, never throws
    final customerAsync = ref.watch(customerDetailProvider(order.customerId));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Status banner ─────────────────────────────────────────────
          _StatusBanner(order: order),
          const SizedBox(height: 20),

          // ── COD payment card (BUG #4 fix) ────────────────────────────
          if (order.isCod) _CodPaymentCard(order: order),
          if (order.isCod) const SizedBox(height: 16),

          // ── Customer details ─────────────────────────────────────────
          _SectionCard(
            title: 'Customer',
            icon: Icons.person_outline,
            child: customerAsync.when(
              loading: () => const Padding(padding: EdgeInsets.all(12), child: LinearProgressIndicator(color: AppColors.mrfRed)),
              error: (_, __) => _CustomerFallback(order: order),  // fallback to denormalized
              data: (user) => user != null
                  ? _CustomerInfo(name: user.name, phone: user.phone, email: user.email)
                  : _CustomerFallback(order: order),
            ),
          ),
          const SizedBox(height: 16),

          // ── Order items ───────────────────────────────────────────────
          _SectionCard(
            title: 'Items (${order.items.length})',
            icon: Icons.inventory_2_outlined,
            child: Column(
              children: order.items.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(item.productName.isNotEmpty ? item.productName : 'Product', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    Text('${item.category.toUpperCase()} × ${item.quantity}', style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                  ])),
                  Text('₹${item.totalPriceRupees.toStringAsFixed(0)}', style: const TextStyle(color: AppColors.mrfRed, fontWeight: FontWeight.bold)),
                ]),
              )).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // ── Amount breakdown ─────────────────────────────────────────
          _SectionCard(
            title: 'Amount',
            icon: Icons.receipt_outlined,
            child: Column(children: [
              _amtRow('Subtotal',        order.totalAmountRupees),
              _amtRow('GST',             order.gstAmount / 100),
              _amtRow('Delivery',        order.deliveryCharges / 100),
              const Divider(color: Colors.white10),
              _amtRow('Total', order.finalAmountRupees, highlight: true),
            ]),
          ),
          const SizedBox(height: 16),

          // ── Delivery address ──────────────────────────────────────────
          _SectionCard(
            title: 'Delivery Address',
            icon: Icons.location_on_outlined,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (order.deliveryAddress.recipientName.isNotEmpty)
                Text(order.deliveryAddress.recipientName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              if (order.deliveryAddress.phone.isNotEmpty)
                Text(order.deliveryAddress.phone, style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
              Text([
                order.deliveryAddress.address,
                order.deliveryAddress.landmark,
                order.deliveryAddress.city,
                order.deliveryAddress.state,
                order.deliveryAddress.pincode,
              ].where((s) => s.isNotEmpty).join(', '), style: TextStyle(color: Colors.grey.shade300, fontSize: 13, height: 1.4)),
            ]),
          ),
          const SizedBox(height: 16),

          // ── Status update dropdown ────────────────────────────────────
          _StatusUpdateCard(order: order),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _amtRow(String label, double value, {bool highlight = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: TextStyle(color: highlight ? Colors.white : Colors.grey.shade400, fontWeight: highlight ? FontWeight.bold : FontWeight.normal)),
      Text('₹${value.toStringAsFixed(0)}', style: TextStyle(color: highlight ? AppColors.mrfRed : Colors.white70, fontWeight: highlight ? FontWeight.bold : FontWeight.normal, fontSize: highlight ? 18 : 14)),
    ]),
  );
}

// ─── Status Banner ────────────────────────────────────────────────────────
class _StatusBanner extends StatelessWidget {
  final OrderModel order;
  const _StatusBanner({required this.order});
  @override
  Widget build(BuildContext context) {
    final color = _statusColor(order.orderStatus);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withValues(alpha: 0.4))),
      child: Row(children: [
        Icon(_statusIcon(order.orderStatus), color: color, size: 28),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(order.orderStatus.replaceAll('_', ' ').toUpperCase(), style: TextStyle(color: color, fontWeight: FontWeight.bold, letterSpacing: 1)),
          Text('Order placed ${_date(order.createdAt)}', style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
        ])),
      ]),
    );
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'delivered':  return Colors.green;
      case 'shipped':    return Colors.indigo;
      case 'processing': return Colors.purple;
      case 'confirmed':  return Colors.lightBlue;
      case 'cancelled':  return Colors.red;
      default:           return Colors.orange;
    }
  }

  IconData _statusIcon(String s) {
    switch (s) {
      case 'delivered':  return Icons.check_circle;
      case 'shipped':    return Icons.local_shipping;
      case 'processing': return Icons.engineering;
      case 'confirmed':  return Icons.thumb_up_alt;
      case 'cancelled':  return Icons.cancel;
      default:           return Icons.pending;
    }
  }

  String _date(DateTime d) => '${d.day}/${d.month}/${d.year}';
}

// ─── COD Payment Card (BUG #4 fix) ────────────────────────────────────────
class _CodPaymentCard extends ConsumerWidget {
  final OrderModel order;
  const _CodPaymentCard({required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adminUid = ref.watch(authProvider).userModel?.uid;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: order.isCodPending ? Colors.amber.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: order.isCodPending ? Colors.amber.withValues(alpha: 0.4) : Colors.green.withValues(alpha: 0.4)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.payments_rounded, color: order.isCodPending ? Colors.amber : Colors.green),
          const SizedBox(width: 10),
          Text('CASH ON DELIVERY', style: TextStyle(color: order.isCodPending ? Colors.amber : Colors.green, fontWeight: FontWeight.bold, letterSpacing: 1)),
        ]),
        const SizedBox(height: 8),
        Text('Amount to collect: ₹${order.finalAmountRupees.toStringAsFixed(0)}',
            style: TextStyle(color: Colors.grey.shade300, fontSize: 14)),
        const SizedBox(height: 12),

        if (order.isCodPending) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32), padding: const EdgeInsets.symmetric(vertical: 14)),
              icon: const Icon(Icons.check_circle),
              label: const Text('Mark Cash Collected', style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () => _confirmCollect(context, ref, adminUid),
            ),
          ),
        ] else ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
            child: Row(children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 18),
              const SizedBox(width: 6),
              Text('Cash Collected ✓', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              if (order.collectedAt != null) ...[
                const Spacer(),
                Text('${order.collectedAt!.day}/${order.collectedAt!.month}/${order.collectedAt!.year}', style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
              ],
            ]),
          ),
        ],
      ]),
    );
  }

  void _confirmCollect(BuildContext context, WidgetRef ref, String? adminUid) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        title: const Text('Confirm Cash Collection', style: TextStyle(color: Colors.white)),
        content: Text('Mark ₹${order.finalAmountRupees.toStringAsFixed(0)} as collected for order #${order.orderId.substring(0, 8).toUpperCase()}?', style: TextStyle(color: Colors.grey.shade400)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Colors.white70))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32)),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref.read(orderRepositoryProvider).markCodCashCollected(order.orderId, adminUid: adminUid);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Cash marked as collected')));
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ Error: $e')));
                }
              }
            },
            child: const Text('CONFIRM', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ─── Status Update Card ───────────────────────────────────────────────────
class _StatusUpdateCard extends ConsumerStatefulWidget {
  final OrderModel order;
  const _StatusUpdateCard({required this.order});
  @override
  ConsumerState<_StatusUpdateCard> createState() => _StatusUpdateCardState();
}

class _StatusUpdateCardState extends ConsumerState<_StatusUpdateCard> {
  late String _selected;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _selected = widget.order.orderStatus;
  }

  @override
  Widget build(BuildContext context) {
    const statuses = ['pending_confirmation', 'confirmed', 'processing', 'shipped', 'delivered', 'cancelled'];
    return _SectionCard(
      title: 'Update Order Status',
      icon: Icons.compare_arrows_rounded,
      child: Column(children: [
        DropdownButtonFormField<String>(
          value: statuses.contains(_selected) ? _selected : 'pending_confirmation',
          dropdownColor: const Color(0xFF2C2C2C),
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true, fillColor: const Color(0xFF2C2C2C),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
          items: statuses.map((s) => DropdownMenuItem(value: s, child: Text(s.replaceAll('_', ' ').toUpperCase()))).toList(),
          onChanged: (v) { if (v != null) setState(() => _selected = v); },
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.mrfRed, padding: const EdgeInsets.symmetric(vertical: 14)),
            onPressed: _loading ? null : _updateStatus,
            child: _loading
                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('CONFIRM STATUS UPDATE', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
          ),
        ),
      ]),
    );
  }

  Future<void> _updateStatus() async {
    setState(() => _loading = true);
    try {
      await ref.read(orderRepositoryProvider).updateOrderStatus(widget.order.orderId, _selected);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('📝 Order status → ${_selected.replaceAll('_', ' ')}')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ Error: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}

// ─── Reusable card ────────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  const _SectionCard({required this.title, required this.icon, required this.child});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Padding(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          Icon(icon, color: AppColors.mrfRed, size: 20),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
        ]),
      ),
      const Divider(height: 1, color: Colors.white10),
      Padding(padding: const EdgeInsets.all(16), child: child),
    ]),
  );
}

// ─── Customer info ────────────────────────────────────────────────────────
class _CustomerInfo extends StatelessWidget {
  final String name, phone, email;
  const _CustomerInfo({required this.name, required this.phone, required this.email});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(name.isNotEmpty ? name : 'Unknown Customer', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
    if (phone.isNotEmpty) Text(phone, style: TextStyle(color: Colors.grey.shade300, fontSize: 14)),
    if (email.isNotEmpty) Text(email, style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
  ]);
}

class _CustomerFallback extends StatelessWidget {
  final OrderModel order;
  const _CustomerFallback({required this.order});
  @override
  Widget build(BuildContext context) => _CustomerInfo(
    name:  order.customerName,
    phone: order.customerPhone,
    email: order.customerEmail,
  );
}
