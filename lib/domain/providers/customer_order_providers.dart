import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/order_model.dart';
import '../../data/repositories/order_repository.dart';
import 'auth_provider.dart';

/// All customer orders for a given customerId — real-time
final customerOrdersStreamProvider = StreamProvider.family<List<OrderModel>, String>((ref, customerId){
  if(customerId.isEmpty) return Stream.value([]);
  return ref
      .read(orderRepositoryProvider)
      .streamUserOrders(customerId)
      .handleError((e,s){
        print('customerOrdersStreamProvider($customerId) error: $e\n$s');
        return <OrderModel>[];
      });
});

/// Customer: single order — real-time (admin status changes reflectt here instantly)
final customerOrderDetailProvider = StreamProvider.family<OrderModel?, String>((ref, orderId){
  if(orderId.isEmpty) return Stream.value(null);
  return ref
      .read(orderRepositoryProvider)
      .streamOrderById(orderId)
      .handleError((e,s){
        print('customerOrderDetailProvider($orderId) error: $e\n$s');
        return null;
      });
});

/// Convenience: current logged-in customer's orders (uses auth state)
final myOrdersProvider = StreamProvider<List<OrderModel>>((ref){
  final user = ref.watch(authProvider).userModel;
  if(user==null) return Stream.value([]);
  return ref
      .read(orderRepositoryProvider)
      .streamUserOrders(user.uid)
      .handleError((e, s) {
        print('myOrdersProvider error: $e\n$s');
        return <OrderModel>[];
      });
});
