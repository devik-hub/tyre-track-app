import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../domain/providers/product_provider.dart';
import '../../../domain/providers/cart_provider.dart';
import '../../widgets/glass/liquid_glass_card.dart';
import '../../widgets/glass/liquid_glass_app_bar.dart';
import '../../widgets/glass/liquid_glass_button.dart';
import '../../widgets/glass/liquid_glass_status_badge.dart';
import '../../widgets/glass/customer_background.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});
  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _quantity = 1;
  int _currentImageIndex = 0;
  final _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final product = ref.watch(productByIdProvider(widget.productId));
    if (product == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: CustomerBackground(
          child: Center(
            child: Text('Product not found', style: AppTextStyles.body1.copyWith(color: AppColors.textTertiary)),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomerBackground(
        child: Column(
          children: [
            LiquidGlassAppBar(
              title: product.name,
              showBrandSubtitle: true,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      height: 270,
                      color: AppColors.surface,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (product.imageUrls.isNotEmpty)
                            PageView.builder(
                              controller: _pageController,
                              itemCount: product.imageUrls.length,
                              onPageChanged: (idx) => setState(() => _currentImageIndex = idx),
                              itemBuilder: (ctx, idx) => Padding(
                                padding: const EdgeInsets.all(16),
                                child: Image.network(
                                  product.imageUrls[idx],
                                  fit: BoxFit.contain,
                                  errorBuilder: (c, e, s) => const Center(
                                    child: Icon(LucideIcons.disc, size: 80, color: AppColors.textTertiary),
                                  ),
                                ),
                              ),
                            )
                          else
                            const Center(child: Icon(LucideIcons.disc, size: 80, color: AppColors.textTertiary)),
                          if (product.imageUrls.length > 1)
                            Positioned(
                              bottom: 12,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(product.imageUrls.length, (i) {
                                  final isSelected = i == _currentImageIndex;
                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    margin: const EdgeInsets.symmetric(horizontal: 4),
                                    width: isSelected ? 22 : 7,
                                    height: 7,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      color: isSelected ? AppColors.primary : AppColors.primary.withValues(alpha: 0.25),
                                    ),
                                  );
                                }),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              LiquidGlassStatusBadge(label: product.brand, color: AppColors.primary),
                              LiquidGlassStatusBadge(
                                label: product.stockQuantity > 0 ? '${product.stockQuantity} in stock' : 'Out of stock',
                                color: product.stockQuantity > 0 ? AppColors.success : AppColors.error,
                                glow: product.stockQuantity > 0,
                              ),
                            ],
                          ),
                          const Gap(12),
                          Text(product.name, style: AppTextStyles.h1.copyWith(color: AppColors.textPrimary)),
                          const Gap(4),
                          Text(product.size, style: AppTextStyles.body1.copyWith(color: AppColors.textSecondary)),
                          const Gap(16),
                          Row(
                            children: [
                              Text(
                                '₹${(product.discountedPrice ?? product.price).toStringAsFixed(0)}',
                                style: AppTextStyles.display2.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
                              ),
                              if (product.discountedPrice != null) ...[
                                const Gap(10),
                                Text(
                                  '₹${product.price.toStringAsFixed(0)}',
                                  style: AppTextStyles.body1.copyWith(
                                    decoration: TextDecoration.lineThrough,
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const Gap(24),
                          // Specifications card
                          LiquidGlassCard(
                            borderRadius: 24,
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Specifications', style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary)),
                                const Gap(14),
                                _specRow('Category', product.category.toUpperCase()),
                                _specRow('Tyre Dimension', product.size),
                                if (product.loadIndex > 0) _specRow('Load Index', '${product.loadIndex}'),
                                if (product.speedRating.isNotEmpty) _specRow('Speed Rating', product.speedRating),
                                if (product.treadPattern.isNotEmpty) _specRow('Tread Pattern', product.treadPattern),
                                ...product.specifications.entries.map((e) => _specRow(e.key, e.value)),
                              ],
                            ),
                          ),
                          const Gap(16),
                          // Quantity selector card
                          LiquidGlassCard(
                            borderRadius: 20,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            child: Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Quantity', style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary)),
                                    if (product.stockQuantity > 0)
                                      Text('${product.stockQuantity} in stock',
                                          style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary)),
                                  ],
                                ),
                                const Spacer(),
                                GestureDetector(
                                  onTap: product.stockQuantity > 0
                                      ? () => setState(() {
                                          if (_quantity > 1) _quantity--;
                                        })
                                      : null,
                                  child: Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                      border: Border.all(color: const Color(0xFFE8DCDC)),
                                    ),
                                    child: const Icon(LucideIcons.minus, size: 18, color: AppColors.textPrimary),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 18),
                                  child: Text('$_quantity', style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary)),
                                ),
                                GestureDetector(
                                  onTap: product.stockQuantity > 0
                                      ? () {
                                          if (_quantity < product.stockQuantity) {
                                            setState(() => _quantity++);
                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Maximum available stock is ${product.stockQuantity}'),
                                                duration: const Duration(seconds: 1),
                                              ),
                                            );
                                          }
                                        }
                                      : null,
                                  child: Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: (_quantity < product.stockQuantity)
                                          ? AppColors.primary
                                          : AppColors.primary.withValues(alpha: 0.4),
                                    ),
                                    child: const Icon(LucideIcons.plus, size: 18, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Gap(24),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: LiquidGlassButton(
                        label: 'Add to Cart',
                        icon: LucideIcons.shoppingBag,
                        variant: GlassButtonVariant.secondary,
                        onPressed: product.stockQuantity > 0
                            ? () {
                                ref.read(cartProvider.notifier).addToCart(product, _quantity);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${product.name} added to cart'),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            : null,
                      ),
                    ),
                    const Gap(14),
                    Expanded(
                      child: LiquidGlassButton(
                        label: 'Buy Now',
                        onPressed: product.stockQuantity > 0
                            ? () {
                                ref.read(cartProvider.notifier).addToCart(product, _quantity);
                                context.push('/cart');
                              }
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _specRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary)),
          Text(value, style: AppTextStyles.label1.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
