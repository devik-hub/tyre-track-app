import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/routes/app_routes.dart';
import '../../../domain/providers/product_provider.dart';
import '../../../data/models/product_model.dart';
import '../home/product_search_delegate.dart';

class CasingCatalogScreen extends ConsumerStatefulWidget {
  const CasingCatalogScreen({super.key});

  @override
  ConsumerState<CasingCatalogScreen> createState() => _CasingCatalogScreenState();
}

class _CasingCatalogScreenState extends ConsumerState<CasingCatalogScreen> {
  final List<String> categories = ['All', 'Truck', 'Bus', 'LCV', 'Tractor'];
  int _selectedCategoryIndex = 0;

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productStreamProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go(AppRoutes.home)),
        title: const Text('Buy Casings'),
        actions: [
          IconButton(icon: const Icon(Icons.shopping_cart), onPressed: () => context.push(AppRoutes.cart)),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: InkWell(
              onTap: () {
                showSearch(context: context, delegate: ProductSearchDelegate(ref));
              },
              child: IgnorePointer(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search casings...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: const Icon(Icons.filter_list),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
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
                  // Filter strictly for Casing items (if backend schema eventually uses category=casing, we can mock it by matching naming)
                  // For now, we assume Casings are products containing "Casing" or "Remould" in their name, or category == 'casing'.
                  List<ProductModel> filtered = products.where((p) => p.category.toLowerCase().contains('casing') || p.name.toLowerCase().contains('casing')).toList();
                  
                  if (_selectedCategoryIndex != 0) {
                     String mappedCategory = categories[_selectedCategoryIndex].toLowerCase();
                     filtered = filtered.where((p) => p.category.toLowerCase().contains(mappedCategory)).toList();
                  }

                  if (filtered.isEmpty) {
                     return const Center(child: Text('No casings found in this category.'));
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
               error: (e, s) => Center(child: Text('Failed to load casings: $e')),
            )
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, ProductModel product) {
    return InkWell(
      onTap: () => context.push(AppRoutes.tyreDetail, extra: product.productId),
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
                  const Center(child: Icon(Icons.circle_outlined, size: 60, color: Colors.grey)), // distinct icon
                  Positioned(
                    top: 8, left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      color: AppColors.mrfBlack,
                      child: const Text('CASING', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
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
                Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(product.size, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('₹${product.discountedPrice ?? product.price}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.mrfRed, fontSize: 14)),
                      ],
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
