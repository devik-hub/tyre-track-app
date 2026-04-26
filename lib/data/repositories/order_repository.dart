import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/firebase_constants.dart';
import '../models/order_model.dart';
import '../models/user_model.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) => OrderRepository());

class OrderRepository{
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _orders => _db.collection(FirebaseConstants.ordersCollection);
  CollectionReference get _products => _db.collection(FirebaseConstants.productsCollection);

  /// Admin: All orders ordered by createdAt in descending order
  Stream<List<OrderModel>> streamAllOrders(){
    return _orders
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) {
          try{
            return snap.docs
                .map((doc) => OrderModel.fromFirestore(doc))
                .toList();
          } catch(e,s){
            print('streamAllOrders map error: $e\n$s');
            return <OrderModel>[];
          }
        })
        .handleError((e,s){
          print('streamAllOrders stream error: $e\n$s');
          return <OrderModel>[];
        });
  }

  /// Admin: COD orders where cash has not yet been collected
  Stream<List<OrderModel>> streamCodPendingOrders(){
    return _orders
        .where('paymentMethod', isEqualTo: 'cod')
        .where('paymentStatus', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) {
          try{
            return snap.docs.map((d) => OrderModel.fromFirestore(d)).toList();
          } catch(e){
            print('streamCodPendingOrders map error: $e');
            return <OrderModel>[];
          }
        })
        .handleError((e){
          print('streamCodPendingOrders stream error: $e');
          return <OrderModel>[];
        });
  }

  /// Admin: Filter orders by orderStatus
  Stream<List<OrderModel>> streamOrdersByStatus(String status){
    return _orders
        .where('orderStatus', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) {
          try{
            return snap.docs.map((d) => OrderModel.fromFirestore(d)).toList();
          } catch(e){
            print('streamOrdersByStatus map error: $e');
            return <OrderModel>[];
          }
        })
        .handleError((e){
          print('streamOrdersByStatus stream error: $e');
          return <OrderModel>[];
        });
  }

  /// Single order by ID — real-time
  Stream<OrderModel?> streamOrderById(String orderId) {
    return _orders
        .doc(orderId)
        .snapshots()
        .map((doc) {
          if(!doc.exists){
            print('⚠streamOrderById: order $orderId not found');
            return null;
          }
          try{
            return OrderModel.fromFirestore(doc);
          } catch(e){
            print('streamOrderById parse error: $e');
            return null;
          }
        })
        .handleError((e){
          print('streamOrderById stream error: $e');
          return null;
        });
  }

  /// Customer: My orders — real-time
  Stream<List<OrderModel>> streamUserOrders(String customerId){
    return _orders
        .where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) {
          try{
            return snap.docs.map((d) => OrderModel.fromFirestore(d)).toList();
          } catch(e){
            print('streamUserOrders map error: $e');
            return <OrderModel>[];
          }
        })
        .handleError((e){
          print('streamUserOrders stream error: $e');
          return <OrderModel>[];
        });
  }

  /// Creates an order and decreases stock for every item.
  /// Sends notice if any product has insufficient stock.
  /// Uses Firestore transaction — all-or-nothing.
  Future<String> checkoutAtomicWithStockReduction({
    required List<OrderItem> items,
    required UserModel customer,
    required String paymentMethod,    // Razorpay or COD
    required String paymentStatus,    // Pending or Paid
    String? paymentId,
    String? razorpayOrderId,
    DeliveryAddress? deliveryAddress,
    int gstAmount = 0,
    int deliveryCharges = 0,
  }) async{
    final orderId = const Uuid().v4();
    print('Starting atomic checkout for order $orderId (${items.length} items)');

    try{
      await _db.runTransaction((txn) async{
        // Step 1: Read all product docs inside transaction
        final productRefs = items
            .map((item) => _products.doc(item.productId))
            .toList();

        final productSnaps = await Future.wait(
          productRefs.map((ref) => txn.get(ref)),
        );

        // Step 2: Validate stock for every item
        for(int i=0;i<items.length;i++){
          final snap = productSnaps[i];
          final item = items[i];

          if(!snap.exists){
            throw Exception(
              'Product "${item.productName}" (${item.productId}) no longer exists.',
            );
          }

          final data = snap.data() as Map<String, dynamic>;
          final currentStock = (data['stockQuantity'] as num?)?.toInt() ?? 0;

          if(currentStock < item.quantity){
            final name = data['name'] as String? ?? item.productName;
            throw Exception(
              'Insufficient stock for "$name". '
              'Available: $currentStock, Requested: ${item.quantity}',
            );
          }
          print('Stock OK for ${item.productName}: $currentStock available, ${item.quantity} requested');
        }

        // Step 3: Decrement stock for every item
        for(int i=0;i<items.length;i++){
          final snap = productSnaps[i];
          final item = items[i];
          final data = snap.data() as Map<String, dynamic>;
          final currentStock = (data['stockQuantity'] as num?)?.toInt() ?? 0;
          final newStock = currentStock - item.quantity;

          txn.update(productRefs[i], {
            'stockQuantity': newStock,
            'updatedAt': FieldValue.serverTimestamp(),
          });
          print('Decremented stock for ${item.productName}: $currentStock → $newStock');
        }

        // Step 4: Calculate totals
        final totalAmount = items.fold<int>(0, (sum,i) => sum + i.totalPrice);
        final finalAmount = totalAmount + gstAmount + deliveryCharges;

        // Step 5: Write order document
        final orderDoc = _orders.doc(orderId);
        txn.set(orderDoc, {
          'orderId':         orderId,
          'customerId':      customer.uid,
          'customerName':    customer.name,
          'customerPhone':   customer.phone,
          'customerEmail':   customer.email,
          'items':           items.map((i) => i.toMap()).toList(),
          'totalAmount':     totalAmount,
          'gstAmount':       gstAmount,
          'deliveryCharges': deliveryCharges,
          'finalAmount':     finalAmount,
          'paymentMethod':   paymentMethod,
          'paymentStatus':   paymentStatus,
          'paymentId':       paymentId,
          'razorpayOrderId': razorpayOrderId,
          'deliveryAddress': (deliveryAddress ?? const DeliveryAddress()).toMap(),
          'orderStatus':     'pending_confirmation',
          'createdAt':       FieldValue.serverTimestamp(),
          'confirmedAt':     null,
          'shippedAt':       null,
          'deliveredAt':     null,
          'cancelledAt':     null,
          'collectedAt':     null,
          'invoiceUrl':      null,
          'adminNotes':      null,
          'adminAssignedTo': null,
          'collectedBy':     null,
        });
        print('Order document written: $orderId');
      });

      print('Atomic checkout complete for order $orderId');
      return orderId;
    } on FirebaseException catch(e,s){
      print('Firestore transaction failed: ${e.code} — ${e.message}\n$s');
      throw Exception('Order failed: ${e.message ?? e.code}');
    } catch(e){
      print('Checkout error: $e');
      rethrow;
    }
  }

  /// Admin marks COD cash as physically collected → delivered
  Future<void> markCodCashCollected(String orderId, {String? adminUid}) async{
    try{
      await _orders.doc(orderId).update({
        'paymentStatus': 'collected',
        'orderStatus':   'delivered',
        'deliveredAt':   FieldValue.serverTimestamp(),
        'collectedAt':   FieldValue.serverTimestamp(),
        if(adminUid!=null) 'collectedBy': adminUid,
      });
      print('markCodCashCollected: order $orderId marked collected by $adminUid');
    } on FirebaseException catch(e){
      print('markCodCashCollected error: ${e.code} — ${e.message}');
      throw Exception('Failed to mark cash collected: ${e.message}');
    }
  }

  /// Admin updates order status + timestamps the transition
  Future<void> updateOrderStatus(String orderId, String newStatus) async{
    final Map<String, dynamic> updates = {
      'orderStatus': newStatus,
    };

    switch(newStatus){
      case 'confirmed':
        updates['confirmedAt'] = FieldValue.serverTimestamp();
        break;
      case 'shipped':
        updates['shippedAt'] = FieldValue.serverTimestamp();
        break;
      case 'delivered':
        updates['deliveredAt'] = FieldValue.serverTimestamp();
        break;
      case 'cancelled':
        updates['cancelledAt'] = FieldValue.serverTimestamp();
        break;
    }

    try{
      await _orders.doc(orderId).update(updates);
      print('updateOrderStatus: order $orderId → $newStatus');
    } on FirebaseException catch (e) {
      print('updateOrderStatus error: ${e.code} — ${e.message}');
      throw Exception('Failed to update order status: ${e.message}');
    }
  }

  /// Legacy create — kept for backwards compatibility
  Future<void> createOrder(OrderModel order) async {
    await _orders.doc(order.orderId).set(order.toMap());
    print('createOrder: ${order.orderId}');
  }

  /// Update payment status
  Future<void> updatePaymentStatus(
    String orderId,
    String paymentStatus, {
    String? paymentId,
  }) async{
    final updates = <String, dynamic>{'paymentStatus': paymentStatus};
    if (paymentId != null) updates['paymentId'] = paymentId;
    await _orders.doc(orderId).update(updates);
    print('updatePaymentStatus: order $orderId → $paymentStatus');
  }
}
