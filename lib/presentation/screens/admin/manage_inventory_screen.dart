import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';

class ManageInventoryScreen extends StatelessWidget {
  const ManageInventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Inventory', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.mrfBlack,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (context, index) {
          final isLowStock = index == 1;
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Container(width: 48, height: 48, color: Colors.grey[200], child: const Icon(Icons.tire_repair)),
              title: const Text('MRF ZTX (195/65 R15)', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(isLowStock ? 'Low Stock: 2 Left' : 'In Stock: 24 units', style: TextStyle(color: isLowStock ? AppColors.mrfOrange : Colors.grey)),
              trailing: IconButton(icon: const Icon(Icons.edit, color: AppColors.mrfBlack), onPressed: () {}),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.mrfBlack,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
