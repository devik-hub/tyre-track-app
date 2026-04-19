import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firebase_constants.dart';
import '../models/product_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) => ProductRepository());

class ProductRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<ProductModel>> getProducts() async {
    try {
      final snapshot = await _firestore.collection(FirebaseConstants.productsCollection).get();
      return snapshot.docs.map((doc) => ProductModel.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      throw Exception('Failed to load products: $e');
    }
  }

  Future<ProductModel?> getProductById(String id) async {
    try {
      final doc = await _firestore.collection(FirebaseConstants.productsCollection).doc(id).get();
      if (doc.exists) {
         return ProductModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to load product: $e');
    }
  }
}
