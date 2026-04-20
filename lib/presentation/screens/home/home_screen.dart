import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../domain/providers/auth_provider.dart';
import '../../../domain/providers/product_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).userModel;
    final userName = user?.name.split(' ').first ?? 'User';

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset('assets/images/logo.png', errorBuilder: (c, e, s) => const Icon(Icons.tire_repair)),
        ),
        title: const Text('Jagadale Retreads'),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () => context.go('/tyres')),
          IconButton(icon: const Icon(Icons.notifications_none), onPressed: () => context.push('/notifications')),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildGreetingBanner(context, userName, user?.role ?? 'customer'),
            const SizedBox(height: 16),
            _buildQuickActions(context),
            const SizedBox(height: 16),
            _buildServicesSection(context),
            const SizedBox(height: 16),
            _buildFeaturedTyres(context, ref),
            const SizedBox(height: 24),
            _buildCompanyQuickLinks(context),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildGreetingBanner(BuildContext context, String name, String role) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good Morning' : (hour < 17 ? 'Good Afternoon' : 'Good Evening');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.mrfRed, AppColors.mrfDarkRed],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$greeting, $name! 👋', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Your tyre health is being monitored', style: TextStyle(color: Colors.white70, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 2.5,
        children: [
          _buildActionCard(context, 'Buy New Tyre', Icons.shopping_bag, () => context.go('/tyres')),
          _buildActionCard(context, 'Book Service', Icons.build, () => context.go('/services')),
          _buildActionCard(context, 'My Vehicles', Icons.directions_car, () => context.go('/vehicles')),
          _buildActionCard(context, 'Track Order', Icons.local_shipping, () => context.push('/orders')),
        ],
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.mrfRed, size: 20),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesSection(BuildContext context) {
    final services = [
      {'name': 'Retreading', 'icon': Icons.autorenew},
      {'name': 'Remoulding', 'icon': Icons.handyman},
      {'name': 'Inspection', 'icon': Icons.search},
      {'name': 'New Fitment', 'icon': Icons.build_circle},
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Our Services', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: services.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () => context.go('/services'),
                  child: Container(
                    width: 100,
                    margin: const EdgeInsets.only(right: 12),
                    child: Card(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(services[index]['icon'] as IconData, color: AppColors.mrfRed),
                          const SizedBox(height: 8),
                          Text(services[index]['name'] as String, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedTyres(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productStreamProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Featured MRF Tyres', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton(onPressed: () => context.go('/tyres'), child: const Text('Shop All →', style: TextStyle(color: AppColors.mrfRed))),
            ],
          ),
          SizedBox(
            height: 200,
            child: productsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Unable to load products', style: TextStyle(color: Colors.grey.shade500))),
              data: (products) {
                if (products.isEmpty) {
                  return const Center(child: Text('No products yet. Admin can add from dashboard.', style: TextStyle(color: Colors.grey)));
                }
                final featured = products.take(5).toList();
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: featured.length,
                  itemBuilder: (context, index) {
                    final p = featured[index];
                    return InkWell(
                      onTap: () => context.push('/tyre_detail', extra: p.productId),
                      child: Container(
                        width: 160,
                        margin: const EdgeInsets.only(right: 12),
                        child: Card(
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 100,
                                color: Colors.grey[200],
                                child: Center(
                                  child: p.imageUrls.isNotEmpty
                                      ? Image.network(p.imageUrls.first, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.tire_repair, size: 40, color: Colors.grey))
                                      : const Icon(Icons.tire_repair, size: 40, color: Colors.grey),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                                    Text('${p.brand} • ${p.size}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                    const SizedBox(height: 4),
                                    Text('₹${p.price.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.mrfRed)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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

  Widget _buildCompanyQuickLinks(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Discover Jagadale', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMiniAction(context, Icons.info_outline, 'About Us', () => context.push('/about')),
              _buildMiniAction(context, Icons.photo_library_outlined, 'Gallery', () => context.push('/gallery')),
              _buildMiniAction(context, Icons.phone_outlined, 'Contact', () => context.push('/contact')),
              _buildMiniAction(context, Icons.inventory_2_outlined, 'Products', () => context.push('/legacy-products')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniAction(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Column(
        children: [
          CircleAvatar(backgroundColor: AppColors.mrfRed.withOpacity(0.1), child: Icon(icon, color: AppColors.mrfRed)),
          const SizedBox(height: 6),
          Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
