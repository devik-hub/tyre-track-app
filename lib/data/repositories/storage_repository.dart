import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final storageRepositoryProvider =
    Provider<StorageRepository>((ref) => StorageRepository());

class StorageRepository {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload a product image to Firebase Storage and return the download URL
  Future<String> uploadProductImage(String productId, File imageFile) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final ref = _storage.ref().child('products/$productId/$timestamp.jpg');

    final uploadTask = ref.putFile(
      imageFile,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  /// Delete an image from Firebase Storage by its URL
  Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (_) {
      // Image may already be deleted or URL may be invalid
    }
  }
}
