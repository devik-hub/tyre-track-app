import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/routes/app_routes.dart';
import '../../../domain/providers/service_availability_provider.dart';
import '../../../domain/providers/auth_provider.dart';

class ServicesHomeScreen extends ConsumerWidget{
  const ServicesHomeScreen({super.key});

  static const List<Map<String, dynamic>> _allServices = [
    {'key': 'retreading', 'title': 'Retreading', 'icon': Icons.sync, 'desc': 'Extend the life of your tyre with premium MRF treading.'},
    {'key': 'remoulding', 'title': 'Remoulding', 'icon': Icons.layers, 'desc': 'Complete tyre rebuild for superior safety.'},
    {'key': 'inspection', 'title': 'Inspection', 'icon': Icons.search, 'desc': 'Detailed 25-point safety check.'},
    {'key': 'new_fitment', 'title': 'New Fitment', 'icon': Icons.build, 'desc': 'Professional installation of new tyres.'},
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref){
    final availabilityAsync = ref.watch(serviceAvailabilityProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Services'),
      ),
      body: availabilityAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e'),),
        data: (availability){
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _allServices.length,
            itemBuilder: (context,index){
              final service = _allServices[index];
              final serviceKey = service['key'] as String;
              final isAvailable = availability[serviceKey] ?? true;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Opacity(
                  opacity: isAvailable ? 1.0 : 0.5,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: (isAvailable ? AppColors.mrfRed : Colors.grey).withOpacity(0.1),
                      radius: 30,
                      child: Icon(service['icon'] as IconData, color: isAvailable ? AppColors.mrfRed : Colors.grey, size: 30),
                    ),
                    title: Text(service['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(service['desc'] as String),
                          if(!isAvailable) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.orange.shade200),
                              ),
                              child: const Text('⚠ Not Available Today',
                                style: TextStyle(color: Colors.deepOrange, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    trailing: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: isAvailable ? (){
                        final serviceName = service['title'];
                        print('BOOK BUTTON TAPPED FOR: $serviceName');
                        final user = ref.read(authProvider).userModel;
                        if(user==null){
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please wait for session to load or log in'),
                            ),
                          );
                          return;
                        }
                        context.push(AppRoutes.bookService);
                      } : null,
                      child: IgnorePointer(
                        child: ElevatedButton(
                          onPressed: isAvailable ? () {} : null, // Handled by GestureDetector
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(80, 36),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            disabledBackgroundColor: Colors.grey.shade300,
                          ),
                          child: Text(isAvailable ? 'Book' : 'Closed'),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
