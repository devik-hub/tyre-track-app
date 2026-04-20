import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/product_model.dart';
import '../../data/models/booking_model.dart';
import '../../data/models/order_model.dart';
import 'product_provider.dart';
import 'booking_provider.dart';
import 'order_provider.dart';

/// Admin dashboard live stats derived from real-time streams
final adminStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final products = ref.watch(productStreamProvider).valueOrNull ?? [];
  final bookings = ref.watch(allBookingsProvider).valueOrNull ?? [];
  final orders = ref.watch(allOrdersProvider).valueOrNull ?? [];

  final pendingBookings = bookings.where((b) => b.status == 'pending').length;
  final activeRetreads = bookings.where((b) => b.status == 'in_progress').length;
  final lowStockProducts = products.where((p) => p.stockQuantity < 5).length;
  final totalRevenue = orders.fold<double>(0, (sum, o) => sum + o.totalAmount);

  return {
    'pendingBookings': pendingBookings,
    'activeRetreads': activeRetreads,
    'lowStock': lowStockProducts,
    'totalRevenue': totalRevenue,
    'totalProducts': products.length,
    'totalOrders': orders.length,
  };
});
