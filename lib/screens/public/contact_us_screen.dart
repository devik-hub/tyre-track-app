import 'package:flutter/material.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Us'),
      ),
      body: SingleChildScrollView(
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
                    children: const [
                      ListTile(
                        leading: Icon(Icons.location_on, color: Colors.red),
                        title: Text('Address'),
                        subtitle: Text('Jagadale Retreads, Near Khed Shivapur Toll Plaza, Pune-Satara Highway, Pune, Maharashtra 412205'),
                      ),
                      ListTile(
                        leading: Icon(Icons.phone, color: Colors.red),
                        title: Text('Phone'),
                        subtitle: Text('+91 98222 89488'),
                      ),
                      ListTile(
                        leading: Icon(Icons.email, color: Colors.red),
                        title: Text('Email'),
                        subtitle: Text('jagadaleretrads@gmail.com'),
                      ),
                      ListTile(
                        leading: Icon(Icons.access_time, color: Colors.red),
                        title: Text('Business Hours'),
                        subtitle: Text('Monday - Saturday: 9:00 AM - 6:00 PM\nSunday: Closed'),
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
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Full Name *'),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Email Address *'),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Phone Number *'),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Subject'),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Message *'),
                        maxLines: 4,
                      ),
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
    );
  }
}
