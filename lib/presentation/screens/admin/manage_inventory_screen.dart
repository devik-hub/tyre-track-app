import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../app/theme/app_colors.dart';
import '../../../data/models/product_model.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../domain/providers/product_provider.dart';

class ManageInventoryScreen extends ConsumerWidget {
  const ManageInventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.mrfBlack,
      appBar: AppBar(
        title: const Text('Inventory Control', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showProductBottomSheet(context, ref, null),
        backgroundColor: AppColors.mrfRed,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Product', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.mrfRed)),
        error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.red))),
        data: (products) {
          if (products.isEmpty) {
            return _buildEmptyState();
          }
          return RefreshIndicator(
            color: AppColors.mrfRed,
            backgroundColor: AppColors.mrfBlack,
            onRefresh: () async => ref.refresh(productStreamProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final p = products[index];
                final isLowStock = p.stockQuantity < 5;
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isLowStock ? Colors.red.withValues(alpha: 0.3) : Colors.white10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.tire_repair, color: isLowStock ? AppColors.mrfRed : Colors.white70, size: 30),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(child: Text(p.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                  Text('₹${p.price.toStringAsFixed(0)}', style: const TextStyle(color: AppColors.mrfRed, fontWeight: FontWeight.bold, fontSize: 16)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text('${p.brand} • ${p.size}', style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  _buildDataChip(isLowStock ? Colors.red : Colors.green, 'Stock: ${p.stockQuantity}'),
                                  const SizedBox(width: 8),
                                  _buildDataChip(Colors.blue, p.category.toUpperCase()),
                                ],
                              )
                            ],
                          ),
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, color: Colors.white54),
                          color: const Color(0xFF2C2C2C),
                          onSelected: (action) {
                            if (action == 'edit') _showProductBottomSheet(context, ref, p);
                            if (action == 'delete') _confirmDelete(context, ref, p);
                          },
                          itemBuilder: (_) => [
                            const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, color: Colors.white70, size: 18), SizedBox(width: 8), Text('Edit', style: TextStyle(color: Colors.white))])),
                            const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, color: AppColors.mrfRed, size: 18), SizedBox(width: 8), Text('Delete', style: TextStyle(color: AppColors.mrfRed))])),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildDataChip(Color color, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade800),
          const SizedBox(height: 16),
          const Text('Inventory is Empty', style: TextStyle(fontSize: 18, color: Colors.white70, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Tap the button below to add MRF products.', style: TextStyle(color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, ProductModel product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        title: const Text('Delete Product', style: TextStyle(color: Colors.white)),
        content: Text('Permanently delete "${product.name}"? This action cannot be undone.', style: TextStyle(color: Colors.grey.shade400)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Colors.white70))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.mrfRed),
            onPressed: () async {
              await ref.read(productRepositoryProvider).deleteProduct(product.productId);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showProductBottomSheet(BuildContext context, WidgetRef ref, ProductModel? existing) {
    final isEdit = existing != null;
    final nameC = TextEditingController(text: existing?.name ?? '');
    final brandC = TextEditingController(text: existing?.brand ?? 'MRF');
    final categoryC = TextEditingController(text: existing?.category ?? 'car');
    final sizeC = TextEditingController(text: existing?.size ?? '');
    final priceC = TextEditingController(text: existing?.price.toStringAsFixed(0) ?? '');
    final stockC = TextEditingController(text: existing?.stockQuantity.toString() ?? '0');
    final patternC = TextEditingController(text: existing?.treadPattern ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.8,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          builder: (_, controller) => Padding(
            padding: const EdgeInsets.all(24.0),
            child: ListView(
              controller: controller,
              children: [
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade600, borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 24),
                Text(isEdit ? 'Edit Product' : 'New Product Entry', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 24),
                _buildDarkTextField(nameC, 'Product Name *', Icons.inventory),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildDarkTextField(brandC, 'Brand', Icons.branding_watermark)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildDarkTextField(categoryC, 'Category', Icons.category)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildDarkTextField(sizeC, 'Size *', Icons.straighten)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildDarkTextField(patternC, 'Tread Pattern', Icons.texture)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildDarkTextField(priceC, 'Price (₹) *', Icons.currency_rupee, isNumber: true)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildDarkTextField(stockC, 'Stock Count *', Icons.format_list_numbered, isNumber: true)),
                  ],
                ),
                const SizedBox(height: 32),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.mrfRed, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    onPressed: () async {
                      if (nameC.text.isEmpty || sizeC.text.isEmpty || priceC.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all required fields (*)')));
                        return;
                      }
                      final product = ProductModel(
                        productId: existing?.productId ?? const Uuid().v4(),
                        name: nameC.text.trim(),
                        brand: brandC.text.trim(),
                        category: categoryC.text.trim(),
                        size: sizeC.text.trim(),
                        loadIndex: existing?.loadIndex ?? 0,
                        speedRating: existing?.speedRating ?? '',
                        treadPattern: patternC.text.trim(),
                        price: double.tryParse(priceC.text) ?? 0,
                        stockQuantity: int.tryParse(stockC.text) ?? 0,
                        imageUrls: existing?.imageUrls ?? [],
                        specifications: existing?.specifications ?? {},
                        isActive: true,
                        isFeatured: existing?.isFeatured ?? false,
                        createdAt: existing?.createdAt ?? DateTime.now(),
                      );
                      
                      try {
                         if (isEdit) {
                           await ref.read(productRepositoryProvider).updateProduct(product);
                         } else {
                           await ref.read(productRepositoryProvider).createProduct(product);
                         }
                         if (ctx.mounted) Navigator.pop(ctx);
                      } catch (e) {
                         if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Error saving: $e')));
                      }
                    },
                    child: Text(isEdit ? 'UPDATE PRODUCT' : 'CREATE PRODUCT', style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDarkTextField(TextEditingController controller, String label, IconData icon, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
        prefixIcon: Icon(icon, color: Colors.grey.shade600, size: 20),
        filled: true,
        fillColor: const Color(0xFF2C2C2C),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.mrfRed, width: 1)),
      ),
    );
  }
}
