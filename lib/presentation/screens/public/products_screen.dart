import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';

class CompanyProductsScreen extends StatelessWidget {
  const CompanyProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final products = [
      {
        'title': 'Auto Tires',
        'size': '4.50-10',
        'features': ['Perfect for small vehicles', 'Enhanced grip', 'Long-lasting tread'],
        'icon': Icons.directions_car,
      },
      {
        'title': 'Bias & Radial',
        'size': '12.00-20',
        'features': ['Heavy-duty performance', 'Superior durability', 'All-terrain capability'],
        'icon': Icons.local_shipping,
      },
      {
        'title': 'Tubeless 17.5',
        'size': '17.5',
        'features': ['Modern design', 'Fuel efficiency', 'Smooth operation'],
        'icon': Icons.tire_repair,
      },
      {
        'title': 'Tubeless 22.5',
        'size': '22.5',
        'features': ['Maximum load capacity', 'Extended lifespan', 'Premium quality'],
        'icon': Icons.fire_truck,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Our Products'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              color: AppColors.mrfRed,
              child: const Column(
                children: [
                  Text(
                    'Premium Retreaded Tires',
                    style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Quality and reliability for every journey',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.6,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  final features = product['features'] as List<String>;
                  return Card(
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Center(
                              child: Icon(
                                product['icon'] as IconData,
                                size: 80,
                                color: Colors.blueGrey,
                              ),
                            ),
                          ),
                          const Divider(),
                          Expanded(
                            flex: 5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product['title'] as String,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                Text(
                                  'Size: ${product['size']}',
                                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                                ),
                                const SizedBox(height: 8),
                                ...features.map((f) => Padding(
                                      padding: const EdgeInsets.only(bottom: 4.0),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Icon(Icons.check, size: 16, color: Colors.green),
                                          const SizedBox(width: 4),
                                          Expanded(child: Text(f, style: const TextStyle(fontSize: 12))),
                                        ],
                                      ),
                                    )),
                                const Spacer(),
                                ElevatedButton(
                                  onPressed: () {
                                    context.push('/home'); // Fallback to Dashboard if booking route unregistered alone
                                  },
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(double.infinity, 36),
                                  ),
                                  child: const Text('Order Now', style: TextStyle(fontSize: 12)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
