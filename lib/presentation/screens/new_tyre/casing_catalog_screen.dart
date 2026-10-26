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
import '../../../data/models/product_model.dart';
import '../../../widgets/clay_chip.dart';
import '../../../widgets/clay_shimmer.dart';
import '../../widgets/glass/liquid_glass_card.dart';
import '../../widgets/glass/liquid_glass_app_bar.dart';
import '../../widgets/glass/liquid_glass_status_badge.dart';
import '../../widgets/glass/customer_background.dart';
import '../home/product_search_delegate.dart';

class CasingCatalogScreen extends ConsumerStatefulWidget {
  const CasingCatalogScreen({super.key});
  @override
  ConsumerState<CasingCatalogScreen> createState() => _CasingCatalogScreenState();
}

class _CasingCatalogScreenState extends ConsumerState<CasingCatalogScreen> {
  final List<String> categories = ['All Casings', 'Truck', 'Bus', 'LCV', 'Tractor'];
  int _selectedCategoryIndex = 0;

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: LiquidGlassAppBar(
        title: 'Tyre Casings',
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
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: GestureDetector(
                onTap: () => showSearch(context: context, delegate: ProductSearchDelegate(ref)),
                child: LiquidGlassCard(
                  borderRadius: 20,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      const Icon(LucideIcons.search, color: AppColors.primary, size: 20),
                      const Gap(10),
                      Text(
                        'Search sound casing stock...',
                        style: AppTextStyles.body2.copyWith(color: AppColors.textTertiary),
                      ),
                      const Spacer(),
                      const Icon(LucideIcons.slidersHorizontal, color: AppColors.textSecondary, size: 18),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 52,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: categories.length,
                itemBuilder: (ctx, i) {
                  final sel = i == _selectedCategoryIndex;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ClayChip(
                      label: categories[i],
                      isSelected: sel,
                      onTap: () => setState(() => _selectedCategoryIndex = i),
                    ),
                  );
                },
              ),
            ),
            const Gap(8),
            Expanded(
              child: productState.when(
                data: (products) {
                  List<ProductModel> filtered = products
                      .where((p) => p.category.toLowerCase().contains('casing') || p.name.toLowerCase().contains('casing'))
                      .toList();
                  if (_selectedCategoryIndex != 0) {
                    final cat = categories[_selectedCategoryIndex].toLowerCase();
                    filtered = filtered.where((p) => p.category.toLowerCase().contains(cat)).toList();
                  }
                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(LucideIcons.disc, size: 48, color: AppColors.textTertiary),
                          const Gap(12),
                          Text('No casing stock found.', style: AppTextStyles.body1.copyWith(color: AppColors.textSecondary)),
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
                    itemBuilder: (ctx, i) => _card(ctx, filtered[i])
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
                error: (e, s) => Center(child: Text('Failed: $e', style: AppTextStyles.body2.copyWith(color: AppColors.error))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(BuildContext ctx, ProductModel p) {
    return LiquidGlassCard(
      onTap: () => ctx.push(AppRoutes.tyreDetail, extra: p.productId),
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
                child: const Stack(
                  children: [
                    Center(child: Icon(LucideIcons.disc, size: 48, color: AppColors.primary)),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: LiquidGlassStatusBadge(label: 'CASING', color: AppColors.primary),
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
                Text(p.size, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                const Gap(8),
                Text(
                  '₹${(p.discountedPrice ?? p.price).toStringAsFixed(0)}',
                  style: AppTextStyles.h3.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
