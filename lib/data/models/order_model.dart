import 'package:cloud_firestore/cloud_firestore.dart';

// ─── OrderItem ─────────────────────────────────────────────────────────────
class OrderItem {
  final String productId;
  final String productName;
  final int quantity;
  final int unitPrice;   // paise
  final int totalPrice;  // paise
  final String category; // "tyre" | "casing"

  const OrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.category = 'tyre',
  });

  factory OrderItem.fromMap(Map<String, dynamic> d) {
    return OrderItem(
      productId:   d['productId']   as String?  ?? '',
      productName: d['productName'] as String?  ?? d['name'] as String? ?? '',
      quantity:    (d['quantity']   as num?)?.toInt() ?? 1,
      unitPrice:   (d['unitPrice']  as num?)?.toInt() ?? (d['price'] as num?)?.toInt() ?? 0,
      totalPrice:  (d['totalPrice'] as num?)?.toInt() ?? 0,
      category:    d['category']   as String?  ?? 'tyre',
    );
  }

  Map<String, dynamic> toMap() => {
    'productId':   productId,
    'productName': productName,
    'quantity':    quantity,
    'unitPrice':   unitPrice,
    'totalPrice':  totalPrice,
    'category':    category,
  };

  // Convenience display helpers — divide paise by 100
  double get unitPriceRupees  => unitPrice  / 100.0;
  double get totalPriceRupees => totalPrice / 100.0;
}

// ─── DeliveryAddress ───────────────────────────────────────────────────────
class DeliveryAddress {
  final String recipientName;
  final String phone;
  final String address;
  final String landmark;
  final String city;
  final String state;
  final String pincode;

  const DeliveryAddress({
    this.recipientName = '',
    this.phone         = '',
    this.address       = '',
    this.landmark      = '',
    this.city          = '',
    this.state         = '',
    this.pincode       = '',
  });

  factory DeliveryAddress.fromMap(Map<String, dynamic> d) => DeliveryAddress(
    recipientName: d['recipientName'] as String? ?? d['name']    as String? ?? '',
    phone:         d['phone']         as String? ?? '',
    address:       d['address']       as String? ?? '',
    landmark:      d['landmark']      as String? ?? '',
    city:          d['city']          as String? ?? '',
    state:         d['state']         as String? ?? '',
    pincode:       d['pincode']       as String? ?? '',
  );

  Map<String, dynamic> toMap() => {
    'recipientName': recipientName,
    'phone':         phone,
    'address':       address,
    'landmark':      landmark,
    'city':          city,
    'state':         state,
    'pincode':       pincode,
  };
}

// ─── OrderModel ────────────────────────────────────────────────────────────
class OrderModel {
  final String orderId;
  final String customerId;

  // Denormalized customer fields — always read these as fallback
  final String customerName;
  final String customerPhone;
  final String customerEmail;

  final List<OrderItem> items;

  final int totalAmount;       // paise
  final int gstAmount;         // paise
  final int deliveryCharges;   // paise
  final int finalAmount;       // paise

  final String paymentMethod;  // "razorpay" | "cod"
  final String paymentStatus;  // "pending" | "paid" | "collected" | "failed" | "refunded"
  final String? paymentId;
  final String? razorpayOrderId;

  final DeliveryAddress deliveryAddress;

  final String orderStatus;    // "pending_confirmation" | "confirmed" | "processing" | "shipped" | "delivered" | "cancelled"

  final DateTime createdAt;
  final DateTime? confirmedAt;
  final DateTime? shippedAt;
  final DateTime? deliveredAt;
  final DateTime? cancelledAt;
  final DateTime? collectedAt;

  final String? invoiceUrl;
  final String? adminNotes;
  final String? adminAssignedTo;
  final String? collectedBy;

  const OrderModel({
    required this.orderId,
    required this.customerId,
    this.customerName    = '',
    this.customerPhone   = '',
    this.customerEmail   = '',
    required this.items,
    this.totalAmount     = 0,
    this.gstAmount       = 0,
    this.deliveryCharges = 0,
    this.finalAmount     = 0,
    this.paymentMethod   = 'razorpay',
    this.paymentStatus   = 'pending',
    this.paymentId,
    this.razorpayOrderId,
    required this.deliveryAddress,
    this.orderStatus     = 'pending_confirmation',
    required this.createdAt,
    this.confirmedAt,
    this.shippedAt,
    this.deliveredAt,
    this.cancelledAt,
    this.collectedAt,
    this.invoiceUrl,
    this.adminNotes,
    this.adminAssignedTo,
    this.collectedBy,
  });

