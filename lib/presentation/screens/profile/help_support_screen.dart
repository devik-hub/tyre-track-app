import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../domain/providers/business_info_provider.dart';
import '../../widgets/glass/liquid_glass_card.dart';
import '../../widgets/glass/liquid_glass_app_bar.dart';
import '../../widgets/glass/customer_background.dart';

class HelpSupportScreen extends ConsumerWidget {
  const HelpSupportScreen({super.key});

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) throw Exception('Could not launch $url');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final infoAsync = ref.watch(businessInfoProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomerBackground(
        child: Column(
          children: [
            const LiquidGlassAppBar(
              title: 'Help & Support',
              showBrandSubtitle: true,
            ),
            Expanded(
              child: infoAsync.when(
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                error: (e, _) => Center(child: Text('Error: $e', style: AppTextStyles.body1.copyWith(color: AppColors.error))),
                data: (info) => SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('How can we help?', style: AppTextStyles.display2.copyWith(color: AppColors.textPrimary))
                          .animate().fadeIn(duration: 300.ms),
                      const Gap(16),
                      _contactCard(LucideIcons.phone, 'Call Us Directly', info.phone, () => _launchUrl('tel:${info.phone}'))
                          .animate().fadeIn(duration: 300.ms, delay: 50.ms),
                      const Gap(12),
                      _contactCard(LucideIcons.mail, 'Email Support', info.email, () => _launchUrl('mailto:${info.email}'))
                          .animate().fadeIn(duration: 300.ms, delay: 100.ms),
                      const Gap(12),
                      _contactCard(LucideIcons.mapPin, 'Visit Franchise Workshop', info.address, () => _launchUrl(info.googleMapsUrl))
                          .animate().fadeIn(duration: 300.ms, delay: 150.ms),
                      if (info.whatsapp.isNotEmpty) ...[
                        const Gap(12),
                        _contactCard(LucideIcons.messageSquare, 'WhatsApp Assistance', info.whatsapp,
                                () => _launchUrl('https://wa.me/${info.whatsapp.replaceAll('+', '')}'))
                            .animate().fadeIn(duration: 300.ms, delay: 200.ms),
                      ],
                      const Gap(32),
                      Text('Frequently Asked Questions', style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary)),
                      const Gap(12),
                      _faq(
                        'What is the MRF Retreading warranty policy?',
                        'We offer an authorized MRF franchise warranty covering tread bonding and workmanship for up to 2 years or specified mileage.',
                      ),
                      _faq(
                        'How long does standard tyre remoulding take?',
                        'Standard turnaround time is 24 to 48 hours depending on inspection queue and structural casing preparation.',
                      ),
                      _faq(
                        'Which tyre casings can be retreaded?',
                        'Radial and bias tyre casings with sound belt integrity and no bead damage qualify for cold or hot process retreading.',
                      ),
                      const Gap(32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _contactCard(IconData icon, String title, String sub, VoidCallback onTap) {
    return LiquidGlassCard(
      onTap: onTap,
      borderRadius: 22,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.12),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.25), width: 1),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.label1.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                const Gap(2),
                Text(sub, style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          const Icon(LucideIcons.chevronRight, size: 18, color: AppColors.textSecondary),
        ],
      ),
    );
  }

  Widget _faq(String q, String a) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: LiquidGlassCard(
        borderRadius: 20,
        padding: EdgeInsets.zero,
        child: Theme(
          data: ThemeData(dividerColor: Colors.transparent),
          child: ExpansionTile(
            title: Text(q, style: AppTextStyles.label1.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
            trailing: const Icon(LucideIcons.chevronDown, size: 18, color: AppColors.primary),
            tilePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
            childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
            children: [
              Text(a, style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary, height: 1.5)),
            ],
          ),
        ),
      ),
    );
  }
}
