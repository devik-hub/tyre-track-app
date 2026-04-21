import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../domain/providers/product_provider.dart';
import '../../../domain/providers/cart_provider.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final product = ref.watch(productByIdProvider(widget.productId));

    if (product == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Product Detail'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: const Center(child: Text('Product not found', style: TextStyle(color: Colors.grey, fontSize: 16))),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 250,
              color: Colors.grey[200],
              child: product.imageUrls.isNotEmpty
                  ? Image.network(product.imageUrls.first, fit: BoxFit.contain,
                      errorBuilder: (c, e, s) => const Center(child: Icon(Icons.tire_repair, size: 100, color: Colors.grey)))
                  : const Center(child: Icon(Icons.tire_repair, size: 100, color: Colors.grey)),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    color: AppColors.mrfRed,
                    child: Text(product.brand, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 8),
                  Text(product.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(product.size, style: const TextStyle(fontSize: 16, color: Colors.grey)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text('₹${(product.discountedPrice ?? product.price).toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.mrfRed)),
                      if (product.discountedPrice != null) ...[
                        const SizedBox(width: 8),
                        Text('₹${product.price.toStringAsFixed(0)}',
                            style: const TextStyle(fontSize: 16, decoration: TextDecoration.lineThrough, color: Colors.grey)),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: product.stockQuantity > 0 ? Colors.green.shade100 : Colors.red.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      product.stockQuantity > 0 ? '${product.stockQuantity} in stock' : 'Out of stock',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: product.stockQuantity > 0 ? Colors.green : Colors.red),
                    ),
                  ),
                  const Divider(height: 32),
                  const Text('Specifications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildSpecRow('Category', product.category.toUpperCase()),
                  _buildSpecRow('Size', product.size),
                  if (product.loadIndex > 0) _buildSpecRow('Load Index', '${product.loadIndex}'),
                  if (product.speedRating.isNotEmpty) _buildSpecRow('Speed Rating', product.speedRating),
                  if (product.treadPattern.isNotEmpty) _buildSpecRow('Tread Pattern', product.treadPattern),
                  ...product.specifications.entries.map((e) => _buildSpecRow(e.key, e.value)),
                  const Divider(height: 32),
                  Row(
                    children: [
                      const Text('Quantity', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      IconButton(
                        onPressed: () => setState(() { if (_quantity > 1) _quantity--; }),
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Text('$_quantity', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      IconButton(
                        onPressed: () => setState(() => _quantity++),
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: product.stockQuantity > 0
                      ? () {
                          ref.read(cartProvider.notifier).addToCart(product, _quantity);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${product.name} added to cart'), duration: const Duration(seconds: 2)),
                          );
                        }
                      : null,
                  child: const Text('Add to Cart'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: product.stockQuantity > 0
                      ? () {
                          ref.read(cartProvider.notifier).addToCart(product, _quantity);
                          context.push('/cart');
                        }
                      : null,
                  child: const Text('Buy Now'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
