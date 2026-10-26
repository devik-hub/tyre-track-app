import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../app/routes/app_routes.dart';
import '../../../data/models/order_model.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../domain/providers/admin_order_providers.dart';
import '../../../domain/providers/admin_customer_providers.dart';
import '../../../domain/providers/auth_provider.dart';
import '../../widgets/glass/liquid_glass_card.dart';
import '../../widgets/glass/liquid_glass_app_bar.dart';
import '../../widgets/glass/liquid_glass_button.dart';
import '../../widgets/glass/liquid_glass_status_badge.dart';
import '../../widgets/glass/admin_background.dart';

class OrderDetailScreen extends ConsumerWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderDetailProvider(orderId));
    return Scaffold(backgroundColor: AppColors.mrfBlack,
      body: AdminBackground(child: Column(children: [
        LiquidGlassAppBar(title: 'Order #${orderId.substring(0, 8).toUpperCase()}', isDark: true),
        Expanded(child: orderAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.mrfRed)),
          error: (e, _) => _errorBody(context, e.toString()),
          data: (order) {
            if (order == null) return _errorBody(context, 'Order not found.');
            return _OrderDetailBody(order: order);
          })),
      ])),
    );
  }

  Widget _errorBody(BuildContext ctx, String msg) => Center(child: Padding(padding: const EdgeInsets.all(32),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(LucideIcons.alertTriangle, color: AppColors.primary, size: 64),
      const SizedBox(height: 16),
      Text('Unable to load order', style: AppTextStyles.h2.copyWith(color: Colors.white)),
      const SizedBox(height: 8),
      Text(msg, textAlign: TextAlign.center, style: AppTextStyles.body2.copyWith(color: AppColors.adminTextTert)),
      const SizedBox(height: 24),
      LiquidGlassButton(
        label: 'Go Back',
        isDark: true,
        variant: GlassButtonVariant.secondary,
        onPressed: () {
          if (ctx.canPop()) {
            ctx.pop();
          } else {
            ctx.go(AppRoutes.adminOrders);
          }
        },
      ),
    ])));
}

class _OrderDetailBody extends ConsumerWidget {
  final OrderModel order;
  const _OrderDetailBody({required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customerAsync = ref.watch(customerDetailProvider(order.customerId));
    return SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _StatusBanner(order: order),
      const SizedBox(height: 20),
      if (order.isCod) _CodPaymentCard(order: order),
      if (order.isCod) const SizedBox(height: 16),
      _SectionCard(title: 'Customer', icon: LucideIcons.user, child: customerAsync.when(
        loading: () => const Padding(padding: EdgeInsets.all(12), child: LinearProgressIndicator(color: AppColors.primary)),
        error: (_, __) => _CustomerFallback(order: order),
        data: (user) => user != null ? _CustomerInfo(name: user.name, phone: user.phone, email: user.email)
          : _CustomerFallback(order: order))),
      const SizedBox(height: 16),
      _SectionCard(title: 'Items (${order.items.length})', icon: LucideIcons.package,
        child: Column(children: order.items.map((item) => Padding(padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(item.productName.isNotEmpty ? item.productName : 'Product', style: AppTextStyles.label1.copyWith(color: AppColors.adminTextPrimary)),
              Text('${item.category.toUpperCase()} × ${item.quantity}', style: AppTextStyles.body2.copyWith(color: AppColors.adminTextTert)),
            ])),
            Text('₹${item.totalPriceRupees.toStringAsFixed(0)}', style: AppTextStyles.label1.copyWith(color: AppColors.primary)),
          ]))).toList())),
      const SizedBox(height: 16),
      _SectionCard(title: 'Amount', icon: LucideIcons.receipt, child: Column(children: [
        _amtRow('Subtotal', order.totalAmountRupees),
        _amtRow('GST', order.gstAmount / 100),
        _amtRow('Delivery', order.deliveryCharges / 100),
        Divider(color: AppColors.glassDarkBorder), _amtRow('Total', order.finalAmountRupees, highlight: true),
      ])),
      const SizedBox(height: 16),
      _SectionCard(title: 'Delivery Address', icon: LucideIcons.mapPin,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (order.deliveryAddress.recipientName.isNotEmpty) Text(order.deliveryAddress.recipientName, style: AppTextStyles.label1.copyWith(color: AppColors.adminTextPrimary)),
          if (order.deliveryAddress.phone.isNotEmpty) Text(order.deliveryAddress.phone, style: AppTextStyles.body2.copyWith(color: AppColors.adminTextSec)),
          Text([order.deliveryAddress.address, order.deliveryAddress.landmark, order.deliveryAddress.city, order.deliveryAddress.state, order.deliveryAddress.pincode]
            .where((s) => s.isNotEmpty).join(', '), style: AppTextStyles.body2.copyWith(color: AppColors.adminTextSec, height: 1.4)),
        ])),
      const SizedBox(height: 16),
      _StatusUpdateCard(order: order),
      const SizedBox(height: 40),
    ]));
  }

  Widget _amtRow(String label, double value, {bool highlight = false}) => Padding(padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: AppTextStyles.body2.copyWith(color: highlight ? AppColors.adminTextPrimary : AppColors.adminTextTert, fontWeight: highlight ? FontWeight.bold : FontWeight.normal)),
      Text('₹${value.toStringAsFixed(0)}', style: (highlight ? AppTextStyles.h2 : AppTextStyles.body1).copyWith(color: highlight ? AppColors.mrfRed : AppColors.adminTextSec)),
    ]));
}

