import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddTyreScreen extends StatefulWidget {
  const AddTyreScreen({super.key});

  @override
  State<AddTyreScreen> createState() => _AddTyreScreenState();
}

class _AddTyreScreenState extends State<AddTyreScreen> {
  // Controllers
  final TextEditingController brandController = TextEditingController();
  final TextEditingController mileageController = TextEditingController();
  final TextEditingController serialNumberController = TextEditingController();
  final TextEditingController vehicleTypeController = TextEditingController();

  DateTime? _purchaseDate;

  // Checkbox values
  bool wornTread = false;
  bool cracks = false;
  bool bulge = false;
  bool _isSaving = false;

  // Save function
  Future<void> _pickPurchaseDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _purchaseDate ?? now,
      firstDate: DateTime(2000),
      lastDate: now,
    );
    if (picked != null) {
      setState(() {
        _purchaseDate = picked;
      });
    }
  }

  Future<void> saveTyre() async {
    final brand = brandController.text.trim();
    if (brand.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Brand cannot be empty")),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await FirebaseFirestore.instance.collection('tyres').add({
        'brand': brand,
        'mileage': int.tryParse(mileageController.text.trim()) ?? 0,
        'serial': serialNumberController.text.trim(),
        'vehicle': vehicleTypeController.text.trim(),
        'purchaseDate': _purchaseDate != null ? Timestamp.fromDate(_purchaseDate!) : null,
        'wornTread': wornTread,
        'cracks': cracks,
        'bulge': bulge,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      // Success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tyre added successfully")),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Tyre"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Brand
            TextField(
              controller: brandController,
              decoration: const InputDecoration(
                labelText: "Brand",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Serial Number
            TextField(
              controller: serialNumberController,
              decoration: const InputDecoration(
                labelText: "Serial Number",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Vehicle Type
            TextField(
              controller: vehicleTypeController,
              decoration: const InputDecoration(
                labelText: "Vehicle Type",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Purchase Date
            Row(
              children: [
                Expanded(
                  child: Text(
                    _purchaseDate == null
                        ? "No Purchase Date Selected"
                        : "Purchase Date: ${_purchaseDate!.year}-${_purchaseDate!.month.toString().padLeft(2, '0')}-${_purchaseDate!.day.toString().padLeft(2, '0')}",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                OutlinedButton(
                  onPressed: _pickPurchaseDate,
                  child: const Text("Choose Date"),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Mileage
            TextField(
              controller: mileageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Mileage",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Worn tread
            CheckboxListTile(
              title: const Text("Worn Tread"),
              value: wornTread,
              onChanged: (val) {
                setState(() {
                  wornTread = val!;
                });
              },
            ),

            // Cracks
            CheckboxListTile(
              title: const Text("Cracks"),
              value: cracks,
              onChanged: (val) {
                setState(() {
                  cracks = val!;
                });
              },
            ),

            // Bulge
            CheckboxListTile(
              title: const Text("Bulge"),
              value: bulge,
              onChanged: (val) {
                setState(() {
                  bulge = val!;
                });
              },
            ),

            const SizedBox(height: 20),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : saveTyre,
                child: _isSaving 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text("Save Tyre"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}