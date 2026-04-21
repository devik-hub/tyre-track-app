import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/routes/app_routes.dart';
import '../../../domain/providers/business_info_provider.dart';

class CompanyContactScreen extends ConsumerWidget {
  const CompanyContactScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final infoAsync = ref.watch(businessInfoProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Contact Us')),
      body: infoAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.mrfRed)),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (info) => SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Contact Information',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.location_on, color: AppColors.mrfRed),
                          title: const Text('Address', style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(info.address),
                          onTap: () => launchUrl(Uri.parse(info.googleMapsUrl)),
                        ),
                        ListTile(
                          leading: const Icon(Icons.phone, color: AppColors.mrfRed),
                          title: const Text('Phone', style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(info.phone),
                          onTap: () => launchUrl(Uri.parse('tel:${info.phone}')),
                        ),
                        ListTile(
                          leading: const Icon(Icons.email, color: AppColors.mrfRed),
                          title: const Text('Email', style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(info.email),
                          onTap: () => launchUrl(Uri.parse('mailto:${info.email}')),
                        ),
                        Builder(
                          builder: (context) {
                            final hours = info.businessHours;
                            String hoursText = '';
                            final days = ['monday','tuesday','wednesday','thursday','friday','saturday','sunday'];
                            for (final d in days) {
                              final s = hours[d];
                              if (s == null) continue;
                              final dayName = d[0].toUpperCase() + d.substring(1);
                              hoursText += s.isOpen ? '$dayName: ${s.openTime} — ${s.closeTime}\n' : '$dayName: Closed\n';
                            }
                            return ListTile(
                              leading: const Icon(Icons.access_time, color: AppColors.mrfRed),
                              title: const Text('Business Hours', style: TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(hoursText.trim()),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Send us a Message',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        TextFormField(decoration: const InputDecoration(labelText: 'Full Name *')),
                        const SizedBox(height: 16),
                        TextFormField(decoration: const InputDecoration(labelText: 'Email Address *')),
                        const SizedBox(height: 16),
                        TextFormField(decoration: const InputDecoration(labelText: 'Phone Number *'), keyboardType: TextInputType.phone),
                        const SizedBox(height: 16),
                        TextFormField(decoration: const InputDecoration(labelText: 'Subject')),
                        const SizedBox(height: 16),
                        TextFormField(decoration: const InputDecoration(labelText: 'Message *'), maxLines: 4),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Thank you! Message sent.')),
                            );
                          },
                          child: const Text('Send Message'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