class _StatusBanner extends StatelessWidget {
  final OrderModel order;
  const _StatusBanner({required this.order});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(order.orderStatus);
    return LiquidGlassCard(isDark: true, borderRadius: 16, blurStrength: 12,
      child: Row(children: [
        Icon(_statusIcon(order.orderStatus), color: color, size: 28),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(order.orderStatus.replaceAll('_', ' ').toUpperCase(), style: AppTextStyles.labelCaps.copyWith(color: color)),
          Text('Order placed ${_date(order.createdAt)}', style: AppTextStyles.body2.copyWith(color: AppColors.adminTextTert)),
        ])),
      ]));
  }

  Color _statusColor(String s) {
    switch (s) { case 'delivered': return Colors.green; case 'shipped': return Colors.indigo; case 'processing': return Colors.purple;
      case 'confirmed': return Colors.lightBlue; case 'cancelled': return Colors.red; default: return Colors.orange; }
  }
  IconData _statusIcon(String s) {
    switch (s) {
      case 'delivered':
        return LucideIcons.checkCircle2;
      case 'shipped':
        return LucideIcons.truck;
      case 'processing':
        return LucideIcons.hardHat;
      case 'confirmed':
        return LucideIcons.thumbsUp;
      case 'cancelled':
        return LucideIcons.xCircle;
      default:
        return LucideIcons.clock;
    }
  }
  String _date(DateTime d) => '${d.day}/${d.month}/${d.year}';
}

