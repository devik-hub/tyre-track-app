import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../widgets/glass/liquid_glass_card.dart';
import '../../widgets/glass/liquid_glass_app_bar.dart';
import '../../widgets/glass/liquid_glass_button.dart';
import '../../widgets/glass/customer_background.dart';

class CompanyProductsScreen extends StatelessWidget {
  const CompanyProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final products = [
      {'title': 'Auto Tires', 'size': '4.50-10', 'features': ['Perfect for small vehicles', 'Enhanced grip', 'Long-lasting tread'], 'icon': LucideIcons.car},
      {'title': 'Bias & Radial', 'size': '12.00-20', 'features': ['Heavy-duty performance', 'Superior durability', 'All-terrain'], 'icon': LucideIcons.truck},
      {'title': 'Tubeless 17.5', 'size': '17.5', 'features': ['Modern design', 'Fuel efficiency', 'Smooth operation'], 'icon': LucideIcons.disc},
      {'title': 'Tubeless 22.5', 'size': '22.5', 'features': ['Maximum load capacity', 'Extended lifespan', 'Premium quality'], 'icon': LucideIcons.flame},
    ];
    return Scaffold(backgroundColor: AppColors.background,
      body: CustomerBackground(child: Column(children: [
        const LiquidGlassAppBar(title: 'Our Products'),
        // Hero banner
        Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
          decoration: const BoxDecoration(gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryDark])),
          child: Column(children: [
            Text('Premium Retreaded Tires', style: AppTextStyles.display2.copyWith(color: Colors.white)),
            const SizedBox(height: 8),
            Text('Quality and reliability for every journey', style: AppTextStyles.body1.copyWith(color: Colors.white70)),
          ])),
        Expanded(child: Padding(padding: const EdgeInsets.all(16),
          child: GridView.builder(shrinkWrap: true, physics: const BouncingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.55, crossAxisSpacing: 12, mainAxisSpacing: 12),
            itemCount: products.length,
            itemBuilder: (ctx, i) {
              final p = products[i];
              final features = p['features'] as List<String>;
              return LiquidGlassCard(blurStrength: 10, borderRadius: 16,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(flex: 3, child: Center(child: Icon(p['icon'] as IconData, size: 64, color: AppColors.primary.withValues(alpha: 0.7)))),
                  Divider(color: AppColors.glassBorder),
                  Expanded(flex: 5, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(p['title'] as String, style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary)),
                    Text('Size: ${p['size']}', style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    ...features.map((f) => Padding(padding: const EdgeInsets.only(bottom: 4),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Icon(LucideIcons.check, size: 14, color: AppColors.success), const SizedBox(width: 4),
                        Expanded(child: Text(f, style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary))),
                      ]))),
                    const Spacer(),
                    LiquidGlassButton(label: 'Order Now', height: 36, onPressed: () => context.push('/home')),
                  ])),
                ]));
            }))),
      ])),
    );
  }
}
