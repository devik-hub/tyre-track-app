import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../domain/providers/product_provider.dart';
import '../../../domain/providers/vehicle_category_provider.dart';
import '../../../data/models/product_model.dart';

class TyreCatalogScreen extends ConsumerStatefulWidget {
  const TyreCatalogScreen({super.key});

  @override
  ConsumerState<TyreCatalogScreen> createState() => _TyreCatalogScreenState();
}

class _TyreCatalogScreenState extends ConsumerState<TyreCatalogScreen> {
  int _selectedCategoryIndex = 0;

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productStreamProvider);
    final categoriesAsync = ref.watch(vehicleCategoryStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buy Tyres'),
        actions: [
          IconButton(icon: const Icon(Icons.shopping_cart), onPressed: () => context.push('/cart')),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by size, model, vehicle type...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: const Icon(Icons.filter_list),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          // Dynamic category chips from Firestore
          SizedBox(
            height: 50,
            child: categoriesAsync.when(
              loading: () => const Center(
                child: SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.mrfRed),
                ),
              ),
              error: (e, _) => Center(
                child: Text('Failed to load categories', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              ),
              data: (firestoreCategories) {
                // Build the display list: "All" + categories from Firestore
                final categoryNames = ['All', ...firestoreCategories.map((c) => c.name)];

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categoryNames.length,
                  itemBuilder: (context, index) {
                    final isSelected = index == _selectedCategoryIndex;
                    return Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: ChoiceChip(
                        label: Text(categoryNames[index]),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() => _selectedCategoryIndex = index);
                        },
                        selectedColor: AppColors.mrfRed,
                        labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.mrfBlack),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Expanded(
            child: productState.when(
               data: (products) {
                 // Filter products by selected category
                 List<ProductModel> filtered = products;

                 if (_selectedCategoryIndex != 0) {
                   final categoriesValue = ref.read(vehicleCategoryStreamProvider).valueOrNull ?? [];
                   if (_selectedCategoryIndex - 1 < categoriesValue.length) {
                     final selectedCategoryName = categoriesValue[_selectedCategoryIndex - 1].name.toLowerCase();
                     filtered = products.where((p) => p.category.toLowerCase() == selectedCategoryName).toList();
                   }
                 }

                 if (filtered.isEmpty) {
                    return const Center(child: Text('No tyres found in this category.'));
                 }

                 return GridView.builder(
                   padding: const EdgeInsets.all(16),
                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                     crossAxisCount: 2,
                     childAspectRatio: 0.7,
                     crossAxisSpacing: 16,
                     mainAxisSpacing: 16,
                   ),
                   itemCount: filtered.length,
                   itemBuilder: (context, index) {
                     return _buildProductCard(context, filtered[index]);
                   },
                 );
               },
               loading: () => const Center(child: CircularProgressIndicator(color: AppColors.mrfRed)),
               error: (e, s) => Center(child: Text('Failed to load products: $e')),
            )
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, ProductModel product) {
    return InkWell(
      onTap: () => context.push('/tyre_detail', extra: product.productId),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Expanded(
            child: Container(
              color: Colors.grey[200],
              child: Stack(
                children: [
                  Center(
                    child: product.imageUrls.isNotEmpty
                        ? Image.network(product.imageUrls.first, fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => const Icon(Icons.tire_repair, size: 60, color: Colors.grey))
                        : const Icon(Icons.tire_repair, size: 60, color: Colors.grey),
                  ),
                  Positioned(
                    top: 8, left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      color: AppColors.mrfRed,
                      child: const Text('MRF', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(product.size, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('₹${product.discountedPrice ?? product.price}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.mrfRed, fontSize: 14)),
                        if (product.discountedPrice != null) 
                           Text('₹${product.price}', style: const TextStyle(fontSize: 10, decoration: TextDecoration.lineThrough, color: Colors.grey)),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_shopping_cart, color: AppColors.mrfRed),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {}, // Handled deeper inside detail view usually
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}