  // ─── Firestore → Model ───
  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final d = (doc.data() as Map<String, dynamic>?) ?? {};
    return OrderModel._fromMap(d, doc.id);
  }

  factory OrderModel.fromMap(Map<String, dynamic> d, String docId) {
    return OrderModel._fromMap(d, docId);
  }

  factory OrderModel._fromMap(Map<String, dynamic> d, String docId) {
    // items — handle both old and new shape
    final rawItems = d['items'] as List<dynamic>? ?? [];
    final items = rawItems.map((i) {
      if (i is Map<String, dynamic>) return OrderItem.fromMap(i);
      return const OrderItem(productId: '', productName: '', quantity: 1, unitPrice: 0, totalPrice: 0);
    }).toList();

    // amounts — support legacy double fields by converting to paise
    int _parsePaise(dynamic v) {
      if (v == null) return 0;
      final n = v as num;
      // If stored as rupees (double < 1000000 and has decimal), multiply by 100
      if (n is double && n < 1000000 && n != n.toInt().toDouble()) {
        return (n * 100).round();
      }
      return n.toInt();
    }

    final rawAddr = d['deliveryAddress'];
    final addr = rawAddr is Map<String, dynamic>
        ? DeliveryAddress.fromMap(rawAddr)
        : const DeliveryAddress();

    // Legacy `status` field → map to `orderStatus`
    final legacyStatus = d['status'] as String? ?? '';
    String _mapStatus(String s) {
      switch (s) {
        case 'pending':    return 'pending_confirmation';
        case 'confirmed':  return 'confirmed';
        case 'processing': return 'processing';
        case 'shipped':    return 'shipped';
        case 'delivered':  return 'delivered';
        case 'cancelled':  return 'cancelled';
        default:           return s.isNotEmpty ? s : 'pending_confirmation';
      }
    }

    return OrderModel(
      orderId:          docId,
      customerId:       d['customerId']   as String? ?? '',
      customerName:     d['customerName'] as String? ?? '',
      customerPhone:    d['customerPhone'] as String? ?? '',
      customerEmail:    d['customerEmail'] as String? ?? '',
      items:            items,
      totalAmount:      _parsePaise(d['totalAmount']),
      gstAmount:        _parsePaise(d['gstAmount']),
      deliveryCharges:  _parsePaise(d['deliveryCharges']),
      finalAmount:      _parsePaise(d['finalAmount'] ?? d['totalAmount']),
      paymentMethod:    d['paymentMethod']  as String? ?? 'razorpay',
      paymentStatus:    d['paymentStatus']  as String? ?? 'pending',
      paymentId:        d['paymentId']      as String?,
      razorpayOrderId:  d['razorpayOrderId'] as String?,
      deliveryAddress:  addr,
      orderStatus:      d['orderStatus'] as String? ?? _mapStatus(legacyStatus),
      createdAt:        _parseDate(d['createdAt']),
      confirmedAt:      d['confirmedAt']  != null ? _parseDate(d['confirmedAt'])  : null,
      shippedAt:        d['shippedAt']    != null ? _parseDate(d['shippedAt'])    : null,
      deliveredAt:      d['deliveredAt']  != null ? _parseDate(d['deliveredAt'])  : null,
      cancelledAt:      d['cancelledAt']  != null ? _parseDate(d['cancelledAt'])  : null,
      collectedAt:      d['collectedAt']  != null ? _parseDate(d['collectedAt'])  : null,
      invoiceUrl:       d['invoiceUrl']       as String?,
      adminNotes:       d['adminNotes']       as String?,
      adminAssignedTo:  d['adminAssignedTo']  as String?,
      collectedBy:      d['collectedBy']      as String?,
    );
  }

  // ─── Model → Firestore ───
  Map<String, dynamic> toMap() => {
    'orderId':         orderId,
    'customerId':      customerId,
    'customerName':    customerName,
    'customerPhone':   customerPhone,
    'customerEmail':   customerEmail,
    'items':           items.map((i) => i.toMap()).toList(),
    'totalAmount':     totalAmount,
    'gstAmount':       gstAmount,
    'deliveryCharges': deliveryCharges,
    'finalAmount':     finalAmount,
    'paymentMethod':   paymentMethod,
    'paymentStatus':   paymentStatus,
    'paymentId':       paymentId,
    'razorpayOrderId': razorpayOrderId,
    'deliveryAddress': deliveryAddress.toMap(),
    'orderStatus':     orderStatus,
    'createdAt':       FieldValue.serverTimestamp(),
    'confirmedAt':     confirmedAt  != null ? Timestamp.fromDate(confirmedAt!)  : null,
    'shippedAt':       shippedAt    != null ? Timestamp.fromDate(shippedAt!)    : null,
    'deliveredAt':     deliveredAt  != null ? Timestamp.fromDate(deliveredAt!)  : null,
    'cancelledAt':     cancelledAt  != null ? Timestamp.fromDate(cancelledAt!)  : null,
    'collectedAt':     collectedAt  != null ? Timestamp.fromDate(collectedAt!)  : null,
    'invoiceUrl':      invoiceUrl,
    'adminNotes':      adminNotes,
    'adminAssignedTo': adminAssignedTo,
    'collectedBy':     collectedBy,
  };

  // ─── Helpers ───
  double get finalAmountRupees => finalAmount / 100.0;
  double get totalAmountRupees => totalAmount / 100.0;
  bool   get isCod             => paymentMethod == 'cod';
  bool   get isCodPending      => isCod && paymentStatus == 'pending';
  bool   get isCodCollected    => isCod && paymentStatus == 'collected';

  static DateTime _parseDate(dynamic v) {
    if (v == null)          return DateTime.now();
    if (v is Timestamp)     return v.toDate();
    if (v is String)        return DateTime.tryParse(v) ?? DateTime.now();
    return DateTime.now();
  }
}
