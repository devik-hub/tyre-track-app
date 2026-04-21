import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/routes/app_routes.dart';
import '../../../domain/providers/business_info_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends ConsumerWidget {
  const HelpSupportScreen({super.key});

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final infoAsync = ref.watch(businessInfoProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: infoAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.mrfRed)),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (info) => SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('How can we help you today?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              _buildContactCard(
                icon: Icons.phone,
                title: 'Call Us Now',
                subtitle: info.phone,
                onTap: () => _launchUrl('tel:${info.phone}'),
              ),
              const SizedBox(height: 16),
              _buildContactCard(
                icon: Icons.email,
                title: 'Email Us',
                subtitle: info.email,
                onTap: () => _launchUrl('mailto:${info.email}'),
              ),
              const SizedBox(height: 16),
              _buildContactCard(
                icon: Icons.location_on,
                title: 'Visit our Workshop',
                subtitle: info.address,
                onTap: () => _launchUrl(info.googleMapsUrl),
              ),
              if (info.whatsapp.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildContactCard(
                  icon: Icons.message,
                  title: 'WhatsApp',
                  subtitle: info.whatsapp,
                  onTap: () => _launchUrl('https://wa.me/${info.whatsapp.replaceAll('+', '')}'),
                ),
              ],
              const Divider(height: 48),
              const Text('Frequently Asked Questions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildFAQ('What is your retreading warranty?', 'We offer a standard 2-year warranty on all retreading services.'),
              _buildFAQ('How long does a service take?', 'Standard retreading takes 24-48 hours depending on queue.'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactCard({required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(backgroundColor: AppColors.mrfRed.withOpacity(0.1), child: Icon(icon, color: AppColors.mrfRed)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildFAQ(String q, String a) {
    return ExpansionTile(
      title: Text(q, style: const TextStyle(fontWeight: FontWeight.w600)),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(a, style: const TextStyle(color: Colors.grey)),
        )
      ],
    );
  }
}
