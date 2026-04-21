import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../app/theme/app_colors.dart';
import '../../../data/models/product_model.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../domain/providers/product_provider.dart';
import '../../../domain/providers/search_analytics_provider.dart';
import '../../../domain/providers/inventory_settings_provider.dart';

class ManageInventoryScreen extends ConsumerStatefulWidget {
  const ManageInventoryScreen({super.key});

  @override
  ConsumerState<ManageInventoryScreen> createState() => _ManageInventoryScreenState();
}

class _ManageInventoryScreenState extends ConsumerState<ManageInventoryScreen> {
  bool _showInsights = false;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.mrfBlack,
        appBar: AppBar(
          title: const Text('Inventory Control', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              icon: Icon(_showInsights ? Icons.insights : Icons.insights_outlined, color: _showInsights ? AppColors.mrfRed : Colors.white),
              onPressed: () => setState(() => _showInsights = !_showInsights),
              tooltip: 'Search Insights',
            ),
          ],
          bottom: const TabBar(
            indicatorColor: AppColors.mrfRed,
            labelColor: AppColors.mrfRed,
            unselectedLabelColor: Colors.white54,
            tabs: [
              Tab(text: 'TYRES'),
              Tab(text: 'CASINGS'),
              Tab(text: 'ALL'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showProductBottomSheet(context, ref, null),
          backgroundColor: AppColors.mrfRed,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('New Product', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        body: Column(
          children: [
            if (_showInsights) _buildSearchInsightsPanel(),
            Expanded(
              child: ref.watch(productStreamProvider).when(
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.mrfRed)),
                error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.red))),
                data: (products) {
                  return TabBarView(
                    children: [
                      _buildProductList(products.where((p) => p.category != 'casing').toList()),
                      _buildProductList(products.where((p) => p.category == 'casing').toList()),
                      _buildProductList(products),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchInsightsPanel() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white.withValues(alpha: 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Search Insights (Last 30 Days)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: Row(
              children: [
                Expanded(
                  child: _buildInsightList('Top Searches', ref.watch(topSearchQueriesProvider), false),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInsightList('Zero Result Searches', ref.watch(zeroResultSearchesProvider), true),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightList(String title, AsyncValue<List<dynamic>> asyncData, bool isZeroResults) {
    return Container(
      decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(isZeroResults ? Icons.search_off : Icons.trending_up, size: 14, color: isZeroResults ? Colors.amber : Colors.green),
              const SizedBox(width: 4),
              Text(title, style: TextStyle(color: Colors.grey.shade400, fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: asyncData.when(
              loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
              error: (e, _) => Text('Error', style: TextStyle(color: Colors.red.shade300, fontSize: 10)),
              data: (insights) {
                if (insights.isEmpty) return Center(child: Text('No data', style: TextStyle(color: Colors.grey.shade600, fontSize: 11)));
                return ListView.builder(
                  itemCount: insights.length,
                  itemBuilder: (ctx, i) {
                    final item = insights[i];
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(item.query, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 12))),
                        Text('${item.count}', style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList(List<ProductModel> products) {
    if (products.isEmpty) return _buildEmptyState();
    
    final settings = ref.watch(inventorySettingsProvider).valueOrNull;
    final tyreThreshold = settings?.tyreLowStockThreshold ?? 3;
    final casingThreshold = settings?.casingLowStockThreshold ?? 2;

    return RefreshIndicator(
      color: AppColors.mrfRed,
      backgroundColor: AppColors.mrfBlack,
      onRefresh: () async => ref.refresh(productStreamProvider),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final p = products[index];
          final threshold = p.category == 'casing' ? casingThreshold : tyreThreshold;
          final isLowStock = p.stockQuantity < threshold;

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
                    child: Icon(p.category == 'casing' ? Icons.circle : Icons.tire_repair, color: isLowStock ? AppColors.mrfRed : Colors.white70, size: 30),
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
                            if (p.isFeatured) ...[
                              const SizedBox(width: 8),
                              _buildDataChip(Colors.amber, 'FEATURED'),
                            ]
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
    String _category = existing?.category ?? 'car'; // Dropdown state
    final sizeC = TextEditingController(text: existing?.size ?? '');
    final priceC = TextEditingController(text: existing?.price.toStringAsFixed(0) ?? '');
    final stockC = TextEditingController(text: existing?.stockQuantity.toString() ?? '0');
    final patternC = TextEditingController(text: existing?.treadPattern ?? '');

    // Casing fields
    String _casingCondition = existing?.casingCondition ?? 'Grade A';
    String _casingSource = existing?.casingSource ?? 'Customer Return';
    final cyclesC = TextEditingController(text: existing?.maxRetreadCycles?.toString() ?? '1');
    final compatC = TextEditingController(text: existing?.compatibleTyreSizes.join(', ') ?? '');
    bool _isFeatured = existing?.isFeatured ?? false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (_, controller) => Padding(
            padding: const EdgeInsets.all(24.0),
            child: StatefulBuilder(
              builder: (ctx, setModalState) {
                final isCasing = _category == 'casing';

                return ListView(
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
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _category,
                            dropdownColor: const Color(0xFF2C2C2C),
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Category',
                              labelStyle: TextStyle(color: Colors.grey.shade500),
                              filled: true,
                              fillColor: const Color(0xFF2C2C2C),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            ),
                            items: ['2-wheeler', 'car', 'lcv', 'truck', 'casing']
                                .map((s) => DropdownMenuItem(value: s, child: Text(s.toUpperCase())))
                                .toList(),
                            onChanged: (v) => setModalState(() => _category = v!),
                          ),
                        ),
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

                    if (isCasing) ...[
                      const SizedBox(height: 32),
                      const Text('CASING SPECIFICATIONS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.5)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _casingCondition,
                              dropdownColor: const Color(0xFF2C2C2C),
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                              decoration: InputDecoration(
                                labelText: 'Condition',
                                labelStyle: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                                filled: true,
                                fillColor: const Color(0xFF2C2C2C),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              ),
                              items: ['Grade A', 'Grade B', 'Grade C'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                              onChanged: (v) => setModalState(() => _casingCondition = v!),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _casingSource,
                              dropdownColor: const Color(0xFF2C2C2C),
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                              decoration: InputDecoration(
                                labelText: 'Source',
                                labelStyle: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                                filled: true,
                                fillColor: const Color(0xFF2C2C2C),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              ),
                              items: ['In-House', 'Customer Return', 'Purchased'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                              onChanged: (v) => setModalState(() => _casingSource = v!),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildDarkTextField(cyclesC, 'Max Retread Cycles (e.g. 1, 2)', Icons.autorenew, isNumber: true),
                      const SizedBox(height: 16),
                      _buildDarkTextField(compatC, 'Compatible Tyres (comma separated)', Icons.link),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Feature this casing on Home Screen?', style: TextStyle(color: Colors.white, fontSize: 14)),
                        activeColor: AppColors.mrfRed,
                        value: _isFeatured,
                        onChanged: (val) => setModalState(() => _isFeatured = val),
                      ),
                    ],

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
                            category: _category.trim(),
                            size: sizeC.text.trim(),
                            loadIndex: existing?.loadIndex ?? 0,
                            speedRating: existing?.speedRating ?? '',
                            treadPattern: patternC.text.trim(),
                            price: double.tryParse(priceC.text) ?? 0,
                            stockQuantity: int.tryParse(stockC.text) ?? 0,
                            imageUrls: existing?.imageUrls ?? [],
                            specifications: existing?.specifications ?? {},
                            isActive: true,
                            createdAt: existing?.createdAt ?? DateTime.now(),
                            // Derived from state
                            isFeatured: isCasing ? _isFeatured : existing?.isFeatured ?? false,
                            casingCondition: isCasing ? _casingCondition : null,
                            casingSource: isCasing ? _casingSource : null,
                            maxRetreadCycles: isCasing ? int.tryParse(cyclesC.text) : null,
                            compatibleTyreSizes: isCasing ? compatC.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList() : [],
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
                );
              }
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDarkTextField(TextEditingController controller, String label, IconData icon, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white, fontSize: 13),
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
