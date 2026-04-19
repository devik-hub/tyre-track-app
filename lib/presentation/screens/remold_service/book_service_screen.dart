import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';

class BookServiceScreen extends StatefulWidget {
  const BookServiceScreen({super.key});

  @override
  State<BookServiceScreen> createState() => _BookServiceScreenState();
}

class _BookServiceScreenState extends State<BookServiceScreen> {
  int _currentStep = 0;
  String _selectedService = 'Retreading';
  final _issueController = TextEditingController();

  Future<void> _submitBooking() async {
     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking Confirmed!')));
     Navigator.pop(context);
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
            _submitBooking();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) setState(() => _currentStep -= 1);
        },
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.only(top: 24.0),
            child: Row(
              children: [
                Expanded(child: ElevatedButton(onPressed: details.onStepContinue, child: Text(_currentStep == 3 ? 'Confirm Booking' : 'Continue'))),
                const SizedBox(width: 16),
                if (_currentStep > 0)
                   Expanded(child: OutlinedButton(onPressed: details.onStepCancel, child: const Text('Back'))),
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
