import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/order_model.dart';
import '../../data/models/product_model.dart';

final cartProvider = StateNotifierProvider<CartNotifier, List<OrderItem>>((ref) {
  return CartNotifier();
});

class CartNotifier extends StateNotifier<List<OrderItem>> {
  CartNotifier() : super([]);

  void addToCart(ProductModel product, int quantity) {
    final index = state.indexWhere((item) => item.productId == product.productId);
    // Price stored in paise — ProductModel.price is double rupees, convert
    final unitPricePaise = ((product.discountedPrice ?? product.price) * 100).round();
    if (index >= 0) {
      final current = state[index];
      final newQty = current.quantity + quantity;
      final updated = OrderItem(
        productId:   current.productId,
        productName: current.productName,
        quantity:    newQty,
        unitPrice:   current.unitPrice,
        totalPrice:  current.unitPrice * newQty,
        category:    current.category,
      );
      final newState = [...state];
      newState[index] = updated;
      state = newState;
    } else {
      state = [
        ...state,
        OrderItem(
          productId:   product.productId,
          productName: product.name,
          quantity:    quantity,
          unitPrice:   unitPricePaise,
          totalPrice:  unitPricePaise * quantity,
          category:    product.category,
        ),
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
      final updated = OrderItem(
        productId:   current.productId,
        productName: current.productName,
        quantity:    newQuantity,
        unitPrice:   current.unitPrice,
        totalPrice:  current.unitPrice * newQuantity,
        category:    current.category,
      );
      final newState = [...state];
      newState[index] = updated;
      state = newState;
    }
  }

  void clear() => state = [];

  /// Total in rupees (for display)
  double get totalAmount =>
      state.fold(0.0, (total, item) => total + item.totalPriceRupees);

  /// Total in paise (for Firestore writes)
  int get totalAmountPaise =>
      state.fold(0, (total, item) => total + item.totalPrice);
}
