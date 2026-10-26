import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../domain/providers/business_info_provider.dart';
import '../../widgets/glass/liquid_glass_card.dart';
import '../../widgets/glass/liquid_glass_app_bar.dart';
import '../../widgets/glass/liquid_glass_button.dart';
import '../../widgets/glass/liquid_glass_text_field.dart';
import '../../widgets/glass/customer_background.dart';

class CompanyContactScreen extends ConsumerWidget {
  const CompanyContactScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final infoAsync = ref.watch(businessInfoProvider);
    return Scaffold(backgroundColor: AppColors.background,
      body: CustomerBackground(child: Column(children: [
        const LiquidGlassAppBar(title: 'Contact Us'),
        Expanded(child: infoAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (info) => SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('Contact Information', style: AppTextStyles.h1.copyWith(color: AppColors.textPrimary)),
            const SizedBox(height: 16),
            LiquidGlassCard(blurStrength: 10, borderRadius: 16, padding: const EdgeInsets.all(4),
              child: Column(children: [
                _contactTile(LucideIcons.mapPin, 'Address', info.address, () => launchUrl(Uri.parse(info.googleMapsUrl))),
                Divider(color: AppColors.glassBorder, height: 1),
                _contactTile(LucideIcons.phone, 'Phone', info.phone, () => launchUrl(Uri.parse('tel:${info.phone}'))),
                Divider(color: AppColors.glassBorder, height: 1),
                _contactTile(LucideIcons.mail, 'Email', info.email, () => launchUrl(Uri.parse('mailto:${info.email}'))),
                Divider(color: AppColors.glassBorder, height: 1),
                Builder(builder: (ctx) {
                  final hours = info.businessHours;
                  String hoursText = '';
                  for (final d in ['monday','tuesday','wednesday','thursday','friday','saturday','sunday']) {
                    final s = hours[d]; if (s == null) continue;
                    final dayName = d[0].toUpperCase() + d.substring(1);
                    hoursText += s.isOpen ? '$dayName: ${s.openTime} — ${s.closeTime}\n' : '$dayName: Closed\n';
                  }
                  return ListTile(leading: const Icon(LucideIcons.clock, color: AppColors.primary),
                    title: Text('Business Hours', style: AppTextStyles.label1), subtitle: Text(hoursText.trim(), style: AppTextStyles.body2));
                }),
              ])),
            const SizedBox(height: 28),
            Text('Send a Message', style: AppTextStyles.h1.copyWith(color: AppColors.textPrimary)),
            const SizedBox(height: 16),
            LiquidGlassCard(blurStrength: 10, borderRadius: 16,
              child: Column(children: [
                LiquidGlassTextField(hintText: 'Full Name *'),
                const SizedBox(height: 12),
                LiquidGlassTextField(hintText: 'Email Address *', keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 12),
                LiquidGlassTextField(hintText: 'Phone Number *', keyboardType: TextInputType.phone),
                const SizedBox(height: 12),
                LiquidGlassTextField(hintText: 'Subject'),
                const SizedBox(height: 12),
                LiquidGlassTextField(hintText: 'Message *', maxLines: 4),
                const SizedBox(height: 16),
                LiquidGlassButton(label: 'Send Message', onPressed: () =>
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thank you! Message sent.')))),
              ])),
          ])),
        )),
      ])),
    );
  }

  Widget _contactTile(IconData icon, String title, String sub, VoidCallback onTap) {
    return ListTile(leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: AppTextStyles.label1), subtitle: Text(sub, style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary)),
      trailing: const Icon(LucideIcons.externalLink, size: 14, color: AppColors.textTertiary), onTap: onTap);
  }
}
