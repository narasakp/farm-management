import 'dart:async';
import 'package:uni_links/uni_links.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../models/deep_link_click.dart';

/// Service สำหรับจัดการ Deep Links จาก Social Media
class DeepLinkService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  
  StreamSubscription? _linkSubscription;
  Uri? _initialLink;
  String? _currentSessionId;
  
  /// Initialize deep link listener
  Future<void> initialize() async {
    try {
      // สร้าง session ID ใหม่
      _currentSessionId = _generateSessionId();
      
      // รับ initial link (เมื่อเปิดแอปจาก link)
      _initialLink = await getInitialUri();
      if (_initialLink != null) {
        await handleDeepLink(_initialLink!);
      }
      
      // Listen for incoming links (เมื่อแอปเปิดอยู่แล้ว)
      _linkSubscription = uriLinkStream.listen(
        (Uri? uri) {
          if (uri != null) {
            handleDeepLink(uri);
          }
        },
        onError: (err) {
          print('❌ Error listening to deep links: $err');
        },
      );
      
      print('✅ Deep link service initialized');
    } catch (e) {
      print('❌ Error initializing deep link service: $e');
    }
  }
  
  /// Handle incoming deep link
  Future<Map<String, dynamic>?> handleDeepLink(Uri uri) async {
    try {
      print('🔗 Handling deep link: $uri');
      
      // Parse URL
      final params = _parseDeepLink(uri);
      if (params == null) {
        print('❌ Invalid deep link format');
        return null;
      }
      
      // Record click
      await _recordClick(
        listingId: params['listingId']!,
        source: params['source'] ?? 'direct',
        campaign: params['campaign'],
        referrer: params['referrer'],
      );
      
      // Track analytics
      await _analytics.logEvent(
        name: 'deep_link_open',
        parameters: {
          'listing_id': params['listingId'] ?? '',
          'source': params['source'] ?? 'direct',
          'campaign': params['campaign'] ?? 'none',
        },
      );
      
      return params;
    } catch (e) {
      print('❌ Error handling deep link: $e');
      return null;
    }
  }
  
  /// Parse deep link URL
  Map<String, String>? _parseDeepLink(Uri uri) {
    try {
      // รูปแบบที่รองรับ:
      // https://farm-app.com/market/{listingId}?source=facebook
      // https://farm-app.com/buy/{listingId}?source=tiktok
      // farm://market/{listingId}?source=x
      
      // ดึง listing ID จาก path
      final segments = uri.pathSegments;
      if (segments.isEmpty || segments.length < 2) {
        return null;
      }
      
      final action = segments[0]; // market, buy, trade
      final listingId = segments[1];
      
      // ดึง query parameters
      final params = uri.queryParameters;
      
      return {
        'action': action,
        'listingId': listingId,
        'source': params['source'] ?? 'direct',
        'campaign': params['campaign'] ?? '',
        'referrer': params['referrer'] ?? '',
        'utm_source': params['utm_source'] ?? '',
        'utm_campaign': params['utm_campaign'] ?? '',
        'utm_medium': params['utm_medium'] ?? '',
      };
    } catch (e) {
      print('❌ Error parsing deep link: $e');
      return null;
    }
  }
  
  /// Record click event
  Future<void> _recordClick({
    required String listingId,
    required String source,
    String? campaign,
    String? referrer,
    String? userId,
  }) async {
    try {
      final click = DeepLinkClick(
        id: '', // Firestore will generate
        listingId: listingId,
        source: source,
        campaign: campaign,
        referrer: referrer,
        userId: userId,
        sessionId: _currentSessionId,
        clickTime: DateTime.now(),
      );
      
      await _firestore.collection('deep_link_clicks').add(click.toFirestore());
      
      // อัปเดตจำนวน clicks ใน social_shares
      await _updateShareClicks(listingId, source);
      
      print('✅ Recorded deep link click: $listingId from $source');
    } catch (e) {
      print('❌ Error recording click: $e');
    }
  }
  
  /// อัปเดตจำนวน clicks ใน social_shares
  Future<void> _updateShareClicks(String listingId, String source) async {
    try {
      // หา social_share ที่ตรงกับ listingId และ platform
      final snapshot = await _firestore
          .collection('social_shares')
          .where('listingId', isEqualTo: listingId)
          .where('platform', isEqualTo: source)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        final docId = snapshot.docs.first.id;
        await _firestore.collection('social_shares').doc(docId).update({
          'clickCount': FieldValue.increment(1),
        });
      }
      
      // อัปเดต listing stats
      await _updateListingStats(listingId, source, isClick: true);
    } catch (e) {
      print('❌ Error updating share clicks: $e');
    }
  }
  
  /// อัปเดตสถิติของ listing
  Future<void> _updateListingStats(
    String listingId,
    String source, {
    bool isClick = false,
    bool isView = false,
    bool isPurchase = false,
  }) async {
    try {
      final docRef = _firestore.collection('market_listings').doc(listingId);
      
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) return;
        
        final data = snapshot.data() as Map<String, dynamic>;
        final socialStats = data['socialStats'] as Map<String, dynamic>? ?? {};
        final platformStats = socialStats['platformStats'] as Map<String, dynamic>? ?? {};
        final sourceStats = platformStats[source] as Map<String, dynamic>? ?? {
          'platform': source,
          'shares': 0,
          'views': 0,
          'clicks': 0,
          'purchases': 0,
        };
        
        // อัปเดตค่า
        if (isClick) {
          socialStats['totalClicks'] = (socialStats['totalClicks'] ?? 0) + 1;
          sourceStats['clicks'] = (sourceStats['clicks'] ?? 0) + 1;
        }
        if (isView) {
          socialStats['totalViews'] = (socialStats['totalViews'] ?? 0) + 1;
          sourceStats['views'] = (sourceStats['views'] ?? 0) + 1;
        }
        if (isPurchase) {
          socialStats['totalPurchases'] = (socialStats['totalPurchases'] ?? 0) + 1;
          sourceStats['purchases'] = (sourceStats['purchases'] ?? 0) + 1;
        }
        
        platformStats[source] = sourceStats;
        socialStats['platformStats'] = platformStats;
        
        transaction.update(docRef, {'socialStats': socialStats});
      });
    } catch (e) {
      print('❌ Error updating listing stats: $e');
    }
  }
  
  /// Mark conversion (เมื่อมีการซื้อสำเร็จ)
  Future<void> markConversion({
    required String listingId,
    required String orderId,
    String? sessionId,
  }) async {
    try {
      // หา deep link click ที่ตรงกับ session
      final query = sessionId != null
          ? _firestore
              .collection('deep_link_clicks')
              .where('listingId', isEqualTo: listingId)
              .where('sessionId', isEqualTo: sessionId)
              .where('converted', isEqualTo: false)
              .limit(1)
          : _firestore
              .collection('deep_link_clicks')
              .where('listingId', isEqualTo: listingId)
              .where('converted', isEqualTo: false)
              .orderBy('clickTime', descending: true)
              .limit(1);
      
      final snapshot = await query.get();
      
      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        await doc.reference.update({
          'converted': true,
          'orderId': orderId,
          'conversionTime': Timestamp.now(),
        });
        
        // อัปเดต social_shares
        final data = doc.data();
        await _updateShareConversion(listingId, data['source']);
        
        // อัปเดต listing stats
        await _updateListingStats(listingId, data['source'], isPurchase: true);
        
        // Track analytics
        await _analytics.logEvent(
          name: 'social_conversion',
          parameters: {
            'listing_id': listingId,
            'order_id': orderId,
            'source': data['source'],
          },
        );
        
        print('✅ Marked conversion: $orderId from ${data['source']}');
      }
    } catch (e) {
      print('❌ Error marking conversion: $e');
    }
  }
  
  /// อัปเดตจำนวน conversions ใน social_shares
  Future<void> _updateShareConversion(String listingId, String source) async {
    try {
      final snapshot = await _firestore
          .collection('social_shares')
          .where('listingId', isEqualTo: listingId)
          .where('platform', isEqualTo: source)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        final docId = snapshot.docs.first.id;
        await _firestore.collection('social_shares').doc(docId).update({
          'conversionCount': FieldValue.increment(1),
        });
      }
    } catch (e) {
      print('❌ Error updating share conversion: $e');
    }
  }
  
  /// Generate deep link URL
  Future<String> generateDeepLink({
    required String listingId,
    required String source,
    String? campaign,
  }) async {
    const baseUrl = 'https://farm-app.com'; // แก้ให้ตรงกับ domain จริง
    
    final params = <String, String>{
      'source': source,
      'utm_source': source,
      'utm_medium': 'social',
    };
    
    if (campaign != null && campaign.isNotEmpty) {
      params['campaign'] = campaign;
      params['utm_campaign'] = campaign;
    }
    
    final queryString = params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
    
    return '$baseUrl/market/$listingId?$queryString';
  }
  
  /// Generate session ID
  String _generateSessionId() {
    return 'session_${DateTime.now().millisecondsSinceEpoch}';
  }
  
  /// Get click statistics
  Future<Map<String, dynamic>> getClickStats({
    String? listingId,
    String? source,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = _firestore.collection('deep_link_clicks').where('clickTime', isGreaterThan: Timestamp.fromDate(startDate ?? DateTime.now().subtract(const Duration(days: 30))));
      
      if (listingId != null) {
        query = query.where('listingId', isEqualTo: listingId);
      }
      if (source != null) {
        query = query.where('source', isEqualTo: source);
      }
      if (endDate != null) {
        query = query.where('clickTime', isLessThan: Timestamp.fromDate(endDate));
      }
      
      final snapshot = await query.get();
      
      int totalClicks = snapshot.docs.length;
      int totalConversions = snapshot.docs.where((doc) => doc.data()['converted'] == true).length;
      double conversionRate = totalClicks > 0 ? (totalConversions / totalClicks) * 100 : 0;
      
      // Group by source
      final bySource = <String, int>{};
      for (final doc in snapshot.docs) {
        final source = doc.data()['source'] as String;
        bySource[source] = (bySource[source] ?? 0) + 1;
      }
      
      return {
        'totalClicks': totalClicks,
        'totalConversions': totalConversions,
        'conversionRate': conversionRate,
        'bySource': bySource,
      };
    } catch (e) {
      print('❌ Error getting click stats: $e');
      return {};
    }
  }
  
  /// Dispose resources
  void dispose() {
    _linkSubscription?.cancel();
  }
}
