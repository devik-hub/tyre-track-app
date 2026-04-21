import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../domain/providers/cart_provider.dart';
import '../../../domain/providers/auth_provider.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../data/models/order_model.dart';
import '../../../data/services/razorpay_service.dart';
import 'package:uuid/uuid.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  bool _isProcessing = false;

  void _handleCheckout(double total, List<OrderItem> cartItems) {
    final user = ref.read(authProvider).userModel;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please login to secure your checkout.')));
      return;
    }

    setState(() => _isProcessing = true);
    final razorpay = ref.read(razorpayServiceProvider);

    razorpay.onSuccess = (response) async {
       try {
         final order = OrderModel(
           orderId: const Uuid().v4(),
           customerId: user.uid,
           items: cartItems,
           totalAmount: total,
           status: 'pending',
           paymentStatus: 'paid',
           paymentId: response.paymentId,
           deliveryAddress: {'address': 'Default Address'},
           createdAt: DateTime.now(),
         );
         await ref.read(orderRepositoryProvider).createOrder(order);
         if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment Successful! Order Confirmed. ✨')));
           ref.read(cartProvider.notifier).clear();
           context.go('/home');
         }
       } catch (e) {
         if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Order failed: $e')));
           setState(() => _isProcessing = false);
         }
       }
    };

    razorpay.onFailure = (response) {
       if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment Cancelled/Failed: ${response.message}')));
           setState(() => _isProcessing = false);
       }
    };

    razorpay.openCheckout(
       amount: total,
       contact: user.phone,
       email: user.email ?? 'customer@jagadale.com',
       description: 'Jagadale Tyre Order',
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    final total = ref.read(cartProvider.notifier).totalAmount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
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
                  ElevatedButton(
                    onPressed: _isProcessing ? null : () => _handleCheckout(total, cartItems), 
                    child: _isProcessing 
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white))
                        : const Text('Proceed to Payment')
                  ),
               ],
            ),
         ),
      ),
    );
  }
}
