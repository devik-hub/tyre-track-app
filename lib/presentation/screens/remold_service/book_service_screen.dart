import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../domain/providers/auth_provider.dart';
import '../../../data/services/razorpay_service.dart';
// Note: Assuming you have a BookingProvider for actual backend submission.
// Adjust the import if needed.
// import '../../../domain/providers/booking_provider.dart';

class BookServiceScreen extends ConsumerStatefulWidget {
  const BookServiceScreen({super.key});

  @override
  ConsumerState<BookServiceScreen> createState() => _BookServiceScreenState();
}

class _BookServiceScreenState extends ConsumerState<BookServiceScreen> {
  int _currentStep = 0;
  String _selectedService = 'Retreading';
  final _issueController = TextEditingController();
  bool _isProcessing = false;

  Future<void> _submitBooking() async {
    final user = ref.read(authProvider).userModel;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please login to book a service.')));
      return;
    }

    setState(() => _isProcessing = true);
    final razorpay = ref.read(razorpayServiceProvider);

    razorpay.onSuccess = (response) async {
       // Perform backend logic here to register booking in Firestore.
       // e.g. ref.read(bookingProvider.notifier).createBooking(...);

       if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment Successful! Service Booked. ✨')));
           context.go('/home');
       }
    };

    razorpay.onFailure = (response) {
       if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment Cancelled/Failed: ${response.message}')));
           setState(() => _isProcessing = false);
       }
    };

    // Calculate a dummy price based on the selected service for demo purposes
    double estimatedCost = _selectedService == 'Retreading' ? 1200.0 : 500.0;

    razorpay.openCheckout(
       amount: estimatedCost,
       contact: user.phone,
       email: user.email ?? 'customer@jagadale.com',
       description: 'Jagadale Retreads: $_selectedService',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book a Service')),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 3) {
            setState(() => _currentStep += 1);
          } else {
            if (!_isProcessing) {
               _submitBooking();
            }
          }
        },
        onStepCancel: () {
          if (_currentStep > 0 && !_isProcessing) setState(() => _currentStep -= 1);
        },
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.only(top: 24.0),
            child: Row(
              children: [
                Expanded(
                   child: ElevatedButton(
                      onPressed: _isProcessing ? null : details.onStepContinue, 
                      child: _isProcessing && _currentStep == 3
                         ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white))
                         : Text(_currentStep == 3 ? 'Pay & Confirm Booking' : 'Continue')
                   )
                ),
                const SizedBox(width: 16),
                if (_currentStep > 0)
                   Expanded(child: OutlinedButton(onPressed: _isProcessing ? null : details.onStepCancel, child: const Text('Back'))),
              ],
            ),
          );
        },
        steps: [
          Step(
            title: const Text('Service Type'),
            content: DropdownButtonFormField<String>(
              value: _selectedService,
              items: ['Retreading', 'Remoulding', 'Inspection', 'New Fitment', 'Balancing', 'Rotation']
                  .map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (val) => setState(() => _selectedService = val!),
              decoration: const InputDecoration(labelText: 'Select Service'),
            ),
            isActive: _currentStep >= 0,
          ),
          Step(
            title: const Text('Vehicle Details'),
            content: Column(
              children: [
                 DropdownButtonFormField<String>(
                    items: const [DropdownMenuItem(value: 'v1', child: Text('Tata Ace (MH 12 AB 1234)'))],
                    onChanged: (val) {},
                    decoration: const InputDecoration(labelText: 'Select Vehicle'),
                 ),
                 const SizedBox(height: 16),
                 const Text('Select Tyre Positions:'),
                 Wrap(
                    spacing: 8,
                    children: ['Front Left', 'Front Right', 'Rear Left', 'Rear Right', 'Spare'].map((p) => FilterChip(
                      label: Text(p),
                      selected: false,
                      onSelected: (val) {},
                    )).toList(),
                 )
              ],
            ),
            isActive: _currentStep >= 1,
          ),
          Step(
            title: const Text('Issue Description'),
            content: Column(
              children: [
                 TextField(
                    controller: _issueController,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Describe the issue or notes for mechanic'),
                 ),
                 const SizedBox(height: 16),
                 OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Upload Tyre Photos'),
                 )
              ],
            ),
            isActive: _currentStep >= 2,
          ),
          Step(
            title: const Text('Schedule'),
            content: Column(
              children: [
                OutlinedButton.icon(
                   onPressed: () async {
                      await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 30)));
                   },
                   icon: const Icon(Icons.calendar_month),
                   label: const Text('Select Appointment Date'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  items: ['Morning (9AM-12PM)', 'Afternoon (12PM-4PM)', 'Evening (4PM-7PM)'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (v) {},
                  decoration: const InputDecoration(labelText: 'Preferred Time Slot'),
                )
              ],
            ),
            isActive: _currentStep >= 3,
          ),
        ],
      ),
    );
  }
}
