import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/product_repository.dart';

final productProvider = StateNotifierProvider<ProductNotifier, AsyncValue<List<ProductModel>>>((ref) {
  return ProductNotifier(ref.read(productRepositoryProvider));
});

class ProductNotifier extends StateNotifier<AsyncValue<List<ProductModel>>> {
  final ProductRepository _productRepo;

  ProductNotifier(this._productRepo) : super(const AsyncValue.loading()) {
    loadProducts();
  }

  Future<void> loadProducts() async {
    state = const AsyncValue.loading();
    try {
      final products = await _productRepo.getProducts();
      state = AsyncValue.data(products);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