class _CodPaymentCard extends ConsumerWidget {
  final OrderModel order;
  const _CodPaymentCard({required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adminUid = ref.watch(authProvider).userModel?.uid;
    final isPending = order.isCodPending;
    return LiquidGlassCard(isDark: true, borderRadius: 16, blurStrength: 10, redAccent: isPending,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(LucideIcons.banknote, color: isPending ? Colors.amber : Colors.green),
          const SizedBox(width: 10),
          Text('CASH ON DELIVERY', style: AppTextStyles.labelCaps.copyWith(color: isPending ? Colors.amber : Colors.green)),
        ]),
        const SizedBox(height: 8),
        Text('Amount: ₹${order.finalAmountRupees.toStringAsFixed(0)}', style: AppTextStyles.body2.copyWith(color: AppColors.adminTextSec)),
        const SizedBox(height: 12),
        if (isPending)
          LiquidGlassButton(label: 'Mark Cash Collected', icon: LucideIcons.checkCircle, variant: GlassButtonVariant.success, isDark: true,
            onPressed: () => _confirmCollect(context, ref, adminUid))
        else
          LiquidGlassStatusBadge(label: 'Cash Collected ✓', color: Colors.green, glow: true),
      ]));
  }

  void _confirmCollect(BuildContext ctx, WidgetRef ref, String? adminUid) {
    showDialog(context: ctx, builder: (c) => AlertDialog(
      backgroundColor: AppColors.glassDarkThick, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Confirm Collection', style: AppTextStyles.h2.copyWith(color: Colors.white)),
      content: Text('Mark ₹${order.finalAmountRupees.toStringAsFixed(0)} as collected?', style: AppTextStyles.body1.copyWith(color: AppColors.adminTextSec)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c), child: Text('Cancel', style: TextStyle(color: AppColors.adminTextSec))),
        ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade800),
          onPressed: () async { Navigator.pop(c);
            try { await ref.read(orderRepositoryProvider).markCodCashCollected(order.orderId, adminUid: adminUid);
              if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Cash collected')));
            } catch (e) { if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Error: $e'))); }
          }, child: const Text('CONFIRM', style: TextStyle(color: Colors.white))),
      ]));
  }
}

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
  void initState() { super.initState(); _selected = widget.order.orderStatus; }

  @override
  Widget build(BuildContext context) {
    const statuses = ['pending_confirmation', 'confirmed', 'processing', 'shipped', 'delivered', 'cancelled'];
    return _SectionCard(title: 'Update Status', icon: LucideIcons.refreshCw,
      child: Column(children: [
        DropdownButtonFormField<String>(
          value: statuses.contains(_selected) ? _selected : 'pending_confirmation',
          dropdownColor: AppColors.glassDarkThick, style: TextStyle(color: AppColors.adminTextPrimary),
          decoration: InputDecoration(filled: true, fillColor: AppColors.glassDark,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
          items: statuses.map((s) => DropdownMenuItem(value: s, child: Text(s.replaceAll('_', ' ').toUpperCase()))).toList(),
          onChanged: (v) { if (v != null) setState(() => _selected = v); }),
        const SizedBox(height: 12),
        LiquidGlassButton(label: 'CONFIRM UPDATE', isDark: true, isLoading: _loading,
          onPressed: _loading ? null : _updateStatus),
      ]));
  }

  Future<void> _updateStatus() async {
    setState(() => _loading = true);
    try { await ref.read(orderRepositoryProvider).updateOrderStatus(widget.order.orderId, _selected);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Status → ${_selected.replaceAll('_', ' ')}')));
    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'))); }
    finally { if (mounted) setState(() => _loading = false); }
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  const _SectionCard({required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) => LiquidGlassCard(isDark: true, borderRadius: 16, blurStrength: 10, padding: EdgeInsets.zero,
    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Padding(padding: const EdgeInsets.all(16), child: Row(children: [
        Icon(icon, color: AppColors.mrfRed, size: 20), const SizedBox(width: 8),
        Text(title, style: AppTextStyles.label1.copyWith(color: AppColors.adminTextPrimary)),
      ])),
      Divider(height: 1, color: AppColors.glassDarkBorder),
      Padding(padding: const EdgeInsets.all(16), child: child),
    ]));
}

class _CustomerInfo extends StatelessWidget {
  final String name, phone, email;
  const _CustomerInfo({required this.name, required this.phone, required this.email});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(name.isNotEmpty ? name : 'Unknown', style: AppTextStyles.label1.copyWith(color: AppColors.adminTextPrimary)),
    if (phone.isNotEmpty) Text(phone, style: AppTextStyles.body2.copyWith(color: AppColors.adminTextSec)),
    if (email.isNotEmpty) Text(email, style: AppTextStyles.body2.copyWith(color: AppColors.adminTextTert)),
  ]);
}

class _CustomerFallback extends StatelessWidget {
  final OrderModel order;
  const _CustomerFallback({required this.order});
  @override
  Widget build(BuildContext context) => _CustomerInfo(name: order.customerName, phone: order.customerPhone, email: order.customerEmail);
}