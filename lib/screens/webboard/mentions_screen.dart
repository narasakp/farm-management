/**
 * Mentions Screen
 * แสดงรายการคนที่ mention เรา
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'dart:html' as html;
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../providers/auth_provider.dart';
import '../../widgets/app_bars/standard_app_bar.dart';
import '../../config/api_config.dart';
import '../../utils/date_formatter.dart';

class MentionsScreen extends StatefulWidget {
  const MentionsScreen({super.key});

  @override
  State<MentionsScreen> createState() => _MentionsScreenState();
}

class _MentionsScreenState extends State<MentionsScreen> {
  List<Map<String, dynamic>> _mentions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMentions();
  }

  Future<void> _loadMentions() async {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;

    if (user == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/forum/mentions/${user.id}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _mentions = List<Map<String, dynamic>>.from(data['mentions'] ?? []);
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading mentions: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StandardAppBar(
        type: AppBarType.detail,
        title: '💬 Mentions',
        onBackPressed: () {
          // กลับหน้าก่อนหน้าจริงๆ
          html.window.history.back();
        },
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _mentions.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadMentions,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _mentions.length,
                    separatorBuilder: (context, index) => const Divider(height: 32),
                    itemBuilder: (context, index) {
                      return _buildMentionCard(_mentions[index]);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.alternate_email,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'ยังไม่มีคนกล่าวถึงคุณ',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'เมื่อมีคนใช้ @username เพื่อกล่าวถึงคุณ\nจะแสดงที่นี่',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMentionCard(Map<String, dynamic> mention) {
    final type = mention['type'] ?? 'thread';
    final isThread = type == 'thread';
    
    return InkWell(
      onTap: () => context.push('/thread/${mention['thread_id']}'),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Type & Time
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isThread ? Colors.blue[50] : Colors.green[50],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isThread ? Icons.forum : Icons.reply,
                        size: 14,
                        color: isThread ? Colors.blue[700] : Colors.green[700],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isThread ? 'กระทู้' : 'คำตอบ',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isThread ? Colors.blue[700] : Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  DateFormatter.formatRelative(mention['created_at']),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Mentioned by
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  child: Text(
                    (mention['mentioned_by_username'] ?? '?')[0].toUpperCase(),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                      children: [
                        TextSpan(
                          text: mention['mentioned_by_username'] ?? 'Unknown',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const TextSpan(text: ' กล่าวถึงคุณใน'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Thread title
            if (mention['thread_title'] != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.article, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            mention['thread_title'],
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (mention['thread_category'] != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        _getCategoryText(mention['thread_category']),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

            const SizedBox(height: 12),

            // View button
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => context.push('/thread/${mention['thread_id']}'),
                icon: const Icon(Icons.arrow_forward, size: 16),
                label: const Text('ดูกระทู้'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCategoryText(String category) {
    switch (category) {
      case 'general':
        return 'ทั่วไป';
      case 'question':
        return 'คำถาม';
      case 'discussion':
        return 'พูดคุย';
      case 'announcement':
        return 'ประกาศ';
      case 'help':
        return 'ขอความช่วยเหลือ';
      case 'feedback':
        return 'แสดงความคิดเห็น';
      default:
        return category;
    }
  }
}
