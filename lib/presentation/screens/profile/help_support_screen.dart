import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
             const Text('How can we help you today?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
             const SizedBox(height: 24),
             _buildContactCard(
               icon: Icons.phone,
               title: 'Call Us (Primary)',
               subtitle: '+91 9637118817',
               onTap: () => _launchUrl('tel:+919637118817'),
             ),
             const SizedBox(height: 16),
             _buildContactCard(
               icon: Icons.phone_in_talk,
               title: 'Call Us (Alternate)',
               subtitle: '+91 8459391282',
               onTap: () => _launchUrl('tel:+918459391282'),
             ),
             const SizedBox(height: 16),
             _buildContactCard(
               icon: Icons.email,
               title: 'Email Us',
               subtitle: 'jagadaleretrads@gmail.com',
               onTap: () => _launchUrl('mailto:jagadaleretrads@gmail.com'),
             ),
             const SizedBox(height: 16),
             _buildContactCard(
               icon: Icons.location_on,
               title: 'Visit our Workshop',
               subtitle: 'Kalyani Corner, Caterpillar Area, Airport Road, MIDC Area, Bandalwadi, Maharashtra 413133',
               onTap: () => _launchUrl('https://maps.google.com/?q=Jagadale+Retreads+Bandalwadi+Maharashtra'),
             ),
             const Divider(height: 48),
             const Text('Frequently Asked Questions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
             const SizedBox(height: 16),
             _buildFAQ('What is your retreading warranty?', 'We offer a standard 2-year warranty on all retreading services.'),
             _buildFAQ('How long does a service take?', 'Standard retreading takes 24-48 hours depending on queue.'),
          ],
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
