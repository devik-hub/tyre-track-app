import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/order_model.dart';
import '../../data/repositories/order_repository.dart';
import 'auth_provider.dart';
import 'cart_provider.dart';
import 'package:uuid/uuid.dart';

final orderProvider = StateNotifierProvider<OrderNotifier, AsyncValue<List<OrderModel>>>((ref) {
  final cartItems = ref.read(cartProvider);
  return OrderNotifier(ref.read(orderRepositoryProvider), ref.read(authProvider).userModel?.uid, cartItems);
});

class OrderNotifier extends StateNotifier<AsyncValue<List<OrderModel>>> {
  final OrderRepository _repo;
  final String? _userId;
  final List<OrderItem> _cartCache;

  OrderNotifier(this._repo, this._userId, this._cartCache) : super(const AsyncValue.loading()) {
    if (_userId != null) {
      loadOrders();
    } else {
      state = const AsyncValue.data([]);
    }
  }

  Future<void> loadOrders() async {
    if (_userId == null) return;
    state = const AsyncValue.loading();
    try {
      final orders = await _repo.getCustomerOrders(_userId!);
      state = AsyncValue.data(orders);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<bool> checkoutCart(double totalAmount, Map<String, dynamic> deliveryAddress) async {
    if (_userId == null || _cartCache.isEmpty) return false;
    try {
      final id = const Uuid().v4();
      final newOrder = OrderModel(
        orderId: id,
        customerId: _userId!,
        items: _cartCache,
        totalAmount: totalAmount,
        deliveryAddress: deliveryAddress,
        createdAt: DateTime.now(),
      );
      
      await _repo.createOrder(newOrder);
      
      if (state is AsyncData) {
         state = AsyncValue.data([newOrder, ...state.value!]);
      } else {
         await loadOrders();
      }
      return true;
    } catch (e) {
      return false;
    }
  }
}
