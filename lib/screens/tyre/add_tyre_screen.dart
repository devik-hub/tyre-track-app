import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddTyreScreen extends StatefulWidget {
  const AddTyreScreen({super.key});

  @override
  State<AddTyreScreen> createState() => _AddTyreScreenState();
}

class _AddTyreScreenState extends State<AddTyreScreen> {
  final _brandController = TextEditingController();
  final _mileageController = TextEditingController();
  bool _wornTread = false;
  bool _cracks = false;
  bool _bulge = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _brandController.dispose();
    _mileageController.dispose();
    super.dispose();
  }

  Future<void> _saveTyre() async {
    final brand = _brandController.text.trim();
    final mileage = int.tryParse(_mileageController.text.trim());
    if (brand.isEmpty || mileage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter brand and valid mileage')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await FirebaseFirestore.instance.collection('tyres').add({
        'brand': brand,
        'mileage': mileage,
        'wornTread': _wornTread,
        'cracks': _cracks,
        'bulge': _bulge,
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to add tyre: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Tyre')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _brandController,
              decoration: const InputDecoration(
                labelText: 'Brand',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _mileageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Mileage',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              value: _wornTread,
              onChanged: (v) => setState(() => _wornTread = v ?? false),
              title: const Text('Worn tread'),
            ),
            CheckboxListTile(
              value: _cracks,
              onChanged: (v) => setState(() => _cracks = v ?? false),
              title: const Text('Cracks'),
            ),
            CheckboxListTile(
              value: _bulge,
              onChanged: (v) => setState(() => _bulge = v ?? false),
              title: const Text('Bulge'),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveTyre,
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save Tyre'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}