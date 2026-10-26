import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../app/routes/app_routes.dart';
import '../../../domain/providers/service_availability_provider.dart';
import '../../../domain/providers/auth_provider.dart';
import '../../widgets/glass/customer_background.dart';
import '../../widgets/glass/liquid_glass_card.dart';
import '../../widgets/glass/liquid_glass_app_bar.dart';
import '../../widgets/glass/liquid_glass_button.dart';
import '../../widgets/glass/liquid_glass_status_badge.dart';

class ServicesHomeScreen extends ConsumerWidget {
  const ServicesHomeScreen({super.key});

  static const List<Map<String, dynamic>> _allServices = [
    {
      'key': 'retreading',
      'title': 'MRF Retreading',
      'icon': LucideIcons.refreshCw,
      'desc': 'Extend tyre lifespan with certified MRF precinct tread rubber.',
    },
    {
      'key': 'remoulding',
      'title': 'Tyre Remoulding',
      'icon': LucideIcons.layers,
      'desc': 'Complete tyre rebuild for superior grip, balance, and highway safety.',
    },
    {
      'key': 'inspection',
      'title': '25-Point Inspection',
      'icon': LucideIcons.search,
      'desc': 'Detailed structural casing and tread health diagnostic scan.',
    },
    {
      'key': 'new_fitment',
      'title': 'Fitment & Balancing',
      'icon': LucideIcons.wrench,
      'desc': 'Professional alignment and rim fitment by certified technicians.',
    },
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final availabilityAsync = ref.watch(serviceAvailabilityProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const LiquidGlassAppBar(
        title: 'Retread & Services',
        showBrandSubtitle: true,
      ),
      body: CustomerBackground(
        child: availabilityAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
          error: (e, _) => Center(
            child: Text('Error: $e', style: AppTextStyles.body1.copyWith(color: AppColors.error)),
          ),
          data: (availability) {
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              itemCount: _allServices.length,
              itemBuilder: (ctx, index) {
                final svc = _allServices[index];
                final key = svc['key'] as String;
                final isAvail = availability[key] ?? true;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Opacity(
                    opacity: isAvail ? 1.0 : 0.6,
                    child: LiquidGlassCard(
                      borderRadius: 24,
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  (isAvail ? AppColors.primary : AppColors.textTertiary).withValues(alpha: 0.16),
                                  (isAvail ? AppColors.primary : AppColors.textTertiary).withValues(alpha: 0.06),
                                ],
                              ),
                              border: Border.all(
                                color: (isAvail ? AppColors.primary : AppColors.textTertiary).withValues(alpha: 0.25),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              svc['icon'] as IconData,
                              color: isAvail ? AppColors.primary : AppColors.textTertiary,
                              size: 24,
                            ),
                          ),
                          const Gap(16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  svc['title'] as String,
                                  style: AppTextStyles.h3.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const Gap(4),
                                Text(
                                  svc['desc'] as String,
                                  style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
                                ),
                                if (!isAvail) ...[
                                  const Gap(8),
                                  const LiquidGlassStatusBadge(label: 'Unavailable Today', color: AppColors.warning),
                                ],
                              ],
                            ),
                          ),
                          const Gap(12),
                          SizedBox(
                            width: 80,
                            child: LiquidGlassButton(
                              label: isAvail ? 'Book' : 'Closed',
                              height: 42,
                              variant: isAvail ? GlassButtonVariant.primary : GlassButtonVariant.secondary,
                              onPressed: isAvail
                                  ? () {
                                      final user = ref.read(authProvider).userModel;
                                      if (user == null) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Please wait or log in')),
                                        );
                                        return;
                                      }
                                      context.push(AppRoutes.bookService);
                                    }
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ).animate().fadeIn(duration: 300.ms, delay: (index * 60).ms).slideY(begin: 0.05, end: 0);
              },
            );
          },
        ),
      ),
    );
  }
}
