import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
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
    return Scaffold(
      appBar: AppBar(title: const Text('Product Detail')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 250,
              color: Colors.grey[200],
              child: const Center(child: Icon(Icons.tire_repair, size: 100, color: Colors.grey)),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    color: AppColors.mrfRed,
                    child: const Text('MRF Zapper', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 8),
                  const Text('195/65 R15', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: const [
                      Text('₹2,400', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.mrfRed)),
                      SizedBox(width: 8),
                      Text('₹2,800', style: TextStyle(fontSize: 16, decoration: TextDecoration.lineThrough, color: Colors.grey)),
                    ],
                  ),
                  const Divider(height: 32),
                  const Text('Specifications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildSpecRow('Load Index', '91'),
                  _buildSpecRow('Speed Rating', 'V'),
                  _buildSpecRow('Tread Pattern', 'Asymmetrical'),
                  const Divider(height: 32),
                  Row(
                    children: [
                      const Text('Quantity', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      IconButton(onPressed: () => setState(() { if(_quantity>1) _quantity--;}), icon: const Icon(Icons.remove_circle_outline)),
                      Text('$_quantity', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      IconButton(onPressed: () => setState(() => _quantity++), icon: const Icon(Icons.add_circle_outline)),
                    ],
                  )
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
                  onPressed: () {},
                  child: const Text('Add to Cart'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
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
