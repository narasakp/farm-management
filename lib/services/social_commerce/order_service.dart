import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'deep_link_service.dart';

/// Service สำหรับจัดการคำสั่งซื้อ
class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  final DeepLinkService _deepLinkService = DeepLinkService();
  
  /// สร้างคำสั่งซื้อใหม่
  Future<String> createOrder({
    required String listingId,
    required String buyerName,
    required String buyerPhone,
    String? buyerAddress,
    required String paymentMethod,
    required double totalAmount,
    String? source,
    String? campaign,
    String? userId,
  }) async {
    try {
      final orderId = 'ORD${DateTime.now().millisecondsSinceEpoch}';
      
      final orderData = {
        'orderId': orderId,
        'listingId': listingId,
        'buyerName': buyerName,
        'buyerPhone': buyerPhone,
        'buyerAddress': buyerAddress,
        'paymentMethod': paymentMethod,
        'totalAmount': totalAmount,
        'status': 'pending', // pending, confirmed, shipped, completed, cancelled
        'source': source ?? 'direct',
        'campaign': campaign,
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      // Save to Firestore
      await _firestore.collection('orders').doc(orderId).set(orderData);
      
      // Mark conversion in deep link service
      if (source != null && source != 'direct') {
        await _deepLinkService.markConversion(
          listingId: listingId,
          orderId: orderId,
        );
      }
      
      // Track analytics
      await _analytics.logEvent(
        name: 'purchase',
        parameters: {
          'transaction_id': orderId,
          'value': totalAmount,
          'currency': 'THB',
          'source': source ?? 'direct',
          'payment_method': paymentMethod,
        },
      );
      
      // Send notification (implement later)
      await _sendOrderNotification(orderId, buyerName, buyerPhone);
      
      print('✅ Order created: $orderId');
      return orderId;
    } catch (e) {
      print('❌ Error creating order: $e');
      rethrow;
    }
  }
  
  /// อัปเดตสถานะคำสั่งซื้อ
  Future<void> updateOrderStatus({
    required String orderId,
    required String status,
    String? note,
  }) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
        if (note != null) 'note': note,
      });
      
      // Track status change
      await _analytics.logEvent(
        name: 'order_status_changed',
        parameters: {
          'order_id': orderId,
          'status': status,
        },
      );
      
      print('✅ Order $orderId updated to $status');
    } catch (e) {
      print('❌ Error updating order: $e');
      rethrow;
    }
  }
  
  /// ดึงข้อมูลคำสั่งซื้อ
  Future<Map<String, dynamic>?> getOrder(String orderId) async {
    try {
      final doc = await _firestore.collection('orders').doc(orderId).get();
      
      if (!doc.exists) {
        return null;
      }
      
      return doc.data();
    } catch (e) {
      print('❌ Error getting order: $e');
      return null;
    }
  }
  
  /// ดึงคำสั่งซื้อของผู้ใช้
  Stream<List<Map<String, dynamic>>> getUserOrders(String userId) {
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList());
  }
  
  /// ดึงคำสั่งซื้อทั้งหมด (สำหรับ admin)
  Stream<List<Map<String, dynamic>>> getAllOrders({
    String? status,
    int limit = 50,
  }) {
    var query = _firestore.collection('orders').orderBy('createdAt', descending: true);
    
    if (status != null) {
      query = query.where('status', isEqualTo: status) as Query<Map<String, dynamic>>;
    }
    
    return query.limit(limit).snapshots().map((snapshot) => snapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data()})
        .toList());
  }
  
  /// ยกเลิกคำสั่งซื้อ
  Future<void> cancelOrder({
    required String orderId,
    required String reason,
  }) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': 'cancelled',
        'cancelReason': reason,
        'cancelledAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      await _analytics.logEvent(
        name: 'order_cancelled',
        parameters: {
          'order_id': orderId,
          'reason': reason,
        },
      );
      
      print('✅ Order $orderId cancelled');
    } catch (e) {
      print('❌ Error cancelling order: $e');
      rethrow;
    }
  }
  
  /// คำนวณสถิติคำสั่งซื้อ
  Future<Map<String, dynamic>> getOrderStats({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = _firestore.collection('orders').where(
        'createdAt',
        isGreaterThanOrEqualTo: Timestamp.fromDate(
          startDate ?? DateTime.now().subtract(const Duration(days: 30)),
        ),
      );
      
      if (endDate != null) {
        query = query.where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }
      
      final snapshot = await query.get();
      
      int totalOrders = snapshot.docs.length;
      int pendingOrders = 0;
      int completedOrders = 0;
      int cancelledOrders = 0;
      double totalRevenue = 0;
      
      final sourceStats = <String, int>{};
      final paymentMethodStats = <String, int>{};
      
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final status = data['status'] as String;
        final source = data['source'] as String? ?? 'direct';
        final paymentMethod = data['paymentMethod'] as String? ?? 'unknown';
        final amount = (data['totalAmount'] as num?)?.toDouble() ?? 0;
        
        // Count by status
        if (status == 'pending') pendingOrders++;
        if (status == 'completed') {
          completedOrders++;
          totalRevenue += amount;
        }
        if (status == 'cancelled') cancelledOrders++;
        
        // Count by source
        sourceStats[source] = (sourceStats[source] ?? 0) + 1;
        
        // Count by payment method
        paymentMethodStats[paymentMethod] = (paymentMethodStats[paymentMethod] ?? 0) + 1;
      }
      
      return {
        'totalOrders': totalOrders,
        'pendingOrders': pendingOrders,
        'completedOrders': completedOrders,
        'cancelledOrders': cancelledOrders,
        'totalRevenue': totalRevenue,
        'averageOrderValue': totalOrders > 0 ? totalRevenue / totalOrders : 0,
        'completionRate': totalOrders > 0 ? (completedOrders / totalOrders) * 100 : 0,
        'sourceStats': sourceStats,
        'paymentMethodStats': paymentMethodStats,
      };
    } catch (e) {
      print('❌ Error getting order stats: $e');
      return {};
    }
  }
  
  /// ส่งการแจ้งเตือนคำสั่งซื้อ
  Future<void> _sendOrderNotification(
    String orderId,
    String buyerName,
    String buyerPhone,
  ) async {
    try {
      // TODO: Implement notification system
      // Options:
      // 1. Send SMS to buyer
      // 2. Send email to admin
      // 3. Push notification to seller
      // 4. LINE notification
      
      print('📧 Order notification sent for $orderId');
    } catch (e) {
      print('❌ Error sending notification: $e');
    }
  }
  
  /// ดึงคำสั่งซื้อจาก Social Commerce
  Future<List<Map<String, dynamic>>> getSocialCommerceOrders({
    String? source,
    DateTime? startDate,
  }) async {
    try {
      var query = _firestore
          .collection('orders')
          .where('source', isNotEqualTo: 'direct')
          .orderBy('source')
          .orderBy('createdAt', descending: true);
      
      if (source != null) {
        query = _firestore
            .collection('orders')
            .where('source', isEqualTo: source)
            .orderBy('createdAt', descending: true);
      }
      
      if (startDate != null) {
        query = query.where(
          'createdAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
        ) as Query<Map<String, dynamic>>;
      }
      
      final snapshot = await query.limit(100).get();
      
      return snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();
    } catch (e) {
      print('❌ Error getting social commerce orders: $e');
      return [];
    }
  }
  
  /// สร้าง Guest Order (ไม่ต้อง login)
  Future<String> createGuestOrder({
    required String listingId,
    required String buyerName,
    required String buyerPhone,
    String? buyerAddress,
    required String paymentMethod,
    required double totalAmount,
    String? source,
    String? campaign,
  }) async {
    return await createOrder(
      listingId: listingId,
      buyerName: buyerName,
      buyerPhone: buyerPhone,
      buyerAddress: buyerAddress,
      paymentMethod: paymentMethod,
      totalAmount: totalAmount,
      source: source,
      campaign: campaign,
      userId: null, // Guest order
    );
  }
  
  /// ตรวจสอบสถานะการชำระเงิน
  Future<bool> verifyPayment(String orderId) async {
    try {
      final order = await getOrder(orderId);
      
      if (order == null) {
        return false;
      }
      
      // TODO: Implement actual payment verification
      // This is a placeholder
      
      return true;
    } catch (e) {
      print('❌ Error verifying payment: $e');
      return false;
    }
  }
  
  /// Generate receipt/invoice
  Future<Map<String, dynamic>> generateReceipt(String orderId) async {
    try {
      final order = await getOrder(orderId);
      
      if (order == null) {
        throw Exception('Order not found');
      }
      
      return {
        'orderId': orderId,
        'date': order['createdAt'],
        'buyerName': order['buyerName'],
        'buyerPhone': order['buyerPhone'],
        'totalAmount': order['totalAmount'],
        'paymentMethod': order['paymentMethod'],
        'status': order['status'],
      };
    } catch (e) {
      print('❌ Error generating receipt: $e');
      rethrow;
    }
  }
}
