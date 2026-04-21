import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String productId;
  final String name;
  final String brand;
  final String category;
  final String size;
  final int loadIndex;
  final String speedRating;
  final String treadPattern;
  final double price;
  final double? discountedPrice;
  final int stockQuantity;
  final List<String> imageUrls;
  final Map<String, String> specifications;
  final bool isActive;
  final bool isFeatured;
  final DateTime createdAt;

  // ─── Casing-specific fields ───
  final String? casingCondition;       // "Grade A" | "Grade B" | "Grade C"
  final String? casingSource;          // "In-House" | "Customer Return" | "Purchased"
  final int? maxRetreadCycles;         // 1 | 2 | 3
  final List<String> compatibleTyreSizes;

  ProductModel({
    required this.productId,
    required this.name,
    this.brand = 'MRF',
    required this.category,
    required this.size,
    required this.loadIndex,
    required this.speedRating,
    required this.treadPattern,
    required this.price,
    this.discountedPrice,
    required this.stockQuantity,
    required this.imageUrls,
    required this.specifications,
    this.isActive = true,
    this.isFeatured = false,
    required this.createdAt,
    this.casingCondition,
    this.casingSource,
    this.maxRetreadCycles,
    this.compatibleTyreSizes = const [],
  });

  factory ProductModel.fromMap(Map<String, dynamic> data, String documentId) {
    return ProductModel(
      productId:    documentId,
      name:         data['name'] ?? '',
      brand:        data['brand'] ?? 'MRF',
      category:     data['category'] ?? 'car',
      size:         data['size'] ?? '',
      loadIndex:    data['loadIndex'] ?? 0,
      speedRating:  data['speedRating'] ?? '',
      treadPattern: data['treadPattern'] ?? '',
      price:        (data['price'] ?? 0.0).toDouble(),
      discountedPrice: data['discountedPrice'] != null ? (data['discountedPrice'] as num).toDouble() : null,
      stockQuantity: data['stockQuantity'] ?? 0,
      imageUrls:     List<String>.from(data['imageUrls'] ?? []),
      specifications: Map<String, String>.from(data['specifications'] ?? {}),
      isActive:      data['isActive'] ?? true,
      isFeatured:    data['isFeatured'] ?? false,
      createdAt:     _parseDate(data['createdAt']),
      casingCondition: data['casingCondition'] as String?,
      casingSource:    data['casingSource'] as String?,
      maxRetreadCycles: data['maxRetreadCycles'] as int?,
      compatibleTyreSizes: List<String>.from(data['compatibleTyreSizes'] ?? []),
    );
  }

  Map<String, dynamic> toMap() => {
    'productId':    productId,
    'name':         name,
    'brand':        brand,
    'category':     category,
    'size':         size,
    'loadIndex':    loadIndex,
    'speedRating':  speedRating,
    'treadPattern': treadPattern,
    'price':        price,
    'discountedPrice': discountedPrice,
    'stockQuantity': stockQuantity,
    'imageUrls':    imageUrls,
    'specifications': specifications,
    'isActive':     isActive,
    'isFeatured':   isFeatured,
    'createdAt':    Timestamp.fromDate(createdAt),
    'casingCondition': casingCondition,
    'casingSource':    casingSource,
    'maxRetreadCycles': maxRetreadCycles,
    'compatibleTyreSizes': compatibleTyreSizes,
  };

  static DateTime _parseDate(dynamic v) {
    if (v == null) return DateTime.now();
    if (v is Timestamp) return v.toDate();
    if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
    return DateTime.now();
  }
}
