import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../data/models/order_model.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../domain/providers/order_provider.dart';

class AdminOrdersScreen extends ConsumerStatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  ConsumerState<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends ConsumerState<AdminOrdersScreen> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(allOrdersProvider);

    return Scaffold(
      backgroundColor: AppColors.mrfBlack,
      appBar: AppBar(
        title: const Text('Customer Orders', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: ordersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.mrfRed)),
              error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.red))),
              data: (orders) {
                final filteredOrders = _filter == 'all' ? orders : orders.where((o) => o.status == _filter).toList();

                if (filteredOrders.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.white24),
                        SizedBox(height: 16),
                        Text('No associated orders', style: TextStyle(fontSize: 18, color: Colors.white70)),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  color: AppColors.mrfRed,
                  backgroundColor: AppColors.mrfBlack,
                  onRefresh: () async => ref.refresh(allOrdersProvider),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) => _buildOrderCard(context, ref, filteredOrders[index]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: ['all', 'pending', 'processing', 'shipped', 'delivered', 'cancelled'].map((status) {
          final isSelected = _filter == status;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(status.toUpperCase().replaceAll('_', ' ')),
              selected: isSelected,
              onSelected: (val) => setState(() => _filter = status),
              backgroundColor: const Color(0xFF2C2C2C),
              selectedColor: AppColors.mrfRed.withValues(alpha: 0.2),
              labelStyle: TextStyle(
                color: isSelected ? AppColors.mrfRed : Colors.grey.shade500,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12
              ),
              side: BorderSide(color: isSelected ? AppColors.mrfRed : Colors.transparent),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, WidgetRef ref, OrderModel order) {
    final statusColor = _getStatusColor(order.status);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Icons.receipt_long_rounded, color: Colors.white54, size: 18),
                    const SizedBox(width: 8),
                    Text('#${order.orderId.substring(0, 8).toUpperCase()}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14, letterSpacing: 1)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12), border: Border.all(color: statusColor.withValues(alpha: 0.5))),
                  child: Text(order.status.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor, letterSpacing: 0.5)),
                ),
              ],
            ),
            const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1, color: Colors.white10)),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${order.items.length} item(s)', style: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.w500)),
                Text('₹${order.totalAmount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.mrfRed, fontSize: 18)),
              ],
            ),
            const SizedBox(height: 8),
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: order.items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(color: Colors.white54)),
                      Expanded(child: Text('${item.name} x${item.quantity}', style: TextStyle(fontSize: 13, color: Colors.grey.shade300))),
                      Text('₹${item.price.toStringAsFixed(0)}', style: const TextStyle(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.bold)),
                    ],
                  ),
                )).toList(),
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(order.paymentStatus == 'paid' ? Icons.check_circle : Icons.error_outline, 
                         size: 16, color: order.paymentStatus == 'paid' ? Colors.greenAccent : Colors.orangeAccent),
                    const SizedBox(width: 6),
                    Text('Payment: ${order.paymentStatus.toUpperCase()}', 
                         style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: order.paymentStatus == 'paid' ? Colors.greenAccent : Colors.orangeAccent)),
                  ],
                ),
                Text('${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}', style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
              ],
            ),
            
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C2C2C),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => _showStatusBottomSheet(context, ref, order),
                icon: const Icon(Icons.compare_arrows_rounded, size: 18),
                label: const Text('UPDATE ORDER PIPELINE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return Colors.orangeAccent;
      case 'processing': return Colors.lightBlueAccent;
      case 'shipped': return Colors.purpleAccent;
      case 'delivered': return Colors.greenAccent;
      case 'cancelled': return Colors.redAccent;
      default: return Colors.grey;
    }
  }

  void _showStatusBottomSheet(BuildContext context, WidgetRef ref, OrderModel order) {
    String selectedStatus = order.status;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade600, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 24),
              const Text('Update Order Pipeline', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 8),
              Text('Order #${order.orderId.substring(0, 8).toUpperCase()}', style: TextStyle(color: Colors.grey.shade500)),
              const SizedBox(height: 24),
              
              DropdownButtonFormField<String>(
                value: selectedStatus,
                dropdownColor: const Color(0xFF2C2C2C),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Order Lifecycle Status',
                  labelStyle: TextStyle(color: Colors.grey.shade500),
                  filled: true,
                  fillColor: const Color(0xFF2C2C2C),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  prefixIcon: const Icon(Icons.local_shipping, color: Colors.white54),
                ),
                items: ['pending', 'processing', 'shipped', 'delivered', 'cancelled']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s.toUpperCase().replaceAll('_', ' '))))
                    .toList(),
                onChanged: (v) => setModalState(() => selectedStatus = v!),
              ),
              
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mrfRed,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                ),
                onPressed: () async {
                  await ref.read(orderRepositoryProvider).updateOrderStatus(order.orderId, selectedStatus);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: const Text('CONFIRM STATUS UPDATE', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
