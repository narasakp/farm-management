/**
 * Activity Feed Screen
 * แสดงกิจกรรมล่าสุดของผู้ใช้และชุมชน
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

class ActivityFeedScreen extends StatefulWidget {
  const ActivityFeedScreen({super.key});

  @override
  State<ActivityFeedScreen> createState() => _ActivityFeedScreenState();
}

class _ActivityFeedScreenState extends State<ActivityFeedScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _myScrollController = ScrollController();
  final ScrollController _publicScrollController = ScrollController();

  List<Map<String, dynamic>> _myActivities = [];
  List<Map<String, dynamic>> _publicActivities = [];
  
  bool _isLoadingMy = false;
  bool _isLoadingPublic = false;
  bool _hasMoreMy = true;
  bool _hasMorePublic = true;
  
  String? _selectedFilter;
  int _myOffset = 0;
  int _publicOffset = 0;
  final int _limit = 20;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Load initial data
    _loadMyActivities();
    _loadPublicActivities();
    
    // Setup infinite scroll
    _myScrollController.addListener(_onMyScroll);
    _publicScrollController.addListener(_onPublicScroll);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _myScrollController.dispose();
    _publicScrollController.dispose();
    super.dispose();
  }

  void _onMyScroll() {
    if (_myScrollController.position.pixels >= _myScrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMy && _hasMoreMy) {
        _loadMoreMyActivities();
      }
    }
  }

  void _onPublicScroll() {
    if (_publicScrollController.position.pixels >= _publicScrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingPublic && _hasMorePublic) {
        _loadMorePublicActivities();
      }
    }
  }

  Future<void> _loadMyActivities({bool refresh = false}) async {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;

    if (user == null) return;

    if (refresh) {
      setState(() {
        _myOffset = 0;
        _myActivities = [];
        _hasMoreMy = true;
      });
    }

    setState(() {
      _isLoadingMy = true;
    });

    try {
      var url = '${ApiConfig.baseUrl}/api/forum/activities/${user.id}?limit=$_limit&offset=$_myOffset';
      if (_selectedFilter != null) {
        url += '&type=$_selectedFilter';
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final activities = List<Map<String, dynamic>>.from(data['activities'] ?? []);
        
        if (mounted) {
          setState(() {
            if (refresh) {
              _myActivities = activities;
            } else {
              _myActivities.addAll(activities);
            }
            _hasMoreMy = activities.length == _limit;
            _isLoadingMy = false;
          });
        }
      }
    } catch (e) {
      print('Error loading my activities: $e');
      if (mounted) {
        setState(() {
          _isLoadingMy = false;
        });
      }
    }
  }

  Future<void> _loadMoreMyActivities() async {
    _myOffset += _limit;
    await _loadMyActivities();
  }

  Future<void> _loadPublicActivities({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _publicOffset = 0;
        _publicActivities = [];
        _hasMorePublic = true;
      });
    }

    setState(() {
      _isLoadingPublic = true;
    });

    try {
      var url = '${ApiConfig.baseUrl}/api/forum/activities/feed/public?limit=$_limit&offset=$_publicOffset';
      if (_selectedFilter != null) {
        url += '&type=$_selectedFilter';
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final activities = List<Map<String, dynamic>>.from(data['activities'] ?? []);
        
        if (mounted) {
          setState(() {
            if (refresh) {
              _publicActivities = activities;
            } else {
              _publicActivities.addAll(activities);
            }
            _hasMorePublic = activities.length == _limit;
            _isLoadingPublic = false;
          });
        }
      }
    } catch (e) {
      print('Error loading public activities: $e');
      if (mounted) {
        setState(() {
          _isLoadingPublic = false;
        });
      }
    }
  }

  Future<void> _loadMorePublicActivities() async {
    _publicOffset += _limit;
    await _loadPublicActivities();
  }

  void _applyFilter(String? filter) {
    setState(() {
      _selectedFilter = filter;
    });
    _loadMyActivities(refresh: true);
    _loadPublicActivities(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StandardAppBar(
        type: AppBarType.detail,
        title: '📊 กิจกรรมล่าสุด',
        onBackPressed: () {
          // กลับหน้าก่อนหน้าจริงๆ
          html.window.history.back();
        },
        customActions: [
          PopupMenuButton<String>(
            icon: Icon(
              _selectedFilter != null ? Icons.filter_alt : Icons.filter_alt_outlined,
              color: _selectedFilter != null ? Colors.blue : Colors.white,
            ),
            tooltip: 'กรองตามประเภท',
            onSelected: _applyFilter,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: null,
                child: Text('ทั้งหมด'),
              ),
              const PopupMenuItem(
                value: 'thread',
                child: Text('📝 กระทู้'),
              ),
              const PopupMenuItem(
                value: 'reply',
                child: Text('💬 คำตอบ'),
              ),
              const PopupMenuItem(
                value: 'vote',
                child: Text('👍 โหวต'),
              ),
              const PopupMenuItem(
                value: 'mention',
                child: Text('@ กล่าวถึง'),
              ),
              const PopupMenuItem(
                value: 'bookmark',
                child: Text('🔖 บันทึก'),
              ),
              const PopupMenuItem(
                value: 'follow',
                child: Text('🔔 ติดตาม'),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'กิจกรรมของฉัน'),
            Tab(text: 'กิจกรรมทั้งหมด'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMyActivitiesTab(),
          _buildPublicActivitiesTab(),
        ],
      ),
    );
  }

  Widget _buildMyActivitiesTab() {
    if (_isLoadingMy && _myActivities.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_myActivities.isEmpty) {
      return _buildEmptyState('คุณยังไม่มีกิจกรรม');
    }

    return RefreshIndicator(
      onRefresh: () => _loadMyActivities(refresh: true),
      child: ListView.separated(
        controller: _myScrollController,
        padding: const EdgeInsets.all(16),
        itemCount: _myActivities.length + (_hasMoreMy ? 1 : 0),
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index >= _myActivities.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            );
          }
          return _buildActivityCard(_myActivities[index]);
        },
      ),
    );
  }

  Widget _buildPublicActivitiesTab() {
    if (_isLoadingPublic && _publicActivities.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_publicActivities.isEmpty) {
      return _buildEmptyState('ยังไม่มีกิจกรรม');
    }

    return RefreshIndicator(
      onRefresh: () => _loadPublicActivities(refresh: true),
      child: ListView.separated(
        controller: _publicScrollController,
        padding: const EdgeInsets.all(16),
        itemCount: _publicActivities.length + (_hasMorePublic ? 1 : 0),
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index >= _publicActivities.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            );
          }
          return _buildActivityCard(_publicActivities[index]);
        },
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(Map<String, dynamic> activity) {
    final activityType = activity['activity_type'] ?? '';
    final action = activity['action'] ?? '';
    final username = activity['username'] ?? 'Unknown';
    final targetTitle = activity['target_title'] ?? '';
    final createdAt = activity['created_at'];

    final icon = _getActivityIcon(activityType, action);
    final color = _getActivityColor(activityType);
    final description = _getActivityDescription(activityType, action, username, targetTitle);

    return InkWell(
      onTap: () => _handleActivityTap(activity),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (targetTitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      targetTitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    DateFormatter.formatRelative(createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            
            // Arrow
            Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
          ],
        ),
      ),
    );
  }

  IconData _getActivityIcon(String type, String action) {
    switch (type) {
      case 'thread':
        return Icons.article;
      case 'reply':
        return Icons.reply;
      case 'vote':
        return action == 'upvoted' ? Icons.thumb_up : Icons.thumb_down;
      case 'mention':
        return Icons.alternate_email;
      case 'bookmark':
        return action == 'bookmarked' ? Icons.bookmark : Icons.bookmark_border;
      case 'follow':
        return action == 'followed' ? Icons.notifications_active : Icons.notifications_off;
      case 'report':
        return Icons.flag;
      default:
        return Icons.circle;
    }
  }

  Color _getActivityColor(String type) {
    switch (type) {
      case 'thread':
        return Colors.blue[700]!;
      case 'reply':
        return Colors.green[700]!;
      case 'vote':
        return Colors.orange[700]!;
      case 'mention':
        return Colors.purple[700]!;
      case 'bookmark':
        return Colors.red[700]!;
      case 'follow':
        return Colors.teal[700]!;
      case 'report':
        return Colors.grey[700]!;
      default:
        return Colors.grey[500]!;
    }
  }

  String _getActivityDescription(String type, String action, String username, String targetTitle) {
    switch (type) {
      case 'thread':
        return '$username สร้างกระทู้ใหม่';
      case 'reply':
        return '$username ตอบกระทู้';
      case 'vote':
        return action == 'upvoted' ? '$username โหวตขึ้น' : '$username โหวตลง';
      case 'mention':
        return '$username กล่าวถึง $targetTitle';
      case 'bookmark':
        return action == 'bookmarked' ? '$username บันทึกกระทู้' : '$username ยกเลิกบันทึก';
      case 'follow':
        return action == 'followed' ? '$username ติดตามกระทู้' : '$username ยกเลิกติดตาม';
      case 'report':
        return '$username รายงานเนื้อหา';
      default:
        return '$username $action';
    }
  }

  void _handleActivityTap(Map<String, dynamic> activity) {
    final targetType = activity['target_type'];
    final targetId = activity['target_id'];
    final metadata = activity['metadata'];

    if (targetType == 'thread' && targetId != null) {
      context.push('/thread/$targetId');
    } else if (targetType == 'user' && metadata != null) {
      // If mention, go to thread
      final threadId = metadata['threadId'];
      if (threadId != null) {
        context.push('/thread/$threadId');
      }
    }
  }
}
