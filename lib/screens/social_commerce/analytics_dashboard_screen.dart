import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/social_commerce/analytics_service.dart';
import '../../widgets/app_bars/standard_app_bar.dart';

/// หน้า Analytics Dashboard สำหรับ Social Commerce
class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({Key? key}) : super(key: key);
  
  @override
  State<AnalyticsDashboardScreen> createState() => _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen> {
  final AnalyticsService _analyticsService = AnalyticsService();
  
  String _selectedPeriod = '30days';
  bool _isLoading = true;
  Map<String, dynamic> _stats = {};
  
  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }
  
  Future<void> _loadAnalytics() async {
    setState(() => _isLoading = true);
    
    try {
      final startDate = _getStartDate();
      final stats = await _analyticsService.getOverallStats(
        startDate: startDate,
        endDate: DateTime.now(),
      );
      
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading analytics: $e');
      setState(() => _isLoading = false);
    }
  }
  
  DateTime _getStartDate() {
    switch (_selectedPeriod) {
      case '7days':
        return DateTime.now().subtract(const Duration(days: 7));
      case '30days':
        return DateTime.now().subtract(const Duration(days: 30));
      case '90days':
        return DateTime.now().subtract(const Duration(days: 90));
      default:
        return DateTime.now().subtract(const Duration(days: 30));
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StandardAppBar(
        type: AppBarType.main,
        title: 'Social Commerce Analytics',
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAnalytics,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Period selector
                    _buildPeriodSelector(),
                    
                    const SizedBox(height: 24),
                    
                    // Overview cards
                    _buildOverviewCards(),
                    
                    const SizedBox(height: 24),
                    
                    // Quick Buy Links Performance
                    _buildQuickBuyPerformance(),
                    
                    const SizedBox(height: 24),
                    
                    // Platform performance
                    _buildPlatformPerformance(),
                    
                    const SizedBox(height: 24),
                    
                    // Conversion funnel
                    _buildConversionFunnel(),
                    
                    const SizedBox(height: 24),
                    
                    // Top performing content
                    _buildTopPerformers(),
                    
                    const SizedBox(height: 24),
                    
                    // Revenue breakdown
                    _buildRevenueBreakdown(),
                  ],
                ),
              ),
            ),
    );
  }
  
  Widget _buildPeriodSelector() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Color(0xFF228B22)),
            const SizedBox(width: 12),
            const Text(
              'ช่วงเวลา:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: '7days', label: Text('7 วัน')),
                  ButtonSegment(value: '30days', label: Text('30 วัน')),
                  ButtonSegment(value: '90days', label: Text('90 วัน')),
                ],
                selected: {_selectedPeriod},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _selectedPeriod = newSelection.first;
                  });
                  _loadAnalytics();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildOverviewCards() {
    final totalShares = _stats['totalShares'] ?? 0;
    final totalViews = _stats['totalViews'] ?? 0;
    final totalClicks = _stats['totalClicks'] ?? 0;
    final totalPurchases = _stats['totalPurchases'] ?? 0;
    final totalRevenue = _stats['totalRevenue'] ?? 0.0;
    final conversionRate = _stats['conversionRate'] ?? 0.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ภาพรวม',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                icon: Icons.share,
                label: 'การแชร์',
                value: '$totalShares',
                color: const Color(0xFF1877F2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                icon: Icons.visibility,
                label: 'การดู',
                value: _formatNumber(totalViews),
                color: const Color(0xFFFF6B35),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                icon: Icons.touch_app,
                label: 'คลิก',
                value: _formatNumber(totalClicks),
                color: const Color(0xFF9C27B0),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                icon: Icons.shopping_cart,
                label: 'ซื้อสำเร็จ',
                value: '$totalPurchases',
                color: const Color(0xFF228B22),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                icon: Icons.attach_money,
                label: 'ยอดขาย',
                value: _formatCurrency(totalRevenue),
                color: const Color(0xFFFFD700),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                icon: Icons.trending_up,
                label: 'Conversion',
                value: '${conversionRate.toStringAsFixed(1)}%',
                color: const Color(0xFF00BCD4),
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildMetricCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildQuickBuyPerformance() {
    // Mock data - TODO: Replace with real data from analytics service
    final quickBuyLinks = [
      {
        'id': '0Giydsk4bk6ApQbMT6Qq',
        'productName': 'โคเนื้อดำ 18 เดือน',
        'views': 247,
        'clicks': 89,
        'conversions': 12,
        'revenue': 180000.0,
        'conversionRate': 13.5,
      },
      {
        'id': 'qkA28dIUguHf0DFf79Il',
        'productName': 'สุกรพันธุ์ดูรอก 6 เดือน',
        'views': 189,
        'clicks': 65,
        'conversions': 8,
        'revenue': 96000.0,
        'conversionRate': 12.3,
      },
      {
        'id': 'SA586suG1L5njUhL5L8s',
        'productName': 'แพะแองโกร่า 12 เดือน',
        'views': 156,
        'clicks': 52,
        'conversions': 5,
        'revenue': 37500.0,
        'conversionRate': 9.6,
      },
    ];
    
    final totalLinks = quickBuyLinks.length;
    final totalViews = quickBuyLinks.fold<int>(0, (sum, link) => sum + (link['views'] as int));
    final totalConversions = quickBuyLinks.fold<int>(0, (sum, link) => sum + (link['conversions'] as int));
    final totalRevenue = quickBuyLinks.fold<double>(0, (sum, link) => sum + (link['revenue'] as double));
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.link, color: const Color(0xFF9C27B0)),
                const SizedBox(width: 8),
                const Text(
                  '🔗 Quick Buy Links Performance',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Summary Metrics
            Row(
              children: [
                Expanded(
                  child: _buildQuickBuyMetricCard(
                    'Total Links',
                    totalLinks.toString(),
                    Icons.link,
                    Colors.purple,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildQuickBuyMetricCard(
                    'Total Views',
                    totalViews.toString(),
                    Icons.visibility,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildQuickBuyMetricCard(
                    'Conversions',
                    totalConversions.toString(),
                    Icons.shopping_cart,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildQuickBuyMetricCard(
                    'Revenue',
                    '฿${(totalRevenue / 1000).toStringAsFixed(0)}K',
                    Icons.attach_money,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            
            // Top Performing Links
            Row(
              children: [
                Icon(Icons.emoji_events, color: Colors.amber[700], size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Top Performing Links',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Links List
            ...quickBuyLinks.asMap().entries.map((entry) {
              final index = entry.key;
              final link = entry.value;
              return _buildQuickBuyLinkItem(
                index + 1,
                link['productName'] as String,
                link['views'] as int,
                link['conversions'] as int,
                link['revenue'] as double,
                link['id'] as String,
              );
            }),
          ],
        ),
      ),
    );
  }
  
  Widget _buildQuickBuyMetricCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuickBuyLinkItem(
    int rank,
    String productName,
    int views,
    int conversions,
    double revenue,
    String listingId,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          // Rank Badge
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: rank == 1 ? Colors.amber : rank == 2 ? Colors.grey[400] : Colors.brown[300],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$rank',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$views views • $conversions sales',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          // Revenue
          Text(
            '฿${(revenue / 1000).toStringAsFixed(0)}K',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF228B22),
            ),
          ),
          const SizedBox(width: 12),
          
          // Copy Link Button
          IconButton(
            icon: const Icon(Icons.copy, size: 18),
            tooltip: 'Copy Link',
            color: const Color(0xFF9C27B0),
            onPressed: () {
              final url = '${Uri.base.origin}/#/quick-buy/$listingId';
              Clipboard.setData(ClipboardData(text: url));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ คัดลอกลิงก์แล้ว!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformPerformance() {
    final platformStats = _stats['platformStats'] as Map<String, dynamic>? ?? {};
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ผลการแชร์แยกตาม Platform',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...platformStats.entries.map((entry) {
              final platform = entry.key;
              final stats = entry.value as Map<String, dynamic>;
              return _buildPlatformRow(platform, stats);
            }).toList(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPlatformRow(String platform, Map<String, dynamic> stats) {
    final shares = stats['shares'] ?? 0;
    final clicks = stats['clicks'] ?? 0;
    final purchases = stats['purchases'] ?? 0;
    final conversionRate = stats['conversionRate'] ?? 0.0;
    
    final platformIcons = {
      'facebook': Icons.facebook,
      'tiktok': Icons.music_note,
      'x': Icons.tag,
      'line': Icons.chat_bubble,
    };
    
    final platformColors = {
      'facebook': Color(0xFF1877F2),
      'tiktok': Colors.black,
      'x': Colors.black,
      'line': Color(0xFF00B900),
    };
    
    final platformNames = {
      'facebook': 'Facebook',
      'tiktok': 'TikTok',
      'x': 'X (Twitter)',
      'line': 'LINE',
    };
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                platformIcons[platform] ?? Icons.share,
                color: platformColors[platform] ?? Colors.grey,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                platformNames[platform] ?? platform,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: conversionRate >= 10
                      ? Colors.green.shade100
                      : Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${conversionRate.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: conversionRate >= 10
                        ? Colors.green.shade700
                        : Colors.orange.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildPlatformStat('แชร์', '$shares'),
              _buildPlatformStat('คลิก', '$clicks'),
              _buildPlatformStat('ซื้อ', '$purchases'),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildPlatformStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
  
  Widget _buildConversionFunnel() {
    final totalShares = _stats['totalShares'] ?? 0;
    final totalViews = _stats['totalViews'] ?? 0;
    final totalClicks = _stats['totalClicks'] ?? 0;
    final totalPurchases = _stats['totalPurchases'] ?? 0;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Conversion Funnel',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _buildFunnelStep('การแชร์', totalShares, 1.0, Colors.blue),
            _buildFunnelStep(
              'การดู',
              totalViews,
              totalShares > 0 ? totalViews / totalShares : 0,
              Colors.purple,
            ),
            _buildFunnelStep(
              'คลิก',
              totalClicks,
              totalViews > 0 ? totalClicks / totalViews : 0,
              Colors.orange,
            ),
            _buildFunnelStep(
              'ซื้อสำเร็จ',
              totalPurchases,
              totalClicks > 0 ? totalPurchases / totalClicks : 0,
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFunnelStep(String label, int count, double ratio, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$count (${(ratio * 100).toStringAsFixed(1)}%)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: ratio,
            backgroundColor: Colors.grey.shade200,
            color: color,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTopPerformers() {
    final topPerformers = _stats['topPerformers'] as List<dynamic>? ?? [];
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'สินค้าขายดี Top 5',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (topPerformers.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('ยังไม่มีข้อมูล'),
                ),
              )
            else
              ...topPerformers.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value as Map<String, dynamic>;
                return _buildTopPerformerItem(
                  rank: index + 1,
                  title: item['title'] ?? 'ไม่ระบุ',
                  shares: item['shares'] ?? 0,
                  purchases: item['purchases'] ?? 0,
                  revenue: item['revenue'] ?? 0.0,
                );
              }).toList(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTopPerformerItem({
    required int rank,
    required String title,
    required int shares,
    required int purchases,
    required double revenue,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: rank <= 3 ? Colors.yellow.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: rank <= 3
            ? Border.all(color: Colors.yellow.shade700, width: 2)
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: rank == 1
                  ? Colors.yellow.shade700
                  : rank == 2
                      ? Colors.grey.shade400
                      : rank == 3
                          ? Colors.brown.shade400
                          : Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$rank',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '$shares แชร์ • $purchases ขาย • ${_formatCurrency(revenue)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRevenueBreakdown() {
    final revenueBySource = _stats['revenueBySource'] as Map<String, dynamic>? ?? {};
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'รายได้แยกตาม Platform',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...revenueBySource.entries.map((entry) {
              return _buildRevenueRow(entry.key, entry.value);
            }).toList(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRevenueRow(String platform, double revenue) {
    final totalRevenue = _stats['totalRevenue'] ?? 1.0;
    final percentage = (revenue / totalRevenue) * 100;
    
    final platformNames = {
      'facebook': 'Facebook',
      'tiktok': 'TikTok',
      'x': 'X (Twitter)',
      'line': 'LINE',
    };
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                platformNames[platform] ?? platform,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                _formatCurrency(revenue),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF228B22),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.grey.shade200,
            color: const Color(0xFF228B22),
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
        ],
      ),
    );
  }
  
  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return '$number';
  }
  
  String _formatCurrency(double amount) {
    return '฿${NumberFormat('#,##0').format(amount)}';
  }
}
