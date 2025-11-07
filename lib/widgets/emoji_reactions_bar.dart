import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/webboard_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';

class EmojiReactionsBar extends StatefulWidget {
  final String contentType; // 'thread' or 'reply'
  final String contentId;

  const EmojiReactionsBar({
    super.key,
    required this.contentType,
    required this.contentId,
  });

  @override
  State<EmojiReactionsBar> createState() => _EmojiReactionsBarState();
}

class _EmojiReactionsBarState extends State<EmojiReactionsBar> {
  List<dynamic> _reactions = [];
  bool _isLoading = true;
  
  // Available emojis
  final List<String> _availableEmojis = ['👍', '❤️', '😂', '😮', '😢'];

  @override
  void initState() {
    super.initState();
    _loadReactions();
  }

  Future<void> _loadReactions() async {
    final provider = context.read<WebboardProvider>();
    final result = await provider.getReactions(widget.contentType, widget.contentId);
    
    if (mounted) {
      setState(() {
        _reactions = result['reactions'] ?? [];
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleReaction(String emoji) async {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.currentUser?.id?.toString();
    final userName = authProvider.currentUser?.fullName ?? 'ผู้ใช้';

    if (userId == null) return;

    final provider = context.read<WebboardProvider>();
    final success = await provider.toggleReaction(
      contentType: widget.contentType,
      contentId: widget.contentId,
      userId: userId,
      userName: userName,
      emoji: emoji,
    );

    if (success && mounted) {
      _loadReactions();
    }
  }

  bool _hasUserReacted(String emoji, String userId) {
    final reaction = _reactions.firstWhere(
      (r) => r['emoji'] == emoji,
      orElse: () => null,
    );
    
    if (reaction == null) return false;
    
    final users = reaction['users'] as List<dynamic>? ?? [];
    return users.any((u) => u['userId'].toString() == userId);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 36,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final userId = authProvider.currentUser?.id?.toString() ?? '';

        return Wrap(
          spacing: 6,
          runSpacing: 6,
          children: _availableEmojis.map((emoji) {
            final reactionData = _reactions.firstWhere(
              (r) => r['emoji'] == emoji,
              orElse: () => null,
            );

            final count = reactionData?['count'] ?? 0;
            final hasReacted = _hasUserReacted(emoji, userId);

            return InkWell(
              onTap: userId.isEmpty ? null : () => _toggleReaction(emoji),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: hasReacted 
                      ? AppTheme.primaryColor.withOpacity(0.15)
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: hasReacted 
                        ? AppTheme.primaryColor
                        : Colors.grey[300]!,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      emoji,
                      style: const TextStyle(fontSize: 16),
                    ),
                    if (count > 0) ...[
                      const SizedBox(width: 4),
                      Text(
                        count.toString(),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: hasReacted ? AppTheme.primaryColor : Colors.grey[700],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
