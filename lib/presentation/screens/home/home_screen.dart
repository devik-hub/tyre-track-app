import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../app/routes/app_routes.dart';
import '../../../domain/providers/auth_provider.dart';
import '../../../domain/providers/product_provider.dart';
import '../../widgets/glass/customer_background.dart';
import '../../widgets/glass/liquid_glass_card.dart';
import '../../widgets/glass/liquid_glass_app_bar.dart';
import 'product_search_delegate.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).userModel;
    final userName = user?.name.split(' ').first ?? 'Customer';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: LiquidGlassAppBar(
        title: 'MRF • JAGADALE RETREADS',
        showBrandSubtitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'assets/images/logo.png',
            errorBuilder: (c, e, s) => const Icon(LucideIcons.disc, color: Colors.white, size: 24),
          ),
        ),
        actions: [
          _clayCircleBtn(LucideIcons.search, () => showSearch(context: context, delegate: ProductSearchDelegate(ref))),
          const Gap(8),
          _clayCircleBtn(LucideIcons.bell, () => context.push(AppRoutes.notifications)),
          const Gap(12),
        ],
      ),
      body: CustomerBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildGreetingBanner(context, userName).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0),
              const Gap(20),
              _buildQuickActions(context).animate().fadeIn(duration: 350.ms, delay: 100.ms),
              const Gap(24),
              _buildServicesSection(context).animate().fadeIn(duration: 350.ms, delay: 150.ms),
              const Gap(24),
              _buildFeaturedTyres(context, ref).animate().fadeIn(duration: 350.ms, delay: 200.ms),
              const Gap(24),
              _buildFeaturedCasings(context, ref).animate().fadeIn(duration: 350.ms, delay: 250.ms),
              const Gap(24),
              _buildCompanyQuickLinks(context).animate().fadeIn(duration: 350.ms, delay: 300.ms),
              const Gap(32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _clayCircleBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1),
        ),
        child: Icon(icon, size: 18, color: Colors.white),
      ),
    );
  }

  Widget _buildGreetingBanner(BuildContext context, String name) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good Morning' : (hour < 17 ? 'Good Afternoon' : 'Good Evening');

    return LiquidGlassCard(
      redAccent: true,
      borderRadius: 28,
      padding: const EdgeInsets.all(22),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(LucideIcons.shieldCheck, size: 14, color: AppColors.primary),
                        const Gap(4),
                        Text(
                          'CERTIFIED MRF FRANCHISE',
                          style: AppTextStyles.labelCaps.copyWith(color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Gap(10),
              Text('$greeting, $name! 👋', style: AppTextStyles.h1.copyWith(color: AppColors.textPrimary)),
              const Gap(6),
              Text(
                'Professional tyre retreading & maintenance at Jagadale Retreads.',
                style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio: 2.3,
      children: [
        _actionCard(context, 'Buy New Tyre', LucideIcons.shoppingBag, () => context.go(AppRoutes.tyres)),
        _actionCard(context, 'Book Service', LucideIcons.wrench, () {
          final u = ref.read(authProvider).userModel;
          if (u == null) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please wait or log in')));
            return;
          }
          context.go(AppRoutes.services);
        }),
        _actionCard(context, 'Buy Casing', LucideIcons.disc, () => context.go(AppRoutes.casings)),
        _actionCard(context, 'Track Order', LucideIcons.truck, () => context.push(AppRoutes.orders)),
      ],
    );
  }

  Widget _actionCard(BuildContext ctx, String title, IconData icon, VoidCallback onTap) {
    return LiquidGlassCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      borderRadius: 24,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const Gap(10),
          Flexible(
            child: Text(
              title,
              style: AppTextStyles.label1.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesSection(BuildContext context) {
    final svcs = [
      {'name': 'Retreading', 'icon': LucideIcons.refreshCw, 'desc': 'MRF Quality'},
      {'name': 'Remoulding', 'icon': LucideIcons.hammer, 'desc': 'Precise fit'},
      {'name': 'Inspection', 'icon': LucideIcons.search, 'desc': 'Safety audit'},
      {'name': 'New Fitment', 'icon': LucideIcons.checkCircle2, 'desc': 'Expert fitting'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Our Services', style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary)),
            TextButton(
              onPressed: () => context.go(AppRoutes.services),
              child: Text('View All →', style: AppTextStyles.label1.copyWith(color: AppColors.primary)),
            ),
          ],
        ),
        const Gap(10),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: svcs.length,
            itemBuilder: (ctx, i) => Container(
              width: 110,
              margin: const EdgeInsets.only(right: 12),
              child: LiquidGlassCard(
                onTap: () => context.go(AppRoutes.services),
                padding: const EdgeInsets.all(12),
                borderRadius: 22,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(svcs[i]['icon'] as IconData, color: AppColors.primary, size: 20),
                    ),
                    const Gap(6),
                    Text(
                      svcs[i]['name'] as String,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.label2.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedTyres(BuildContext ctx, WidgetRef ref) {
    final pa = ref.watch(productStreamProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Featured MRF Tyres', style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary)),
            TextButton(
              onPressed: () => ctx.go(AppRoutes.tyres),
              child: Text('Shop All →', style: AppTextStyles.label1.copyWith(color: AppColors.primary)),
            ),
          ],
        ),
        const Gap(10),
        SizedBox(
          height: 215,
          child: pa.when(
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
            error: (e, _) => Center(
              child: Text('Unable to load', style: AppTextStyles.body2.copyWith(color: AppColors.textTertiary)),
            ),
            data: (products) {
              final f = products.where((p) => p.category != 'casing' && p.isFeatured).toList();
              final d = f.isNotEmpty ? f : products.where((p) => p.category != 'casing').take(5).toList();
              if (d.isEmpty) {
                return Center(
                  child: Text('No products yet.', style: AppTextStyles.body2.copyWith(color: AppColors.textTertiary)),
                );
              }
              return _productRow(ctx, d);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedCasings(BuildContext ctx, WidgetRef ref) {
    final ca = ref.watch(featuredCasingsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Featured Casings', style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary)),
            TextButton(
              onPressed: () => ctx.go(AppRoutes.casings),
              child: Text('Shop All →', style: AppTextStyles.label1.copyWith(color: AppColors.primary)),
            ),
          ],
        ),
        const Gap(10),
        SizedBox(
          height: 215,
          child: ca.when(
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
            error: (e, _) => const SizedBox.shrink(),
            data: (casings) {
              if (casings.isEmpty) {
                return Center(
                  child: Text('No featured casings yet.', style: AppTextStyles.body2.copyWith(color: AppColors.textTertiary)),
                );
              }
              return _productRow(ctx, casings);
            },
          ),
        ),
      ],
    );
  }

  Widget _productRow(BuildContext ctx, List products) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: products.length,
      itemBuilder: (c, i) {
        final p = products[i];
        return Container(
          width: 165,
          margin: const EdgeInsets.only(right: 14),
          child: LiquidGlassCard(
            onTap: () => ctx.push(AppRoutes.tyreDetail, extra: p.productId),
            padding: EdgeInsets.zero,
            borderRadius: 22,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                  child: Container(
                    height: 105,
                    width: double.infinity,
                    color: AppColors.surface,
                    child: Center(
                      child: p.imageUrls.isNotEmpty
                          ? Image.network(
                              p.imageUrls.first,
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => const Icon(LucideIcons.disc, size: 36, color: AppColors.textTertiary),
                            )
                          : const Icon(LucideIcons.disc, size: 36, color: AppColors.textTertiary),
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
                        style: AppTextStyles.label1.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Gap(2),
                      Text(
                        '${p.brand} • ${p.size}',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                      ),
                      const Gap(6),
                      Text(
                        '₹${p.price.toStringAsFixed(0)}',
                        style: AppTextStyles.h3.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompanyQuickLinks(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Discover Jagadale Retreads', style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary)),
        const Gap(16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _miniAction(context, LucideIcons.info, 'About Us', () => context.push(AppRoutes.about)),
            _miniAction(context, LucideIcons.image, 'Gallery', () => context.push(AppRoutes.gallery)),
            _miniAction(context, LucideIcons.phoneCall, 'Contact', () => context.push(AppRoutes.contact)),
            _miniAction(context, LucideIcons.package, 'Products', () => context.push(AppRoutes.legacyProducts)),
          ],
        ),
      ],
    );
  }

  Widget _miniAction(BuildContext ctx, IconData icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.92),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 1.5),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const Gap(8),
          Text(title, style: AppTextStyles.label2.copyWith(color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
