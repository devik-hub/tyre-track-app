import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/order_model.dart';
import '../../data/repositories/order_repository.dart';
import 'auth_provider.dart';

/// UI filter state — drives which StreamProvider the admin orders tab resolves to
final orderFilterProvider = StateProvider<String>((ref) => 'all');

/// Admin: ALL orders, real-time, newest first
final allOrdersStreamProvider = StreamProvider<List<OrderModel>>((ref){
  return ref
      .read(orderRepositoryProvider)
      .streamAllOrders()
      .handleError((e,s){
        print('allOrdersStreamProvider error: $e\n$s');
        return <OrderModel>[];
      });
});

/// Admin: COD orders with paymentStatus == pending
final codPendingOrdersProvider = StreamProvider<List<OrderModel>>((ref){
  return ref
      .read(orderRepositoryProvider)
      .streamCodPendingOrders()
      .handleError((e, s) {
        print('codPendingOrdersProvider error: $e\n$s');
        return <OrderModel>[];
      });
});

/// Admin: Orders filtered by orderStatus — family param is status string
final ordersByStatusProvider =
    StreamProvider.family<List<OrderModel>, String>((ref, status){
  return ref
      .read(orderRepositoryProvider)
      .streamOrdersByStatus(status)
      .handleError((e,s){
        print('ordersByStatusProvider($status) error: $e\n$s');
        return <OrderModel>[];
      });
});

/// Admin: Single order detail in real time
final orderDetailProvider =
    StreamProvider.family<OrderModel?, String>((ref, orderId){
  return ref
      .read(orderRepositoryProvider)
      .streamOrderById(orderId)
      .handleError((e,s){
        print('orderDetailProvider($orderId) error: $e\n$s');
        return null;
      });
});

/// Admin: COD outstanding total in rupees — derived, never separate Firestore read
final codOutstandingTotalProvider = StreamProvider<double>((ref){
  return ref
      .watch(codPendingOrdersProvider.stream)
      .map((orders) {
        final total = orders.fold<int>(0, (sum, o) => sum + o.finalAmount);
        return total / 100.0; // paise → rupees
      })
      .handleError((e,s){
        print('codOutstandingTotalProvider error: $e\n$s');
        return 0.0;
      });
});

/// Convenience: resolves the correct provider based on orderFilterProvider state.
/// Returns AsyncValue directly — no nested streams.
final activeOrdersProvider = Provider<AsyncValue<List<OrderModel>>>((ref) {
  final filter = ref.watch(orderFilterProvider);
  switch(filter){
    case 'cod_pending':
      return ref.watch(codPendingOrdersProvider);
    case 'all':
      return ref.watch(allOrdersStreamProvider);
    default:
      return ref.watch(ordersByStatusProvider(filter));
  }
});

// Keep existing names as aliases for backwards compatibility
final allOrdersProvider = allOrdersStreamProvider;

/// Customer: My orders in real time
final userOrdersProvider = StreamProvider<List<OrderModel>>((ref){
  final user = ref.watch(authProvider).userModel;
  if(user == null) return Stream.value([]);
  return ref
      .read(orderRepositoryProvider)
      .streamUserOrders(user.uid)
      .handleError((e, s) {
        print('userOrdersProvider error: $e\n$s');
        return <OrderModel>[];
      });
});

/// COD outstanding total as AsyncValue<double> — alias used in admin_provider
final codOutstandingTotalLegacyProvider = Provider<AsyncValue<double>>((ref){
  return ref.watch(codPendingOrdersProvider).whenData(
    (orders) => orders.fold<int>(0, (sum, o) => sum + o.finalAmount) / 100.0,
  );
});
