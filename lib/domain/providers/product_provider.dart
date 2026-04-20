import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/product_repository.dart';

/// Real-time stream of all products from Firestore
final productStreamProvider = StreamProvider<List<ProductModel>>((ref) {
  return ref.read(productRepositoryProvider).streamProducts();
});

/// Single product by ID (derived from stream)
final productByIdProvider = Provider.family<ProductModel?, String>((ref, productId) {
  final products = ref.watch(productStreamProvider).valueOrNull ?? [];
  try {
    return products.firstWhere((p) => p.productId == productId);
  } catch (_) {
    return null;
  }
});
