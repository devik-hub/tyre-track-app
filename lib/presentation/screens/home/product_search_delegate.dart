import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/routes/app_routes.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/search_insight_model.dart';
import '../../../domain/providers/product_provider.dart';
import '../../../domain/providers/auth_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductSearchDelegate extends SearchDelegate<String> {
  final WidgetRef ref;
  String _lastLoggedQuery = ''; // Debounce helper

  ProductSearchDelegate(this.ref);

  @override
  String get searchFieldLabel => 'Search tyres, casings, features...';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, ''),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context, isSuggestion: true);
  }

  void _logSearch(String q, List<ProductModel> results) {
    final trimQ = q.trim();
    if (trimQ.isEmpty || _lastLoggedQuery == trimQ) return;
    _lastLoggedQuery = trimQ;

    final user = ref.read(authProvider).userModel;
    final entry = SearchLogEntry(
      query: trimQ,
      userId: user?.uid ?? 'guest',
      resultsCount: results.length,
      resultIds: results.map((p) => p.productId).toList(),
    );

    FirebaseFirestore.instance
        .collection('search_logs')
        .add(entry.toMap());
  }

  Widget _buildSearchResults(BuildContext context, {bool isSuggestion = false}) {
    if (query.trim().isEmpty) {
      return const Center(child: Text('Start typing to search available products', style: TextStyle(color: Colors.grey)));
    }

    final productState = ref.read(productStreamProvider);

    return productState.when(
      data: (products) {
        final lowerQuery = query.toLowerCase();
        final results = products.where((p) {
          return p.name.toLowerCase().contains(lowerQuery) ||
                 p.brand.toLowerCase().contains(lowerQuery) ||
                 p.size.toLowerCase().contains(lowerQuery) ||
                 p.category.toLowerCase().contains(lowerQuery);
        }).toList();

        if (!isSuggestion) {
          _logSearch(query, results);
        }

        if (results.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.search_off, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text('No results found for "$query"'),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final product = results[index];
            return ListTile(
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.tire_repair, color: AppColors.mrfBlack),
              ),
              title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${product.brand} • ${product.size}'),
              trailing: Text('₹${product.price}', style: const TextStyle(color: AppColors.mrfRed, fontWeight: FontWeight.bold)),
              onTap: () {
                close(context, '');
                context.push(AppRoutes.tyreDetail, extra: product.productId);
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.mrfRed)),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }
}
