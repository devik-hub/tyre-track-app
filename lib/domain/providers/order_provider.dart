import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/order_model.dart';
import '../../data/repositories/order_repository.dart';
import 'auth_provider.dart';

/// Real-time stream of current user's orders
final userOrdersProvider = StreamProvider<List<OrderModel>>((ref) {
  final user = ref.watch(authProvider).userModel;
  if (user == null) return Stream.value([]);
  return ref.read(orderRepositoryProvider).streamUserOrders(user.uid);
});

/// Admin: Real-time stream of ALL orders
final allOrdersProvider = StreamProvider<List<OrderModel>>((ref) {
  return ref.read(orderRepositoryProvider).streamAllOrders();
});
