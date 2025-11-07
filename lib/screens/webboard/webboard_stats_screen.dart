import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:html' as html; // สำหรับ browser history
import '../../config/api_config.dart';
import '../../utils/app_theme.dart';
import '../../widgets/app_bars/standard_app_bar.dart';
import '../../utils/tab_navigation_mixin.dart';

class WebboardStatsScreen extends StatefulWidget {
  const WebboardStatsScreen({super.key});

  @override
  State<WebboardStatsScreen> createState() => _WebboardStatsScreenState();
}

class _WebboardStatsScreenState extends State<WebboardStatsScreen> with TabNavigationMixin {
  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/forum/stats'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            _stats = data['stats'];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading stats: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StandardAppBar(
        type: AppBarType.main,
        title: 'สถิติกระทู้',
        onBackPressed: () {
          // ✅ ใช้ browser history.back() เพื่อกลับหน้าก่อนหน้าจริงๆ
          html.window.history.back();
        },
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _stats == null
              ? const Center(child: Text('ไม่สามารถโหลดข้อมูลได้'))
              : RefreshIndicator(
                  onRefresh: _loadStats,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Overview stats
                        _buildOverviewSection(),
                        const SizedBox(height: 24),
                        // Activity stats
                        _buildActivitySection(),
                        const SizedBox(height: 24),
                        // Category stats
                        _buildCategorySection(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildOverviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ภาพรวม',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.3,
          children: [
            _buildStatCard(
              icon: Icons.article,
              label: 'กระทู้ทั้งหมด',
              value: _stats!['totalThreads'].toString(),
              color: Colors.blue,
            ),
            _buildStatCard(
              icon: Icons.comment,
              label: 'คำตอบทั้งหมด',
              value: _stats!['totalReplies'].toString(),
              color: Colors.green,
            ),
            _buildStatCard(
              icon: Icons.visibility,
              label: 'ยอดเข้าชมรวม',
              value: _formatNumber(_stats!['totalViews']),
              color: Colors.orange,
            ),
            _buildStatCard(
              icon: Icons.people,
              label: 'ผู้ใช้ที่โพสต์',
              value: _stats!['totalUsers'].toString(),
              color: AppTheme.primaryColor,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActivitySection() {
    final totalThreads = _stats!['totalThreads'];
    final resolvedThreads = _stats!['resolvedThreads'];
    final resolvedRate = totalThreads > 0 
        ? (resolvedThreads / totalThreads * 100).toStringAsFixed(1)
        : '0.0';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'กิจกรรมล่าสุด (7 วัน)',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildActivityRow(
                  icon: Icons.add_circle,
                  label: 'กระทู้ใหม่',
                  value: _stats!['recentThreads'].toString(),
                  color: Colors.blue,
                ),
                const SizedBox(height: 16),
                _buildActivityRow(
                  icon: Icons.reply,
                  label: 'คำตอบใหม่',
                  value: _stats!['recentReplies'].toString(),
                  color: Colors.green,
                ),
                const Divider(height: 32),
                _buildActivityRow(
                  icon: Icons.check_circle,
                  label: 'กระทู้ที่ได้คำตอบ',
                  value: '$resolvedThreads / $totalThreads',
                  color: Colors.purple,
                  subtitle: 'อัตราการได้คำตอบ $resolvedRate%',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySection() {
    final categories = _stats!['topCategories'] as List<dynamic>;
    
    if (categories.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'หมวดหมู่ยอดนิยม',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: categories.map((cat) {
                final category = cat['category'] as String;
                final count = cat['count'] as int;
                return _buildCategoryItem(category, count);
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: color),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    String? subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[700],
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryItem(String category, int count) {
    final categoryNames = {
      'plant_disease': 'โรคพืช',
      'fertilizer': 'ปุ๋ยและการบำรุง',
      'pest_control': 'แมลงศัตรูพืช',
      'cultivation': 'การเพาะปลูก',
      'general': 'ทั่วไป',
      'other': 'อื่นๆ',
    };

    final categoryIcons = {
      'plant_disease': Icons.coronavirus,
      'fertilizer': Icons.water_drop,
      'pest_control': Icons.bug_report,
      'cultivation': Icons.grass,
      'general': Icons.forum,
      'other': Icons.more_horiz,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            categoryIcons[category] ?? Icons.category,
            color: AppTheme.primaryColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              categoryNames[category] ?? category,
              style: const TextStyle(fontSize: 15),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
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
    return number.toString();
  }
}
