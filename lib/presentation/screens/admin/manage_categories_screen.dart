import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:uuid/uuid.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../data/models/vehicle_category_model.dart';
import '../../../data/repositories/vehicle_category_repository.dart';
import '../../../domain/providers/vehicle_category_provider.dart';
import '../../widgets/glass/liquid_glass_card.dart';
import '../../widgets/glass/liquid_glass_app_bar.dart';
import '../../widgets/glass/liquid_glass_button.dart';
import '../../widgets/glass/liquid_glass_status_badge.dart';
import '../../widgets/glass/admin_background.dart';

class ManageCategoriesScreen extends ConsumerWidget {
  const ManageCategoriesScreen({super.key});

  static const Map<String, IconData> iconOptions = {
    'directions_car': LucideIcons.car, 'two_wheeler': LucideIcons.bike,
    'local_shipping': LucideIcons.truck, 'directions_bus': LucideIcons.bus,
    'agriculture': LucideIcons.truck, 'fire_truck': LucideIcons.flame,
    'electric_car': LucideIcons.zap, 'pedal_bike': LucideIcons.footprints,
    'airport_shuttle': LucideIcons.navigation, 'rv_hookup': LucideIcons.shield,
  };

  static IconData getIconData(String iconName) => iconOptions[iconName] ?? LucideIcons.car;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(vehicleCategoryStreamProvider);
    return Scaffold(backgroundColor: AppColors.mrfBlack,
      body: AdminBackground(child: Column(children: [
        const LiquidGlassAppBar(title: 'Vehicle Categories', isDark: true),
        Expanded(child: categoriesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.mrfRed)),
          error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.red))),
          data: (categories) {
            if (categories.isEmpty) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(LucideIcons.layoutGrid, size: 64, color: Colors.grey.shade800),
              const SizedBox(height: 16),
              Text('No Categories Yet', style: AppTextStyles.h2.copyWith(color: Colors.white70)),
              const SizedBox(height: 8),
              Text('Tap + to add vehicle categories', style: AppTextStyles.body2.copyWith(color: AppColors.adminTextTert)),
            ]));
            return RefreshIndicator(color: AppColors.mrfRed, backgroundColor: AppColors.mrfBlack,
              onRefresh: () async => ref.refresh(vehicleCategoryStreamProvider),
              child: ListView.builder(padding: const EdgeInsets.all(16), itemCount: categories.length,
                itemBuilder: (ctx, i) {
                  final cat = categories[i];
                  return Padding(padding: const EdgeInsets.only(bottom: 12),
                    child: LiquidGlassCard(isDark: true, borderRadius: 16, blurStrength: 10,
                      child: Row(children: [
                        Container(padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: AppColors.mrfRed.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                          child: Icon(getIconData(cat.icon), color: AppColors.mrfRed, size: 28)),
                        const SizedBox(width: 16),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(cat.name, style: AppTextStyles.h3.copyWith(color: AppColors.adminTextPrimary)),
                          const SizedBox(height: 4),
                          Row(children: [
                            LiquidGlassStatusBadge(label: 'Order: ${cat.sortOrder}', color: Colors.blue),
                            const SizedBox(width: 8),
                            LiquidGlassStatusBadge(label: cat.icon, color: Colors.orange),
                          ]),
                        ])),
                        PopupMenuButton<String>(icon: const Icon(LucideIcons.moreVertical, color: Colors.white54), color: AppColors.glassDarkThick,
                          onSelected: (action) {
                            if (action == 'edit') _showCategorySheet(context, ref, cat);
                            if (action == 'delete') _confirmDelete(context, ref, cat);
                          }, itemBuilder: (_) => [
                            PopupMenuItem(value: 'edit', child: Row(children: [Icon(LucideIcons.edit3, color: AppColors.adminTextSec, size: 18), const SizedBox(width: 8), Text('Edit', style: TextStyle(color: AppColors.adminTextPrimary))])),
                            PopupMenuItem(value: 'delete', child: Row(children: [const Icon(LucideIcons.trash2, color: AppColors.mrfRed, size: 18), const SizedBox(width: 8), Text('Delete', style: TextStyle(color: AppColors.mrfRed))])),
                          ]),
                      ])));
                }));
          })),
      ])),
      floatingActionButton: FloatingActionButton.extended(onPressed: () => _showCategorySheet(context, ref, null),
        backgroundColor: AppColors.mrfRed, icon: const Icon(LucideIcons.plus, color: Colors.white),
        label: const Text('New Category', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
    );
  }

  void _confirmDelete(BuildContext ctx, WidgetRef ref, VehicleCategoryModel cat) {
    showDialog(context: ctx, builder: (c) => AlertDialog(
      backgroundColor: AppColors.glassDarkThick, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Delete Category', style: AppTextStyles.h2.copyWith(color: Colors.white)),
      content: Text('Permanently delete "${cat.name}"?', style: AppTextStyles.body1.copyWith(color: AppColors.adminTextSec)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c), child: Text('Cancel', style: TextStyle(color: AppColors.adminTextSec))),
        ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.mrfRed),
          onPressed: () async { await ref.read(vehicleCategoryRepositoryProvider).deleteCategory(cat.categoryId); if (c.mounted) Navigator.pop(c); },
          child: const Text('Delete', style: TextStyle(color: Colors.white))),
      ]));
  }

  void _showCategorySheet(BuildContext ctx, WidgetRef ref, VehicleCategoryModel? existing) {
    final isEdit = existing != null;
    final nameC = TextEditingController(text: existing?.name ?? '');
    final sortC = TextEditingController(text: existing?.sortOrder.toString() ?? '0');
    String selectedIcon = existing?.icon ?? 'directions_car';

    showModalBottomSheet(context: ctx, isScrollControlled: true, backgroundColor: AppColors.glassDarkThick,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (c) => StatefulBuilder(builder: (c, setSheet) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(c).viewInsets.bottom),
        child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.adminTextTert, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 24),
          Text(isEdit ? 'Edit Category' : 'New Category', style: AppTextStyles.h1.copyWith(color: Colors.white)),
          const SizedBox(height: 24),
          TextField(controller: nameC, style: TextStyle(color: AppColors.adminTextPrimary),
            decoration: InputDecoration(labelText: 'Name *', labelStyle: TextStyle(color: AppColors.adminTextTert), prefixIcon: Icon(LucideIcons.tag, color: AppColors.adminTextTert),
              filled: true, fillColor: AppColors.glassDark, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.mrfRed)))),
          const SizedBox(height: 16),
          TextField(controller: sortC, keyboardType: TextInputType.number, style: TextStyle(color: AppColors.adminTextPrimary),
            decoration: InputDecoration(labelText: 'Sort Order', labelStyle: TextStyle(color: AppColors.adminTextTert), prefixIcon: Icon(LucideIcons.arrowDownUp, color: AppColors.adminTextTert),
              filled: true, fillColor: AppColors.glassDark, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
          const SizedBox(height: 16),
          Text('Select Icon', style: AppTextStyles.label1.copyWith(color: AppColors.adminTextSec)),
          const SizedBox(height: 8),
          Wrap(spacing: 10, runSpacing: 10, children: iconOptions.entries.map((e) {
            final sel = e.key == selectedIcon;
            return GestureDetector(onTap: () => setSheet(() => selectedIcon = e.key),
              child: Container(padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: sel ? AppColors.mrfRed.withValues(alpha: 0.2) : AppColors.glassDark,
                  borderRadius: BorderRadius.circular(12), border: Border.all(color: sel ? AppColors.mrfRed : AppColors.glassDarkBorder, width: sel ? 2 : 1)),
                child: Icon(e.value, color: sel ? AppColors.mrfRed : AppColors.adminTextTert, size: 26)));
          }).toList()),
          const SizedBox(height: 24),
          LiquidGlassButton(label: isEdit ? 'UPDATE' : 'CREATE', isDark: true, onPressed: () async {
            if (nameC.text.trim().isEmpty) { ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Name required'))); return; }
            final category = VehicleCategoryModel(categoryId: existing?.categoryId ?? const Uuid().v4(), name: nameC.text.trim(),
              icon: selectedIcon, sortOrder: int.tryParse(sortC.text) ?? 0, createdAt: existing?.createdAt ?? DateTime.now());
            try {
              if (isEdit) await ref.read(vehicleCategoryRepositoryProvider).updateCategory(category);
              else await ref.read(vehicleCategoryRepositoryProvider).addCategory(category);
              if (c.mounted) Navigator.pop(c);
            } catch (e) { if (c.mounted) ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text('Error: $e'))); }
          }),
          const SizedBox(height: 16),
        ])))));
  }
}
