import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../domain/providers/order_provider.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(userOrdersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ordersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.mrfRed)),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (orders) {
          if (orders.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No orders yet', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  SizedBox(height: 8),
                  Text('Your order history will appear here', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final statusColor = _getStatusColor(order.orderStatus);
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Order #${order.orderId.substring(0, 6).toUpperCase()}',
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8)),
                            child: Text(
                              order.orderStatus.replaceAll('_', ' ').toUpperCase(),
                              style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      ...order.items.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(children: [
                          const Icon(Icons.tire_repair, size: 16, color: Colors.grey),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${item.productName.isNotEmpty ? item.productName : 'Item'} ×${item.quantity}',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                          Text(
                            '₹${item.totalPriceRupees.toStringAsFixed(0)}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ]),
                      )),
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}',
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          Text(
                            'Total: ₹${order.finalAmountRupees.toStringAsFixed(0)}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, color: AppColors.mrfRed, fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(children: [
                        Text('Payment: ', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: order.paymentStatus == 'paid' || order.paymentStatus == 'collected'
                                ? Colors.green.shade100
                                : Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            order.paymentStatus.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: order.paymentStatus == 'paid' || order.paymentStatus == 'collected'
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                          ),
                        ),
                      ]),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending_confirmation': return Colors.orange;
      case 'confirmed':            return Colors.blue;
      case 'processing':           return Colors.purple;
      case 'shipped':              return Colors.indigo;
      case 'delivered':            return Colors.green;
      case 'cancelled':            return Colors.red;
      default:                     return Colors.grey;
    }
  }
}
