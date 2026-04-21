import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/product_repository.dart';

/// Real-time stream of ALL active products from Firestore
final productStreamProvider = StreamProvider<List<ProductModel>>((ref) {
  return ref.read(productRepositoryProvider).streamProducts();
});

/// Real-time stream of casing products only
final casingProductsProvider = StreamProvider<List<ProductModel>>((ref) {
  return ref.read(productRepositoryProvider).streamProductsByCategory('casing');
});

/// Real-time stream of featured casings — consumed by HomeScreen
final featuredCasingsProvider = StreamProvider<List<ProductModel>>((ref) {
  return ref.read(productRepositoryProvider).streamFeaturedCasings();
});

/// Single product by ID (derived from stream cache — zero extra reads)
final productByIdProvider = Provider.family<ProductModel?, String>((ref, productId) {
  final products = ref.watch(productStreamProvider).valueOrNull ?? [];
  try {
    return products.firstWhere((p) => p.productId == productId);
  } catch (_) {
    return null;
  }
});
