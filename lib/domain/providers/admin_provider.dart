import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/product_model.dart';
import '../../data/models/booking_model.dart';
import '../../data/models/order_model.dart';
import 'product_provider.dart';
import 'booking_provider.dart';
import 'order_provider.dart';
import 'inventory_settings_provider.dart';

/// Admin dashboard live stats derived from real-time streams
final adminStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final products = ref.watch(productStreamProvider).valueOrNull ?? [];
  final bookings = ref.watch(allBookingsProvider).valueOrNull ?? [];
  final orders   = ref.watch(allOrdersProvider).valueOrNull ?? [];
  final settings = ref.watch(inventorySettingsProvider).valueOrNull;

  final tyreThreshold   = settings?.tyreLowStockThreshold ?? 3;
  final casingThreshold = settings?.casingLowStockThreshold ?? 2;

  final pendingBookings  = bookings.where((b) => b.status == 'pending').length;
  final activeRetreads   = bookings.where((b) => b.status == 'in_progress').length;
  final lowStockProducts = products.where((p) {
    final threshold = p.category == 'casing' ? casingThreshold : tyreThreshold;
    return p.stockQuantity < threshold;
  }).length;
  final totalRevenue     = orders.fold<double>(0, (sum, o) => sum + o.totalAmount);

  // COD specific
  final codPendingOrders = orders.where((o) => o.paymentMethod == 'cod' && o.paymentStatus == 'pending').toList();
  final codOutstanding   = codPendingOrders.fold<double>(0, (sum, o) => sum + o.totalAmount);

  return {
    'pendingBookings': pendingBookings,
    'activeRetreads':  activeRetreads,
    'lowStock':        lowStockProducts,
    'lowStockCount':   lowStockProducts,
    'totalRevenue':    totalRevenue,
    'totalProducts':   products.length,
    'totalOrders':     orders.length,
    'codOutstanding':  codOutstanding,
    'codPendingCount': codPendingOrders.length,
    'revenue':         totalRevenue,
  };
});
