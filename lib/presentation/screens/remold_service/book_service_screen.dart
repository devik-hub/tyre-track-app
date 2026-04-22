import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/routes/app_routes.dart';
import '../../../domain/providers/auth_provider.dart';
import '../../../data/repositories/booking_repository.dart';
import '../../../data/models/booking_model.dart';

class BookServiceScreen extends ConsumerStatefulWidget {
  final String serviceType;
  const BookServiceScreen({super.key, required this.serviceType});

  @override
  ConsumerState<BookServiceScreen> createState() => _BookServiceScreenState();
}

class _BookServiceScreenState extends ConsumerState<BookServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tyreBrandController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _locationController = TextEditingController();
  final _contactController = TextEditingController();
  final _receiverController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill contact from logged-in user
    final user = ref.read(authProvider).userModel;
    if (user != null) {
      _contactController.text = user.phone;
      _receiverController.text = user.name;
    }
  }

  @override
  void dispose() {
    _tyreBrandController.dispose();
    _quantityController.dispose();
    _locationController.dispose();
    _contactController.dispose();
    _receiverController.dispose();
    super.dispose();
  }

  String get _serviceTitle {
    switch (widget.serviceType) {
      case 'retreading': return 'Retreading';
      case 'remoulding': return 'Remoulding';
      case 'inspection': return 'Inspection';
      case 'new_fitment': return 'New Fitment';
      default: return widget.serviceType;
    }
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(authProvider).userModel;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to book a service.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final bookingId = DateTime.now().millisecondsSinceEpoch.toString();
      final booking = BookingModel(
        bookingId: bookingId,
        customerId: user.uid,
        serviceType: widget.serviceType,
        status: 'pending',
        createdAt: DateTime.now(),
        tyreBrand: _tyreBrandController.text.trim(),
        quantity: int.tryParse(_quantityController.text.trim()) ?? 1,
        location: _locationController.text.trim(),
        contactNumber: _contactController.text.trim(),
        receiverName: _receiverController.text.trim(),
      );

      await ref.read(bookingRepositoryProvider).createBooking(booking);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Service booked successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        context.go(AppRoutes.home);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Booking failed: $e')),
        );
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book $_serviceTitle'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ─── Service Type Badge ───
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.mrfRed.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.mrfRed.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.build_circle, color: AppColors.mrfRed, size: 28),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Selected Service', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        Text(_serviceTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.mrfRed)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // ─── Tyre Brand / Type ───
              const Text('Tyre Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _tyreBrandController,
                decoration: InputDecoration(
                  labelText: 'Tyre Brand / Type *',
                  hintText: 'e.g. MRF ZVTV 185/65 R15',
                  prefixIcon: const Icon(Icons.tire_repair),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter tyre brand/type' : null,
              ),
              const SizedBox(height: 16),

              // ─── Quantity ───
              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Number of Tyres *',
                  prefixIcon: const Icon(Icons.numbers),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Enter quantity';
                  final n = int.tryParse(v.trim());
                  if (n == null || n < 1 || n > 50) return 'Enter a number between 1 and 50';
                  return null;
                },
              ),
              const SizedBox(height: 28),

              // ─── Location ───
              const Text('Pickup / Service Location', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _locationController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Full Address *',
                  hintText: 'Street, Area, City, Pincode',
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter the address' : null,
              ),
              const SizedBox(height: 28),

              // ─── Contact Details ───
              const Text('Contact Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _receiverController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Receiver Name *',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter receiver name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contactController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Mobile Number *',
                  prefixText: '+91 ',
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Please enter mobile number';
                  final digits = v.trim().replaceAll(RegExp(r'[^0-9]'), '');
                  if (digits.length < 10) return 'Enter a valid 10-digit number';
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // ─── Submit ───
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitBooking,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: _isSubmitting
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Confirm Booking', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
