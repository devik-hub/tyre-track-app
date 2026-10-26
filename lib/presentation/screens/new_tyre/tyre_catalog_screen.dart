import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../app/routes/app_routes.dart';
import '../../../domain/providers/product_provider.dart';
import '../../../domain/providers/vehicle_category_provider.dart';
import '../../../data/models/product_model.dart';
import '../../../widgets/clay_chip.dart';
import '../../../widgets/clay_shimmer.dart';
import '../../widgets/glass/liquid_glass_card.dart';
import '../../widgets/glass/liquid_glass_app_bar.dart';
import '../../widgets/glass/liquid_glass_status_badge.dart';
import '../../widgets/glass/customer_background.dart';

class TyreCatalogScreen extends ConsumerStatefulWidget {
  const TyreCatalogScreen({super.key});
  @override
  ConsumerState<TyreCatalogScreen> createState() => _TyreCatalogScreenState();
}

class _TyreCatalogScreenState extends ConsumerState<TyreCatalogScreen> {
  int _selectedCategoryIndex = 0;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productStreamProvider);
    final categoriesAsync = ref.watch(vehicleCategoryStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: LiquidGlassAppBar(
        title: 'MRF Tyre Catalog',
        showBrandSubtitle: true,
        leading: GestureDetector(
          onTap: () => context.go(AppRoutes.home),
          child: Container(
            width: 38,
            height: 38,
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1),
            ),
            child: const Icon(LucideIcons.chevronLeft, size: 20, color: Colors.white),
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () => context.push(AppRoutes.cart),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1),
              ),
              child: const Icon(LucideIcons.shoppingCart, size: 18, color: Colors.white),
            ),
          ),
          const Gap(12),
        ],
      ),
      body: CustomerBackground(
        child: Column(
          children: [
            // Search field
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: LiquidGlassCard(
                borderRadius: 20,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                  style: AppTextStyles.bodyMedium,
                  decoration: InputDecoration(
                    hintText: 'Search by tyre model, rim size (e.g. 10.00-20)...',
                    hintStyle: AppTextStyles.body2.copyWith(color: AppColors.textTertiary),
                    prefixIcon: const Icon(LucideIcons.search, color: AppColors.primary, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(LucideIcons.x, size: 16, color: AppColors.textSecondary),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : const Icon(LucideIcons.slidersHorizontal, color: AppColors.textSecondary, size: 18),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ),
            ),
            // Category Chips
            SizedBox(
              height: 52,
              child: categoriesAsync.when(
                loading: () => const Center(
                  child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)),
                ),
                error: (e, _) => Center(
                  child: Text('Failed to load categories', style: AppTextStyles.body2.copyWith(color: AppColors.textTertiary)),
                ),
                data: (fc) {
                  final names = ['All Tyres', ...fc.map((c) => c.name)];
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: names.length,
                    itemBuilder: (ctx, i) {
                      final sel = i == _selectedCategoryIndex;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ClayChip(
                          label: names[i],
                          isSelected: sel,
                          onTap: () => setState(() => _selectedCategoryIndex = i),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const Gap(8),
            // Product Grid
            Expanded(
              child: productState.when(
                data: (products) {
                  List<ProductModel> filtered = products.where((p) => p.category != 'casing').toList();
                  if (_selectedCategoryIndex != 0) {
                    final cv = ref.read(vehicleCategoryStreamProvider).valueOrNull ?? [];
                    if (_selectedCategoryIndex - 1 < cv.length) {
                      final catName = cv[_selectedCategoryIndex - 1].name.toLowerCase();
                      filtered = filtered.where((p) => p.category.toLowerCase() == catName).toList();
                    }
                  }
                  if (_searchQuery.isNotEmpty) {
                    filtered = filtered.where((p) =>
                        p.name.toLowerCase().contains(_searchQuery) ||
                        p.size.toLowerCase().contains(_searchQuery) ||
                        p.brand.toLowerCase().contains(_searchQuery)).toList();
                  }

                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(LucideIcons.disc, size: 48, color: AppColors.textTertiary),
                          const Gap(12),
                          Text('No tyres match your filter.', style: AppTextStyles.body1.copyWith(color: AppColors.textSecondary)),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.65,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) => _productCard(ctx, filtered[i])
                        .animate().fadeIn(duration: 250.ms, delay: (i % 6 * 40).ms).slideY(begin: 0.05, end: 0),
                  );
                },
                loading: () => GridView.count(
                  crossAxisCount: 2,
                  padding: const EdgeInsets.all(20),
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.65,
                  children: List.generate(4, (_) => const ClayShimmerCard(borderRadius: 22)),
                ),
                error: (e, s) => Center(
                  child: Text('Failed: $e', style: AppTextStyles.body2.copyWith(color: AppColors.error)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _productCard(BuildContext ctx, ProductModel p) {
    return LiquidGlassCard(
      onTap: () => ctx.push('/tyre_detail', extra: p.productId),
      padding: EdgeInsets.zero,
      borderRadius: 22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
              child: Container(
                color: AppColors.surface,
                width: double.infinity,
                child: Stack(
                  children: [
                    Center(
                      child: p.imageUrls.isNotEmpty
                          ? Image.network(
                              p.imageUrls.first,
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => const Icon(LucideIcons.disc, size: 44, color: AppColors.textTertiary),
                            )
                          : const Icon(LucideIcons.disc, size: 44, color: AppColors.textTertiary),
                    ),
                    const Positioned(
                      top: 10,
                      left: 10,
                      child: LiquidGlassStatusBadge(label: 'MRF', color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.name,
                  style: AppTextStyles.label1.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Gap(2),
                Text(
                  p.size,
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
                const Gap(8),
                Row(
                  children: [
                    Text(
                      '₹${(p.discountedPrice ?? p.price).toStringAsFixed(0)}',
                      style: AppTextStyles.h3.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
                    ),
                    if (p.discountedPrice != null) ...[
                      const Gap(6),
                      Text(
                        '₹${p.price.toStringAsFixed(0)}',
                        style: AppTextStyles.bodySmall.copyWith(
                          decoration: TextDecoration.lineThrough,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
