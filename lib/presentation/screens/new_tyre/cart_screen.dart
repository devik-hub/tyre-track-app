import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../domain/providers/cart_provider.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final total = ref.read(cartProvider.notifier).totalAmount;

    return Scaffold(
      appBar: AppBar(title: const Text('Your Cart')),
      body: cartItems.isEmpty 
        ? const Center(child: Text('Your cart is empty', style: TextStyle(fontSize: 18)))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
               final item = cartItems[index];
               return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                     padding: const EdgeInsets.all(16.0),
                     child: Row(
                        children: [
                           Container(width: 60, height: 60, color: Colors.grey[200], child: const Icon(Icons.tire_repair)),
                           const SizedBox(width: 16),
                           Expanded(
                              child: Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                    Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    const SizedBox(height: 4),
                                    Text('₹${item.price}', style: const TextStyle(color: AppColors.mrfRed, fontWeight: FontWeight.bold)),
                                 ],
                              ),
                           ),
                           Column(
                              children: [
                                 Row(
                                    children: [
                                       IconButton(onPressed: () => ref.read(cartProvider.notifier).updateQuantity(item.productId, item.quantity - 1), icon: const Icon(Icons.remove_circle_outline, size: 20)),
                                       Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                       IconButton(onPressed: () => ref.read(cartProvider.notifier).updateQuantity(item.productId, item.quantity + 1), icon: const Icon(Icons.add_circle_outline, size: 20)),
                                    ],
                                 ),
                              ],
                           )
                        ],
                     ),
                  ),
               );
            },
         ),
      bottomNavigationBar: cartItems.isEmpty ? null : SafeArea(
         child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
               color: Colors.white,
               boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), offset: const Offset(0, -4), blurRadius: 10)],
            ),
            child: Column(
               mainAxisSize: MainAxisSize.min,
               children: [
                  Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                        const Text('Total Amount', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text('₹$total', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.mrfRed)),
                     ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: () {}, child: const Text('Proceed to Payment')),
               ],
            ),
         ),
      ),
    );
  }
}
