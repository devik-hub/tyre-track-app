import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../domain/providers/vehicle_provider.dart';

class VehicleListScreen extends ConsumerWidget {
  const VehicleListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicleState = ref.watch(vehicleProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Vehicles')),
      body: vehicleState.when(
        data: (vehicles) {
           if (vehicles.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                     const Icon(Icons.directions_car_outlined, size: 80, color: Colors.grey),
                     const SizedBox(height: 16),
                     const Text('No vehicles added yet', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  ]
                ),
              );
           }
           return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: vehicles.length,
              itemBuilder: (context, index) {
                 final vehicle = vehicles[index];
                 return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                       padding: const EdgeInsets.all(16.0),
                       child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                             Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(color: AppColors.mrfRed.withOpacity(0.1), shape: BoxShape.circle),
                                child: const Icon(Icons.directions_car, color: AppColors.mrfRed, size: 32),
                             ),
                             const SizedBox(width: 16),
                             Expanded(
                                child: Column(
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                   children: [
                                      Text('${vehicle.make} ${vehicle.model}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                      Text(vehicle.registrationNumber, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
                                      const SizedBox(height: 4),
                                      Text('Year: ${vehicle.year}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                   ],
                                ),
                             ),
                             IconButton(
                                icon: const Icon(Icons.delete_outline, color: AppColors.mrfRed),
                                onPressed: () {
                                   ref.read(vehicleProvider.notifier).deleteVehicle(vehicle.vehicleId);
                                },
                             )
                          ]
                       )
                    )
                 );
              },
           );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.mrfRed)),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.mrfRed,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
