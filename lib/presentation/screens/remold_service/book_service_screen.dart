import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../app/theme/clay_decorations.dart';
import '../../../app/routes/app_routes.dart';
import '../../../domain/providers/auth_provider.dart';
import '../../../domain/providers/vehicle_provider.dart';
import '../../../data/services/razorpay_service.dart';
import '../../../widgets/clay_chip.dart';
import '../../widgets/glass/liquid_glass_app_bar.dart';
import '../../widgets/glass/liquid_glass_button.dart';
import '../../widgets/glass/liquid_glass_text_field.dart';
import '../../widgets/glass/customer_background.dart';

class BookServiceScreen extends ConsumerStatefulWidget {
  const BookServiceScreen({super.key});
  @override
  ConsumerState<BookServiceScreen> createState() => _BookServiceScreenState();
}

class _BookServiceScreenState extends ConsumerState<BookServiceScreen> {
  int _currentStep = 0;
  String _selectedService = 'Retreading';
  String? _selectedVehicleId;
  final Set<String> _selectedPositions = {'Front Left'};
  DateTime? _selectedDate;
  String _selectedTimeSlot = 'Morning (9-12)';
  final _issueController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _issueController.dispose();
    super.dispose();
  }

  Future<void> _submitBooking() async {
    final user = ref.read(authProvider).userModel;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please login.')));
      return;
    }
    setState(() => _isProcessing = true);
    final razorpay = ref.read(razorpayServiceProvider);
    razorpay.onSuccess = (response) async {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Service Booked Successfully!')));
        context.go('/home');
      }
    };
    razorpay.onFailure = (response) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment Failed: ${response.message}')),
        );
        setState(() => _isProcessing = false);
      }
    };
    final double cost = _selectedService == 'Retreading' ? 1200.0 : 500.0;
    razorpay.openCheckout(
      amount: cost,
      contact: user.phone,
      email: user.email,
      description: 'Jagadale Retreads: $_selectedService',
    );
  }

  @override
  Widget build(BuildContext context) {
    final vehicleState = ref.watch(vehicleProvider);
    final vehicles = vehicleState.valueOrNull ?? [];

    if (_selectedVehicleId == null && vehicles.isNotEmpty) {
      _selectedVehicleId = vehicles.first.vehicleId;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomerBackground(
        child: Column(
          children: [
            const LiquidGlassAppBar(
              title: 'Book a Service',
              showBrandSubtitle: true,
            ),
            Expanded(
              child: Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: Theme.of(context).colorScheme.copyWith(
                    primary: AppColors.primary,
                  ),
                ),
                child: Stepper(
                  currentStep: _currentStep,
                  onStepContinue: () {
                    if (_currentStep == 1) {
                      if (vehicles.isEmpty || _selectedVehicleId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please add and select a vehicle to proceed.')),
                        );
                        return;
                      }
                      if (_selectedPositions.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please select at least one tyre position.')),
                        );
                        return;
                      }
                    } else if (_currentStep == 3) {
                      if (_selectedDate == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please select a booking appointment date.')),
                        );
                        return;
                      }
                    }

                    if (_currentStep < 3) {
                      setState(() => _currentStep += 1);
                    } else if (!_isProcessing) {
                      _submitBooking();
                    }
                  },
                  onStepCancel: () {
                    if (_currentStep > 0 && !_isProcessing) {
                      setState(() => _currentStep -= 1);
                    }
                  },
                  controlsBuilder: (ctx, details) => Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: Row(
                      children: [
                        Expanded(
                          child: LiquidGlassButton(
                            label: _currentStep == 3 ? 'Pay & Confirm' : 'Continue',
                            isLoading: _isProcessing && _currentStep == 3,
                            onPressed: _isProcessing ? null : details.onStepContinue,
                          ),
                        ),
                        if (_currentStep > 0) ...[
                          const Gap(12),
                          Expanded(
                            child: LiquidGlassButton(
                              label: 'Back',
                              variant: GlassButtonVariant.secondary,
                              onPressed: _isProcessing ? null : details.onStepCancel,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  steps: [
                    Step(
                      title: Text('Service Type', style: AppTextStyles.label1),
                      isActive: _currentStep >= 0,
                      content: DropdownButtonFormField<String>(
                        value: _selectedService,
                        items: ['Retreading', 'Remoulding', 'Inspection', 'New Fitment']
                            .map((s) => DropdownMenuItem(value: s, child: Text(s, style: AppTextStyles.bodyMedium)))
                            .toList(),
                        onChanged: (v) => setState(() => _selectedService = v!),
                        decoration: ClayDecorations.inputDecoration(
                          labelText: 'Select Service',
                          prefixIcon: const Icon(LucideIcons.wrench, color: AppColors.primary, size: 20),
                        ),
                      ),
                    ),
                    Step(
                      title: Text('Vehicle & Position', style: AppTextStyles.label1),
                      isActive: _currentStep >= 1,
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (vehicles.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(LucideIcons.alertCircle, color: AppColors.primary, size: 20),
                                  const Gap(10),
                                  Expanded(
                                    child: Text(
                                      'No vehicles found in your garage.',
                                      style: AppTextStyles.body2.copyWith(color: AppColors.textPrimary),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => context.push(AppRoutes.vehicles),
                                    child: const Text('Add Vehicle', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            )
                          else
                            DropdownButtonFormField<String>(
                              value: vehicles.any((v) => v.vehicleId == _selectedVehicleId)
                                  ? _selectedVehicleId
                                  : vehicles.first.vehicleId,
                              items: vehicles
                                  .map((v) => DropdownMenuItem(
                                        value: v.vehicleId,
                                        child: Text(
                                          '${v.make} ${v.model} (${v.registrationNumber})',
                                          style: AppTextStyles.bodyMedium,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ))
                                  .toList(),
                              onChanged: (v) {
                                if (v != null) setState(() => _selectedVehicleId = v);
                              },
                              decoration: ClayDecorations.inputDecoration(
                                labelText: 'Select Vehicle',
                                prefixIcon: const Icon(LucideIcons.truck, color: AppColors.primary, size: 20),
                              ),
                            ),
                          const Gap(16),
                          Text('Select Tyre Position(s):', style: AppTextStyles.label2.copyWith(color: AppColors.textSecondary)),
                          const Gap(8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: ['Front Left', 'Front Right', 'Rear Left', 'Rear Right', 'Spare'].map((p) {
                              final isSelected = _selectedPositions.contains(p);
                              return ClayChip(
                                label: p,
                                isSelected: isSelected,
                                onTap: () {
                                  setState(() {
                                    if (isSelected) {
                                      _selectedPositions.remove(p);
                                    } else {
                                      _selectedPositions.add(p);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    Step(
                      title: Text('Issue Description', style: AppTextStyles.label1),
                      isActive: _currentStep >= 2,
                      content: Column(
                        children: [
                          LiquidGlassTextField(
                            controller: _issueController,
                            hintText: 'Describe tyre tread condition, depth, punctures, or vibration issues...',
                            maxLines: 3,
                            prefixIcon: LucideIcons.fileText,
                          ),
                          const Gap(12),
                          LiquidGlassButton(
                            label: 'Upload Tyre Photos',
                            icon: LucideIcons.camera,
                            variant: GlassButtonVariant.secondary,
                            height: 44,
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                    Step(
                      title: Text('Schedule Appointment', style: AppTextStyles.label1),
                      isActive: _currentStep >= 3,
                      content: Column(
                        children: [
                          LiquidGlassButton(
                            label: _selectedDate == null
                                ? 'Select Booking Date'
                                : 'Date: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                            icon: LucideIcons.calendar,
                            variant: GlassButtonVariant.secondary,
                            height: 48,
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 30)),
                              );
                              if (picked != null) {
                                setState(() => _selectedDate = picked);
                              }
                            },
                          ),
                          const Gap(16),
                          DropdownButtonFormField<String>(
                            value: _selectedTimeSlot,
                            items: ['Morning (9-12)', 'Afternoon (12-4)', 'Evening (4-7)']
                                .map((t) => DropdownMenuItem(value: t, child: Text(t, style: AppTextStyles.bodyMedium)))
                                .toList(),
                            onChanged: (v) {
                              if (v != null) setState(() => _selectedTimeSlot = v);
                            },
                            decoration: ClayDecorations.inputDecoration(
                              labelText: 'Preferred Time Slot',
                              prefixIcon: const Icon(LucideIcons.clock, color: AppColors.primary, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
