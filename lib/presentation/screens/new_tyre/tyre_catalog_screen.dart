import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../domain/providers/product_provider.dart';
import '../../../data/models/product_model.dart';

class TyreCatalogScreen extends ConsumerStatefulWidget {
  const TyreCatalogScreen({super.key});

  @override
  ConsumerState<TyreCatalogScreen> createState() => _TyreCatalogScreenState();
}

class _TyreCatalogScreenState extends ConsumerState<TyreCatalogScreen> {
  final List<String> categories = ['All', '2-Wheeler', 'Car', 'LCV', 'Truck/Bus'];
  int _selectedCategoryIndex = 0;

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productStreamProvider);

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
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final isSelected = index == _selectedCategoryIndex;
                return Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: ChoiceChip(
                    label: Text(categories[index]),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedCategoryIndex = index);
                    },
                    selectedColor: AppColors.mrfRed,
                    labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.mrfBlack),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: productState.when(
               data: (products) {
                  // Basic filtering mapping 
                  List<ProductModel> filtered = products;
                  if (_selectedCategoryIndex != 0) {
                     String mappedCategory = categories[_selectedCategoryIndex].toLowerCase();
                     filtered = products.where((p) => p.category.toLowerCase() == mappedCategory).toList();
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
                  const Center(child: Icon(Icons.tire_repair, size: 60, color: Colors.grey)),
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
