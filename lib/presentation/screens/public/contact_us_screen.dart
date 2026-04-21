import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../app/theme/app_colors.dart';

class CompanyContactScreen extends StatefulWidget {
  const CompanyContactScreen({super.key});

  @override
  State<CompanyContactScreen> createState() => _CompanyContactScreenState();
}

class _CompanyContactScreenState extends State<CompanyContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _launchUri(Uri uri) async {
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open: $uri')),
        );
      }
    }
  }

  Future<void> _sendMessage() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      await FirebaseFirestore.instance.collection('messages').add({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'subject': _subjectController.text.trim(),
        'message': _messageController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'unread',
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thank you! Your message has been sent successfully.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        _nameController.clear();
        _emailController.clear();
        _phoneController.clear();
        _subjectController.clear();
        _messageController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message. Please try again. ($e)'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Us'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Contact Information',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    children: [
                      // Address — tappable → Google Maps
                      ListTile(
                        leading: const Icon(Icons.location_on, color: AppColors.mrfRed),
                        title: const Text('Address',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: const Text(
                          'Jagadale Retreads, Kalyani Corner, Caterpillar Area, '
                          'Airport Road, MIDC Area, Bandalwadi, Maharashtra 413133',
                        ),
                        onTap: () => _launchUri(Uri.parse(
                          'https://maps.google.com/?q=Jagadale+Retreads+Kalyani+Corner+Bandalwadi+Maharashtra+413133',
                        )),
                        trailing: const Icon(Icons.open_in_new,
                            size: 16, color: Colors.grey),
                      ),
                      const Divider(height: 0),
                      // Phone 1 — tappable → phone call
                      ListTile(
                        leading: const Icon(Icons.phone, color: AppColors.mrfRed),
                        title: const Text('Phone',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: const Text('+91 9637118817'),
                        onTap: () =>
                            _launchUri(Uri(scheme: 'tel', path: '+919637118817')),
                        trailing: const Icon(Icons.call,
                            size: 16, color: AppColors.mrfRed),
                      ),
                      const Divider(height: 0),
                      // Phone 2 — tappable → phone call
                      ListTile(
                        leading: const Icon(Icons.phone_in_talk, color: AppColors.mrfRed),
                        title: const Text('Alternate Phone',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: const Text('+91 8459391282'),
                        onTap: () =>
                            _launchUri(Uri(scheme: 'tel', path: '+918459391282')),
                        trailing: const Icon(Icons.call,
                            size: 16, color: AppColors.mrfRed),
                      ),
                      const Divider(height: 0),
                      // Email — tappable → mail app
                      ListTile(
                        leading: const Icon(Icons.email, color: AppColors.mrfRed),
                        title: const Text('Email',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: const Text('jagadaleretrads@gmail.com'),
                        onTap: () => _launchUri(Uri(
                          scheme: 'mailto',
                          path: 'jagadaleretrads@gmail.com',
                          queryParameters: {'subject': 'Enquiry from App'},
                        )),
                        trailing: const Icon(Icons.open_in_new,
                            size: 16, color: Colors.grey),
                      ),
                      const Divider(height: 0),
                      const ListTile(
                        leading: Icon(Icons.receipt_long, color: AppColors.mrfRed),
                        title: Text('GST Number',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('27AHPPJ4450P1ZO'),
                      ),
                      const Divider(height: 0),
                      const ListTile(
                        leading: Icon(Icons.access_time, color: AppColors.mrfRed),
                        title: Text('Business Hours',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                            'Monday – Saturday: 9:00 AM – 6:00 PM\nSunday: Closed'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text('Send us a Message',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration:
                              const InputDecoration(labelText: 'Full Name *'),
                          validator: (val) =>
                              (val == null || val.trim().isEmpty)
                                  ? 'Full name is required'
                                  : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          decoration:
                              const InputDecoration(labelText: 'Email Address *'),
                          keyboardType: TextInputType.emailAddress,
                          validator: (val) =>
                              (val == null || val.trim().isEmpty)
                                  ? 'Email is required'
                                  : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _phoneController,
                          decoration:
                              const InputDecoration(labelText: 'Phone Number *'),
                          keyboardType: TextInputType.phone,
                          validator: (val) =>
                              (val == null || val.trim().isEmpty)
                                  ? 'Phone number is required'
                                  : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _subjectController,
                          decoration:
                              const InputDecoration(labelText: 'Subject'),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _messageController,
                          decoration:
                              const InputDecoration(labelText: 'Message *'),
                          maxLines: 4,
                          validator: (val) =>
                              (val == null || val.trim().isEmpty)
                                  ? 'Message is required'
                                  : null,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _sendMessage,
                            child: _isSubmitting
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2),
                                  )
                                : const Text('Send Message'),
                          ),
                        ),
                      ],
                    ),
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
