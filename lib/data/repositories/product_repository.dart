import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firebase_constants.dart';
import '../models/product_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) => ProductRepository());

class ProductRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _col => _firestore.collection(FirebaseConstants.productsCollection);

  // ─── Real-Time Stream (all) ───
  Stream<List<ProductModel>> streamProducts() {
    return _col.orderBy('createdAt', descending: true).snapshots().map(
      (snap) => snap.docs.map((doc) => ProductModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList(),
    );
  }

  // ─── Real-Time Stream by category ───
  Stream<List<ProductModel>> streamProductsByCategory(String category) {
    return _col
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => ProductModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList());
  }

  // ─── Real-Time Stream of featured casings ───
  Stream<List<ProductModel>> streamFeaturedCasings() {
    return _col
        .where('category', isEqualTo: 'casing')
        .where('isFeatured', isEqualTo: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => ProductModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList());
  }


  // ─── One-time fetch ───
  Future<List<ProductModel>> getProducts() async {
    final snapshot = await _col.orderBy('createdAt', descending: true).get();
    return snapshot.docs.map((doc) => ProductModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
  }

  Future<ProductModel?> getProductById(String id) async {
    final doc = await _col.doc(id).get();
    if (doc.exists) {
      return ProductModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  // ─── Admin CRUD ───
  Future<void> createProduct(ProductModel product) async {
    await _col.doc(product.productId).set(product.toMap());
  }

  Future<void> updateProduct(ProductModel product) async {
    await _col.doc(product.productId).update(product.toMap());
  }

  Future<void> deleteProduct(String productId) async {
    await _col.doc(productId).delete();
  }

  Future<void> updateStock(String productId, int newQuantity) async {
    await _col.doc(productId).update({'stockQuantity': newQuantity});
  }
}
