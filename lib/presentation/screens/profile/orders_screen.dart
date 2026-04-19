import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../domain/providers/order_provider.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderState = ref.watch(orderProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Order History')),
      body: orderState.when(
        data: (orders) {
           if (orders.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                     const Icon(Icons.history, size: 80, color: Colors.grey),
                     const SizedBox(height: 16),
                     const Text('No orders found', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  ]
                ),
              );
           }
           return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                 final order = orders[index];
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
                                   Text('Order #${order.orderId.substring(0,6).toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                   Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                         color: order.status == 'delivered' ? AppColors.mrfGreen.withOpacity(0.1) : Colors.grey[200], 
                                         borderRadius: BorderRadius.circular(4)
                                      ),
                                      child: Text(
                                         order.status.toUpperCase(), 
                                         style: TextStyle(
                                            color: order.status == 'delivered' ? AppColors.mrfGreen : Colors.grey[700], 
                                            fontSize: 12, 
                                            fontWeight: FontWeight.bold
                                         )
                                      ),
                                   )
                                ],
                             ),
                             const Divider(height: 24),
                             Row(
                                children: [
                                   Container(width: 40, height: 40, color: Colors.grey[200], child: const Icon(Icons.tire_repair, size: 20)),
                                   const SizedBox(width: 12),
                                   Expanded(
                                      child: Column(
                                         crossAxisAlignment: CrossAxisAlignment.start,
                                         children: [
                                            Text('${order.items.length} Items purchased', style: const TextStyle(fontWeight: FontWeight.w600)),
                                         ]
                                      ),
                                   ),
                                   Text('₹${order.totalAmount}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.mrfRed)),
                                ],
                             ),
                             const SizedBox(height: 16),
                             OutlinedButton(
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 36)),
                                child: const Text('View Invoice'),
                             )
                          ],
                       ),
                    )
                 );
              },
           );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.mrfRed)),
        error: (err, stack) => Center(child: Text('Error fetching orders: $err')),
      ),
    );
  }
}
