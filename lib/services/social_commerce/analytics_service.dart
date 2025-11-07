import 'package:cloud_firestore/cloud_firestore.dart';

/// Service สำหรับ Analytics
class AnalyticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  /// ดึงสถิติภาพรวม
  Future<Map<String, dynamic>> getOverallStats({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final start = startDate ?? DateTime.now().subtract(const Duration(days: 30));
      final end = endDate ?? DateTime.now();
      
      // ดึงข้อมูลการแชร์
      final sharesSnapshot = await _firestore
          .collection('social_shares')
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .get();
      
      // ดึงข้อมูล deep link clicks
      final clicksSnapshot = await _firestore
          .collection('deep_link_clicks')
          .where('clickTime', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('clickTime', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .get();
      
      // ดึงข้อมูลคำสั่งซื้อ
      final ordersSnapshot = await _firestore
          .collection('orders')
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .get();
      
      // คำนวณสถิติ
      int totalShares = sharesSnapshot.docs.length;
      int totalViews = 0;
      int totalClicks = clicksSnapshot.docs.length;
      int totalPurchases = 0;
      double totalRevenue = 0;
      
      // รวม views จาก shares
      for (final doc in sharesSnapshot.docs) {
        final data = doc.data();
        totalViews += (data['viewCount'] as num?)?.toInt() ?? 0;
      }
      
      // นับ purchases และ revenue
      for (final doc in ordersSnapshot.docs) {
        final data = doc.data();
        if (data['status'] == 'completed') {
          totalPurchases++;
          totalRevenue += (data['totalAmount'] as num?)?.toDouble() ?? 0;
        }
      }
      
      // คำนวณ conversion rate
      final conversionRate = totalClicks > 0 
          ? (totalPurchases / totalClicks) * 100 
          : 0.0;
      
      // สถิติแยกตาม platform
      final platformStats = await _getPlatformStats(start, end);
      
      // Top performers
      final topPerformers = await _getTopPerformers(start, end);
      
      // Revenue by source
      final revenueBySource = await _getRevenueBySource(start, end);
      
      return {
        'totalShares': totalShares,
        'totalViews': totalViews,
        'totalClicks': totalClicks,
        'totalPurchases': totalPurchases,
        'totalRevenue': totalRevenue,
        'conversionRate': conversionRate,
        'averageOrderValue': totalPurchases > 0 ? totalRevenue / totalPurchases : 0,
        'platformStats': platformStats,
        'topPerformers': topPerformers,
        'revenueBySource': revenueBySource,
      };
    } catch (e) {
      print('❌ Error getting overall stats: $e');
      return {};
    }
  }
  
  /// ดึงสถิติแยกตาม platform
  Future<Map<String, dynamic>> _getPlatformStats(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final sharesSnapshot = await _firestore
          .collection('social_shares')
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();
      
      final clicksSnapshot = await _firestore
          .collection('deep_link_clicks')
          .where('clickTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('clickTime', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();
      
      final stats = <String, Map<String, dynamic>>{};
      
      // นับ shares แยกตาม platform
      for (final doc in sharesSnapshot.docs) {
        final data = doc.data();
        final platform = data['platform'] as String? ?? 'unknown';
        
        if (!stats.containsKey(platform)) {
          stats[platform] = {
            'shares': 0,
            'views': 0,
            'clicks': 0,
            'purchases': 0,
          };
        }
        
        stats[platform]!['shares'] = (stats[platform]!['shares'] as int) + 1;
        stats[platform]!['views'] = (stats[platform]!['views'] as int) + 
            ((data['viewCount'] as num?)?.toInt() ?? 0);
      }
      
      // นับ clicks แยกตาม source
      for (final doc in clicksSnapshot.docs) {
        final data = doc.data();
        final source = data['source'] as String? ?? 'unknown';
        
        if (!stats.containsKey(source)) {
          stats[source] = {
            'shares': 0,
            'views': 0,
            'clicks': 0,
            'purchases': 0,
          };
        }
        
        stats[source]!['clicks'] = (stats[source]!['clicks'] as int) + 1;
        
        if (data['converted'] == true) {
          stats[source]!['purchases'] = (stats[source]!['purchases'] as int) + 1;
        }
      }
      
      // คำนวณ conversion rate
      for (final entry in stats.entries) {
        final clicks = entry.value['clicks'] as int;
        final purchases = entry.value['purchases'] as int;
        entry.value['conversionRate'] = clicks > 0 
            ? (purchases / clicks) * 100 
            : 0.0;
      }
      
      return stats;
    } catch (e) {
      print('❌ Error getting platform stats: $e');
      return {};
    }
  }
  
  /// ดึง Top Performers
  Future<List<Map<String, dynamic>>> _getTopPerformers(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      // ดึงข้อมูลคำสั่งซื้อที่สำเร็จ
      final ordersSnapshot = await _firestore
          .collection('orders')
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .where('status', isEqualTo: 'completed')
          .get();
      
      // รวมยอดขายแยกตาม listingId
      final listingStats = <String, Map<String, dynamic>>{};
      
      for (final doc in ordersSnapshot.docs) {
        final data = doc.data();
        final listingId = data['listingId'] as String?;
        final amount = (data['totalAmount'] as num?)?.toDouble() ?? 0;
        
        if (listingId != null) {
          if (!listingStats.containsKey(listingId)) {
            listingStats[listingId] = {
              'listingId': listingId,
              'purchases': 0,
              'revenue': 0.0,
              'shares': 0,
            };
          }
          
          listingStats[listingId]!['purchases'] = 
              (listingStats[listingId]!['purchases'] as int) + 1;
          listingStats[listingId]!['revenue'] = 
              (listingStats[listingId]!['revenue'] as double) + amount;
        }
      }
      
      // เรียงลำดับตาม purchases
      final sorted = listingStats.values.toList()
        ..sort((a, b) => (b['purchases'] as int).compareTo(a['purchases'] as int));
      
      // ดึงข้อมูล listing detail (เฉพาะ top 5)
      final topPerformers = <Map<String, dynamic>>[];
      
      for (int i = 0; i < sorted.length && i < 5; i++) {
        final item = sorted[i];
        final listingId = item['listingId'] as String;
        
        try {
          final listingDoc = await _firestore
              .collection('market_listings')
              .doc(listingId)
              .get();
          
          if (listingDoc.exists) {
            final listingData = listingDoc.data()!;
            topPerformers.add({
              'listingId': listingId,
              'title': listingData['shareTitle'] ?? 'ไม่ระบุ',
              'shares': item['shares'],
              'purchases': item['purchases'],
              'revenue': item['revenue'],
            });
          }
        } catch (e) {
          print('Error fetching listing $listingId: $e');
        }
      }
      
      return topPerformers;
    } catch (e) {
      print('❌ Error getting top performers: $e');
      return [];
    }
  }
  
  /// ดึงรายได้แยกตาม source
  Future<Map<String, double>> _getRevenueBySource(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final ordersSnapshot = await _firestore
          .collection('orders')
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .where('status', isEqualTo: 'completed')
          .get();
      
      final revenueBySource = <String, double>{};
      
      for (final doc in ordersSnapshot.docs) {
        final data = doc.data();
        final source = data['source'] as String? ?? 'direct';
        final amount = (data['totalAmount'] as num?)?.toDouble() ?? 0;
        
        revenueBySource[source] = (revenueBySource[source] ?? 0) + amount;
      }
      
      return revenueBySource;
    } catch (e) {
      print('❌ Error getting revenue by source: $e');
      return {};
    }
  }
  
  /// ดึงข้อมูลแบบ real-time
  Stream<Map<String, dynamic>> getRealtimeStats() {
    return Stream.periodic(const Duration(seconds: 30), (_) async {
      return await getOverallStats(
        startDate: DateTime.now().subtract(const Duration(days: 30)),
      );
    }).asyncMap((future) => future);
  }
  
  /// Export รายงาน CSV
  Future<String> exportReport({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final stats = await getOverallStats(
        startDate: startDate,
        endDate: endDate,
      );
      
      // สร้าง CSV content
      final buffer = StringBuffer();
      
      // Header
      buffer.writeln('Social Commerce Analytics Report');
      buffer.writeln('Period: ${startDate?.toString() ?? 'N/A'} to ${endDate?.toString() ?? 'N/A'}');
      buffer.writeln('');
      
      // Overview
      buffer.writeln('Overview');
      buffer.writeln('Total Shares,${stats['totalShares']}');
      buffer.writeln('Total Views,${stats['totalViews']}');
      buffer.writeln('Total Clicks,${stats['totalClicks']}');
      buffer.writeln('Total Purchases,${stats['totalPurchases']}');
      buffer.writeln('Total Revenue,${stats['totalRevenue']}');
      buffer.writeln('Conversion Rate,${stats['conversionRate']}%');
      buffer.writeln('');
      
      // Platform Stats
      buffer.writeln('Platform Performance');
      buffer.writeln('Platform,Shares,Views,Clicks,Purchases,Conversion Rate');
      
      final platformStats = stats['platformStats'] as Map<String, dynamic>? ?? {};
      for (final entry in platformStats.entries) {
        final platform = entry.key;
        final data = entry.value as Map<String, dynamic>;
        buffer.writeln('$platform,${data['shares']},${data['views']},${data['clicks']},${data['purchases']},${data['conversionRate']}%');
      }
      
      return buffer.toString();
    } catch (e) {
      print('❌ Error exporting report: $e');
      return '';
    }
  }
}
