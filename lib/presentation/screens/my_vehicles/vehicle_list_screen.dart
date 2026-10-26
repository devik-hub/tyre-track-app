import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../data/models/vehicle_model.dart';
import '../../../domain/providers/vehicle_provider.dart';
import '../../widgets/glass/liquid_glass_card.dart';
import '../../widgets/glass/liquid_glass_app_bar.dart';
import '../../widgets/glass/liquid_glass_button.dart';
import '../../widgets/glass/liquid_glass_text_field.dart';
import '../../widgets/glass/customer_background.dart';

class VehicleListScreen extends ConsumerWidget {
  const VehicleListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicleState = ref.watch(vehicleProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const LiquidGlassAppBar(
        title: 'My Vehicles',
        showBrandSubtitle: true,
      ),
      body: CustomerBackground(
        child: vehicleState.when(
          data: (vehicles) {
            if (vehicles.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Icon(LucideIcons.truck, size: 44, color: AppColors.primary),
                      ),
                      const Gap(20),
                      Text(
                        'No Vehicles Added',
                        style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary),
                      ),
                      const Gap(8),
                      Text(
                        'Register your trucks, light commercial vehicles, or cars for fast service bookings and retread tracking.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
                      ),
                      const Gap(24),
                      LiquidGlassButton(
                        label: 'Add Your First Vehicle',
                        icon: LucideIcons.plus,
                        onPressed: () => _showAddVehicleSheet(context, ref),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: vehicles.length,
              itemBuilder: (ctx, i) {
                final v = vehicles[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: LiquidGlassCard(
                    blurStrength: 10,
                    borderRadius: 20,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary.withValues(alpha: 0.1),
                          ),
                          child: const Icon(LucideIcons.truck, color: AppColors.primary, size: 26),
                        ),
                        const Gap(16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${v.make} ${v.model}',
                                style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
                              ),
                              const Gap(2),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryDark.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  v.registrationNumber.toUpperCase(),
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.primaryDark,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                              const Gap(4),
                              Text(
                                'Year ${v.year} • ${v.vehicleType}',
                                style: AppTextStyles.body2.copyWith(color: AppColors.textTertiary),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _confirmDeleteVehicle(context, ref, v),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.error.withValues(alpha: 0.1),
                            ),
                            child: const Icon(LucideIcons.trash2, color: AppColors.error, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
          error: (e, _) => Center(
            child: Text('Error loading vehicles: $e', style: AppTextStyles.body1.copyWith(color: AppColors.error)),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddVehicleSheet(context, ref),
        backgroundColor: AppColors.primary,
        elevation: 6,
        child: const Icon(LucideIcons.plus, color: Colors.white, size: 26),
      ),
    );
  }

  Future<void> _confirmDeleteVehicle(BuildContext context, WidgetRef ref, VehicleModel vehicle) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Vehicle', style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary)),
        content: Text(
          'Are you sure you want to delete ${vehicle.make} ${vehicle.model} (${vehicle.registrationNumber})?',
          style: AppTextStyles.body1.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancel', style: AppTextStyles.button.copyWith(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Delete', style: AppTextStyles.button.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref.read(vehicleProvider.notifier).deleteVehicle(vehicle.vehicleId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${vehicle.make} ${vehicle.model} removed.')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete: $e')),
          );
        }
      }
    }
  }

  void _showAddVehicleSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AddVehicleSheet(
        onSaved: (regNum, make, model, year, type) async {
          await ref.read(vehicleProvider.notifier).addVehicle(
            regNum: regNum,
            make: make,
            model: model,
            year: year,
            type: type,
          );
        },
      ),
    );
  }
}

class _AddVehicleSheet extends StatefulWidget {
  final Future<void> Function(String regNum, String make, String model, int year, String type) onSaved;

  const _AddVehicleSheet({required this.onSaved});

  @override
  State<_AddVehicleSheet> createState() => _AddVehicleSheetState();
}

class _AddVehicleSheetState extends State<_AddVehicleSheet> {
  final _formKey = GlobalKey<FormState>();
  final _regNumController = TextEditingController();
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController(text: DateTime.now().year.toString());
  String _selectedType = 'Commercial Truck';
  bool _isLoading = false;

  final _vehicleTypes = ['Commercial Truck', 'Light Commercial (LCV)', 'Bus / Coach', 'Passenger Car', 'Tractor / Agri'];

  @override
  void dispose() {
    _regNumController.dispose();
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final year = int.tryParse(_yearController.text.trim()) ?? DateTime.now().year;
      await widget.onSaved(
        _regNumController.text.trim().toUpperCase(),
        _makeController.text.trim(),
        _modelController.text.trim(),
        year,
        _selectedType,
      );
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vehicle added successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding vehicle: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        top: 24,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Add New Vehicle', style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary)),
                  IconButton(
                    icon: const Icon(LucideIcons.x, size: 22, color: AppColors.textTertiary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Gap(16),
              LiquidGlassTextField(
                controller: _regNumController,
                labelText: 'Registration Number',
                hintText: 'e.g. MH 12 AB 1234',
                prefixIcon: LucideIcons.creditCard,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Registration number is required';
                  return null;
                },
              ),
              const Gap(12),
              Row(
                children: [
                  Expanded(
                    child: LiquidGlassTextField(
                      controller: _makeController,
                      labelText: 'Make / Manufacturer',
                      hintText: 'e.g. Tata, Mahindra',
                      prefixIcon: LucideIcons.wrench,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Make is required';
                        return null;
                      },
                    ),
                  ),
                  const Gap(10),
                  Expanded(
                    child: LiquidGlassTextField(
                      controller: _modelController,
                      labelText: 'Model',
                      hintText: 'e.g. Ace, 1616',
                      prefixIcon: LucideIcons.truck,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Model is required';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const Gap(12),
              Row(
                children: [
                  Expanded(
                    child: LiquidGlassTextField(
                      controller: _yearController,
                      labelText: 'Model Year',
                      hintText: 'e.g. 2022',
                      keyboardType: TextInputType.number,
                      prefixIcon: LucideIcons.calendar,
                      validator: (val) {
                        final yr = int.tryParse(val ?? '');
                        if (yr == null || yr < 1980 || yr > DateTime.now().year + 1) {
                          return 'Enter valid year';
                        }
                        return null;
                      },
                    ),
                  ),
                  const Gap(10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Vehicle Type', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                        const Gap(6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFBF8F8),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE8DCDC)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedType,
                              isExpanded: true,
                              style: AppTextStyles.body2.copyWith(color: AppColors.textPrimary),
                              items: _vehicleTypes
                                  .map((t) => DropdownMenuItem(value: t, child: Text(t, overflow: TextOverflow.ellipsis)))
                                  .toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedType = val);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Gap(24),
              LiquidGlassButton(
                label: 'Save Vehicle',
                icon: LucideIcons.check,
                isLoading: _isLoading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
