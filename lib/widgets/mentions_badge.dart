/**
 * Mentions Badge Widget
 * แสดงจำนวน mentions ใหม่ที่ยังไม่ได้อ่าน
 */

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../config/api_config.dart';

class MentionsBadge extends StatefulWidget {
  final String userId;
  final Color? badgeColor;
  final Color? iconColor;

  const MentionsBadge({
    super.key,
    required this.userId,
    this.badgeColor,
    this.iconColor,
  });

  @override
  State<MentionsBadge> createState() => _MentionsBadgeState();
}

class _MentionsBadgeState extends State<MentionsBadge> {
  int _mentionCount = 0;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadMentionCount();
    
    // Auto-refresh every 30 seconds
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _loadMentionCount(),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadMentionCount() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/forum/mentions/${widget.userId}?limit=10'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _mentionCount = data['total'] ?? 0;
          });
        }
      }
    } catch (e) {
      print('Error loading mention count: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Stack(
        children: [
          Icon(
            Icons.alternate_email,
            color: widget.iconColor ?? Colors.white,
          ),
          if (_mentionCount > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: widget.badgeColor ?? Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
                ),
                child: Text(
                  _mentionCount > 9 ? '9+' : '$_mentionCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
      tooltip: 'Mentions',
      onPressed: () {
        context.push('/mentions');
      },
    );
  }
}
