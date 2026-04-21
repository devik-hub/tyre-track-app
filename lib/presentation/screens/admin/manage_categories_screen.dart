import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../app/theme/app_colors.dart';
import '../../../data/models/vehicle_category_model.dart';
import '../../../data/repositories/vehicle_category_repository.dart';
import '../../../domain/providers/vehicle_category_provider.dart';

class ManageCategoriesScreen extends ConsumerWidget {
  const ManageCategoriesScreen({super.key});

  /// A curated set of Material icon options for vehicle categories
  static const Map<String, IconData> iconOptions = {
    'directions_car': Icons.directions_car,
    'two_wheeler': Icons.two_wheeler,
    'local_shipping': Icons.local_shipping,
    'directions_bus': Icons.directions_bus,
    'agriculture': Icons.agriculture,
    'fire_truck': Icons.fire_truck,
    'electric_car': Icons.electric_car,
    'pedal_bike': Icons.pedal_bike,
    'airport_shuttle': Icons.airport_shuttle,
    'rv_hookup': Icons.rv_hookup,
  };

  static IconData getIconData(String iconName) {
    return iconOptions[iconName] ?? Icons.directions_car;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(vehicleCategoryStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.mrfBlack,
      appBar: AppBar(
        title: const Text('Vehicle Categories',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCategorySheet(context, ref, null),
        backgroundColor: AppColors.mrfRed,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Category', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.mrfRed)),
        error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.red))),
        data: (categories) {
          if (categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.category_outlined, size: 64, color: Colors.grey.shade800),
                  const SizedBox(height: 16),
                  const Text('No Categories Yet',
                      style: TextStyle(fontSize: 18, color: Colors.white70, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Tap the button below to add vehicle categories.',
                      style: TextStyle(color: Colors.grey.shade500)),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.mrfRed,
            backgroundColor: AppColors.mrfBlack,
            onRefresh: () async => ref.refresh(vehicleCategoryStreamProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.mrfRed.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(getIconData(cat.icon), color: AppColors.mrfRed, size: 28),
                    ),
                    title: Text(cat.name,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          _buildChip('Order: ${cat.sortOrder}', Colors.blue),
                          const SizedBox(width: 8),
                          _buildChip('Icon: ${cat.icon}', Colors.orange),
                        ],
                      ),
                    ),
                    trailing: PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.white54),
                      color: const Color(0xFF2C2C2C),
                      onSelected: (action) {
                        if (action == 'edit') _showCategorySheet(context, ref, cat);
                        if (action == 'delete') _confirmDelete(context, ref, cat);
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(children: [
                            Icon(Icons.edit, color: Colors.white70, size: 18),
                            SizedBox(width: 8),
                            Text('Edit', style: TextStyle(color: Colors.white)),
                          ]),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(children: [
                            Icon(Icons.delete, color: AppColors.mrfRed, size: 18),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: AppColors.mrfRed)),
                          ]),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, VehicleCategoryModel category) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        title: const Text('Delete Category', style: TextStyle(color: Colors.white)),
        content: Text('Permanently delete "${category.name}"?',
            style: TextStyle(color: Colors.grey.shade400)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.white70))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.mrfRed),
            onPressed: () async {
              await ref.read(vehicleCategoryRepositoryProvider).deleteCategory(category.categoryId);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showCategorySheet(BuildContext context, WidgetRef ref, VehicleCategoryModel? existing) {
    final isEdit = existing != null;
    final nameC = TextEditingController(text: existing?.name ?? '');
    final sortC = TextEditingController(text: existing?.sortOrder.toString() ?? '0');
    String selectedIcon = existing?.icon ?? 'directions_car';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                    child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                            color: Colors.grey.shade600,
                            borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 24),
                Text(isEdit ? 'Edit Category' : 'New Category',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 24),
                TextField(
                  controller: nameC,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Category Name *',
                    labelStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                    prefixIcon: Icon(Icons.category, color: Colors.grey.shade600, size: 20),
                    filled: true,
                    fillColor: const Color(0xFF2C2C2C),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.mrfRed, width: 1)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: sortC,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Sort Order',
                    labelStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                    prefixIcon: Icon(Icons.sort, color: Colors.grey.shade600, size: 20),
                    filled: true,
                    fillColor: const Color(0xFF2C2C2C),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.mrfRed, width: 1)),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Select Icon',
                    style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: iconOptions.entries.map((entry) {
                    final isSelected = entry.key == selectedIcon;
                    return GestureDetector(
                      onTap: () => setSheetState(() => selectedIcon = entry.key),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.mrfRed.withValues(alpha: 0.2)
                              : const Color(0xFF2C2C2C),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? AppColors.mrfRed : Colors.white10,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Icon(entry.value,
                            color: isSelected ? AppColors.mrfRed : Colors.white54, size: 26),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mrfRed,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      if (nameC.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Category name is required')));
                        return;
                      }
                      final category = VehicleCategoryModel(
                        categoryId: existing?.categoryId ?? const Uuid().v4(),
                        name: nameC.text.trim(),
                        icon: selectedIcon,
                        sortOrder: int.tryParse(sortC.text) ?? 0,
                        createdAt: existing?.createdAt ?? DateTime.now(),
                      );
                      try {
                        if (isEdit) {
                          await ref.read(vehicleCategoryRepositoryProvider).updateCategory(category);
                        } else {
                          await ref.read(vehicleCategoryRepositoryProvider).addCategory(category);
                        }
                        if (ctx.mounted) Navigator.pop(ctx);
                      } catch (e) {
                        if (ctx.mounted) {
                          ScaffoldMessenger.of(ctx)
                              .showSnackBar(SnackBar(content: Text('Error: $e')));
                        }
                      }
                    },
                    child: Text(isEdit ? 'UPDATE CATEGORY' : 'CREATE CATEGORY',
                        style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
