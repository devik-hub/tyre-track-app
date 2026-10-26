import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../widgets/glass/liquid_glass_card.dart';
import '../../widgets/glass/liquid_glass_app_bar.dart';
import '../../widgets/glass/customer_background.dart';

class CompanyAboutUsScreen extends StatelessWidget {
  const CompanyAboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: AppColors.background,
      body: CustomerBackground(child: Column(children: [
        const LiquidGlassAppBar(title: 'About Us'),
        Expanded(child: SingleChildScrollView(child: Column(children: [
          // Hero
          Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
            decoration: const BoxDecoration(gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryDark])),
            child: Column(children: [
              Text('About Us', style: AppTextStyles.display1.copyWith(color: Colors.white)),
              const SizedBox(height: 8),
              Text('Trusted name in tyre retreading for over 6 years', style: AppTextStyles.body1.copyWith(color: Colors.white70), textAlign: TextAlign.center),
            ])),
          Padding(padding: const EdgeInsets.all(20), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: LiquidGlassCard(blurStrength: 10, borderRadius: 16, redAccent: true,
              child: Column(children: [
                Text('Our Mission', style: AppTextStyles.h2.copyWith(color: AppColors.primary)),
                const SizedBox(height: 10),
                Text('To provide high-quality retreaded tyres that extend the life of your tyres and save you money while maintaining the highest standards of safety.',
                  textAlign: TextAlign.center, style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary)),
              ]))),
            const SizedBox(width: 12),
            Expanded(child: LiquidGlassCard(blurStrength: 10, borderRadius: 16, redAccent: true,
              child: Column(children: [
                Text('Our Vision', style: AppTextStyles.h2.copyWith(color: AppColors.primary)),
                const SizedBox(height: 10),
                Text('To be the leading tyre retreading service provider in Pune District, known for quality, reliability, and customer satisfaction.',
                  textAlign: TextAlign.center, style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary)),
              ]))),
          ])),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text('Jagadale Retreads has been a trusted name in the tyre retreading industry for over 6 years, offering durable and cost-effective solutions for commercial vehicles across Pune District.',
              style: AppTextStyles.body1.copyWith(color: AppColors.textSecondary, height: 1.6))),
          const SizedBox(height: 20),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ClipRRect(borderRadius: BorderRadius.circular(16),
              child: Image.asset('assets/images/Screenshot 2024-06-27 142313.webp', errorBuilder: (c, e, s) => const SizedBox.shrink()))),
          const SizedBox(height: 24),
          Text('Our Process', style: AppTextStyles.display2.copyWith(color: AppColors.primary)),
          const SizedBox(height: 16),
          _step('1. Initial Inspection', 'assets/images/Initial Inspection.jpg', 'Evaluate the suitability of the tyre casing for remolding.'),
          _step('2. Buffing', 'assets/images/Buffing.jpeg', 'Remove the worn-out tread and prepare the surface.'),
          _step('3. Casing Repair', 'assets/images/Casing Repair.jpg', 'Repair minor defects in the casing.'),
          _step('4. Bonding Agent', 'assets/images/Applying Bonding Agent.jpg', 'Apply rubber cement for a robust bond.'),
          _step('5. Tread Application', 'assets/images/Tread Application.jpg', 'Attach new tread material to the casing.'),
          _step('6. Enveloping', 'assets/images/Enveloping and Mounting.jpg', 'Prepare the tyre for curing.'),
          _step('7. Vulcanization', 'assets/images/Vulcanization.jpg', 'Permanently adhere the new tread.'),
          _step('8. Final Inspection', 'assets/images/Final Inspection.jpg', 'Ensure quality standards are met.'),
          _step('9. Finishing', 'assets/images/Finishing.jpg', 'Trim excess rubber and polish.'),
          _step('10. Distribution', 'assets/images/Distribution.jpeg', 'Certify and dispatch to customers.'),
          const SizedBox(height: 40),
        ]))),
      ])),
    );
  }

  Widget _step(String title, String img, String desc) {
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: LiquidGlassCard(blurStrength: 8, borderRadius: 16, padding: EdgeInsets.zero,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.asset(img, height: 180, fit: BoxFit.cover,
              errorBuilder: (c, e, s) => const SizedBox(height: 180, child: Center(child: Icon(LucideIcons.image, size: 40, color: AppColors.textTertiary))))),
          Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary)),
            const SizedBox(height: 6),
            Text(desc, style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary, height: 1.4)),
          ])),
        ])));
  }
}
