import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/routes/app_routes.dart';

/// The first screen a user sees after the splash.
/// They choose whether to log in as a User or as an Admin.
/// No authentication happens here — it's purely a routing decision.
class RoleSelectScreen extends StatelessWidget {
  const RoleSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.tire_repair, size: 80, color: AppColors.mrfRed),
              const SizedBox(height: 16),
              Text(
                'Jagadale Retreads',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.mrfRed,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Who are you?',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 56),

              // ── Login as User ──────────────────────────────────────────
              ElevatedButton.icon(
                onPressed: () => context.push(AppRoutes.login),
                icon: const Icon(Icons.person_outline),
                label: const Text('Login as User'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppColors.mrfRed,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Login as Admin ─────────────────────────────────────────
              OutlinedButton.icon(
                onPressed: () => context.push(AppRoutes.adminLogin),
                icon: const Icon(Icons.admin_panel_settings_outlined),
                label: const Text('Login as Admin'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  foregroundColor: AppColors.mrfRed,
                  side: const BorderSide(color: AppColors.mrfRed, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
