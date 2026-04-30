import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/routes/app_routes.dart';
import '../../../domain/providers/cart_provider.dart';
import '../../../domain/providers/auth_provider.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../data/models/order_model.dart';
import '../../../data/services/razorpay_service.dart';

class CartScreen extends ConsumerStatefulWidget{
  const CartScreen({super.key});
  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen>{
  bool _isProcessing = false;
  String _selectedPaymentMethod = 'online';

  Future<void> _handleCheckout(double totalRupees, int totalPaise, List<OrderItem> cartItems) async{
    final user = ref.read(authProvider).userModel;
    if(user==null){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to secure your checkout.'),
        ),
      );
      return;
    }
    setState(() => _isProcessing = true);

    if(_selectedPaymentMethod == 'cod'){
      try{
        final orderId = await ref.read(orderRepositoryProvider).checkoutAtomicWithStockReduction(
          items: cartItems, customer: user, paymentMethod: 'cod', paymentStatus: 'pending',
        );
        if(mounted){
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Order Placed! Cash on Delivery confirmed!'),
            ),
          );
          context.go(AppRoutes.home);
          Future.delayed(const Duration(milliseconds: 300), () => ref.read(cartProvider.notifier).clear());
        }
        print('COD order placed: $orderId');
      } catch(e){
        if(mounted){
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Order failed: $e'),
            ),
          );
          setState(() => _isProcessing = false);
        }
      }
      return;
    }

    final razorpay = ref.read(razorpayServiceProvider);
    razorpay.onSuccess = (response) async{
      try{
        final orderId = await ref.read(orderRepositoryProvider).checkoutAtomicWithStockReduction(
          items: cartItems, customer: user, paymentMethod: 'razorpay', paymentStatus: 'paid', paymentId: response.paymentId,
        );
        if(mounted){
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment Successful! Order Confirmed'),
            ),
          );
          context.go(AppRoutes.home);
          Future.delayed(const Duration(milliseconds: 300), () => ref.read(cartProvider.notifier).clear());
        }
        print('Online order placed: $orderId');
      } catch(e){
        if(mounted){
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Order save failed: $e'),
            ),
          );
          setState(() => _isProcessing = false);
        }
      }
    };
    razorpay.onFailure = (response){
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment Cancelled/Failed: ${response.message}'),
          ),
        );
        setState(() => _isProcessing = false);
      }
    };
    razorpay.openCheckout(amount: totalRupees, contact: user.phone, email: user.email.isNotEmpty ? user.email : 'customer@jagadale.com', description: 'Jagadale Tyre Order');
  }

  @override
  Widget build(BuildContext context){
    final cartItems = ref.watch(cartProvider);
    final notifier = ref.read(cartProvider.notifier);
    final totalRupees = notifier.totalAmount;
    final totalPaise = notifier.totalAmountPaise;

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
              padding: const EdgeInsets.all(16), itemCount: cartItems.length,
              itemBuilder: (context,index){
                final item = cartItems[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Container(width: 60, height: 60, color: Colors.grey[200],
                          child: const Icon(Icons.tire_repair),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.productName.isNotEmpty ? item.productName : 'Product',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text('₹${item.unitPriceRupees.toStringAsFixed(0)}',
                                style: const TextStyle(color: AppColors.mrfRed, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        Row(children: [
                          IconButton(onPressed: () => ref.read(cartProvider.notifier).updateQuantity(item.productId, item.quantity-1),
                            icon: const Icon(Icons.remove_circle_outline, size: 20),
                          ),
                          Text('${item.quantity}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          IconButton(onPressed: () => ref.read(cartProvider.notifier).updateQuantity(item.productId, item.quantity+1),
                            icon: const Icon(Icons.add_circle_outline, size: 20),
                          ),
                        ],
                        ),
                      ],
                    ),
                  ),
                );
                },
      ),
      bottomNavigationBar: cartItems.isEmpty ? null : SafeArea(child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05),
              offset: const Offset(0, -4),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Payment Method', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: RadioListTile<String>(
                title: const Text('Online',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                value: 'online',
                groupValue: _selectedPaymentMethod,
                activeColor: AppColors.mrfRed,
                contentPadding: EdgeInsets.zero,
                dense: true,
                visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                onChanged: (val) => setState(() => _selectedPaymentMethod = val!),
              ),),
              Expanded(child: RadioListTile<String>(
                title: const Text('COD',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                value: 'cod',
                groupValue: _selectedPaymentMethod,
                activeColor: AppColors.mrfRed,
                contentPadding: EdgeInsets.zero,
                dense: true,
                visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                onChanged: (val) => setState(() => _selectedPaymentMethod = val!),
              ),),
            ],),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Amount',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text('₹${totalRupees.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.mrfRed),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if(_isProcessing)
                    return;
                  _handleCheckout(totalRupees, totalPaise, cartItems);
                },
                child: _isProcessing
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: AppColors.mrfRed, strokeWidth: 2),) : Text(_selectedPaymentMethod == 'cod' ? 'Place Order' : 'Proceed to Payment'),
              ),
            ),
          ],
        ),
      ),),
    );
  }
}