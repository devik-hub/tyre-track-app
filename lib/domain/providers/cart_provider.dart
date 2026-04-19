import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/order_model.dart';
import '../../data/models/product_model.dart';

// Very basic cart state management
final cartProvider = StateNotifierProvider<CartNotifier, List<OrderItem>>((ref) {
  return CartNotifier();
});

class CartNotifier extends StateNotifier<List<OrderItem>> {
  CartNotifier() : super([]);

  void addToCart(ProductModel product, int quantity) {
    // Check if exists
    final index = state.indexWhere((item) => item.productId == product.productId);
    if (index >= 0) {
      final current = state[index];
      final updated = OrderItem(
        productId: current.productId,
        name: current.name,
        quantity: current.quantity + quantity,
        price: current.price,
      );
      final newState = [...state];
      newState[index] = updated;
      state = newState;
    } else {
      state = [
        ...state,
        OrderItem(
          productId: product.productId,
          name: product.name,
          quantity: quantity,
          price: product.discountedPrice ?? product.price,
        )
      ];
    }
  }

  void removeFromCart(String productId) {
    state = state.where((item) => item.productId != productId).toList();
  }
  
  void updateQuantity(String productId, int newQuantity) {
     if (newQuantity <= 0) {
        removeFromCart(productId);
        return;
     }
     final index = state.indexWhere((item) => item.productId == productId);
     if (index >= 0) {
        final current = state[index];
        final updated = OrderItem(productId: current.productId, name: current.name, quantity: newQuantity, price: current.price);
        final newState = [...state];
        newState[index] = updated;
        state = newState;
     }
  }
  
  void clear() {
     state = [];
  }
  
  double get totalAmount {
      return state.fold(0.0, (total, item) => total + (item.price * item.quantity));
  }
}
