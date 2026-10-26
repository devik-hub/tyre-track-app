import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../widgets/glass/liquid_glass_card.dart';
import '../../widgets/glass/liquid_glass_app_bar.dart';
import '../../widgets/glass/customer_background.dart';

class CompanyGalleryScreen extends StatelessWidget {
  const CompanyGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final images = [
      {'title': 'Initial Inspection', 'path': 'assets/images/Initial Inspection.jpg'},
      {'title': 'Buffing Process', 'path': 'assets/images/Buffing.jpeg'},
      {'title': 'Bonding Agent', 'path': 'assets/images/Applying Bonding Agent.jpg'},
      {'title': 'Tread Application', 'path': 'assets/images/Tread Application.jpg'},
      {'title': 'Vulcanization', 'path': 'assets/images/Vulcanization.jpg'},
      {'title': 'Final Inspection', 'path': 'assets/images/Final Inspection.jpg'},
      {'title': 'Our Facility', 'path': 'assets/images/IMG-20240626-WA0000.jpg'},
      {'title': 'Retreaded Tire', 'path': 'assets/images/IMG-20240628-WA0016.jpg'},
    ];
    return Scaffold(backgroundColor: AppColors.background,
      body: CustomerBackground(child: Column(children: [
        const LiquidGlassAppBar(title: 'Gallery'),
        Expanded(child: Padding(padding: const EdgeInsets.all(16),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.8),
            itemCount: images.length,
            itemBuilder: (ctx, i) => LiquidGlassCard(blurStrength: 8, borderRadius: 16, padding: EdgeInsets.zero,
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Expanded(child: ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.asset(images[i]['path']!, fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => const Center(child: Icon(Icons.broken_image, color: AppColors.textTertiary))))),
                Container(padding: const EdgeInsets.all(10),
                  child: Text(images[i]['title']!, style: AppTextStyles.label1.copyWith(color: AppColors.textPrimary), textAlign: TextAlign.center)),
              ]))))),
      ])),
    );
  }
}
