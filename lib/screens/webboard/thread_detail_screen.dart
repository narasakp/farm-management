import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_html/flutter_html.dart';
import 'dart:html' as html;
import '../../providers/webboard_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/thread.dart';
import '../../models/thread_reply.dart';
import '../../widgets/app_bars/standard_app_bar.dart';
import '../../widgets/standard_snackbar.dart';
import '../../widgets/emoji_reactions_bar.dart';
import '../../widgets/quill_editor_widget.dart';
import '../../widgets/report_dialog.dart';
import '../../utils/tab_navigation_mixin.dart';
import '../../utils/app_theme.dart';
import '../../config/api_config.dart';

class ThreadDetailScreen extends StatefulWidget {
  final String threadId;
  
  const ThreadDetailScreen({
    super.key,
    required this.threadId,
  });

  @override
  State<ThreadDetailScreen> createState() => _ThreadDetailScreenState();
}

class _ThreadDetailScreenState extends State<ThreadDetailScreen> with TabNavigationMixin {
  final _replyController = TextEditingController();
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  Thread? _thread;
  List<ThreadReply> _replies = [];
  List<ThreadReply> _filteredReplies = [];
  bool _isLoading = true;
  bool _isSearching = false;
  String? _replyingToId; // For nested replies
  String? _replyingToName;
  
  // Vote tracking
  final Map<String, String> _userThreadVotes = {}; // threadId -> 'up'/'down'
  final Map<String, String> _userReplyVotes = {}; // replyId -> 'up'/'down'
  
  // Bookmark & Follow status
  bool _isBookmarked = false;
  bool _isFollowing = false;

  @override
  void initState() {
    super.initState();
    _loadThreadDetail();
  }

  @override
  void dispose() {
    _replyController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadThreadDetail() async {
    setState(() => _isLoading = true);
    
    final provider = context.read<WebboardProvider>();
    final thread = await provider.loadThreadDetail(widget.threadId);
    
    if (thread != null && mounted) {
      setState(() {
        _thread = thread;
        _replies = provider.getReplies(widget.threadId);
        _filteredReplies = _replies;
        _isLoading = false;
      });
      
      // Load bookmark/follow status
      final authProvider = context.read<AuthProvider>();
      final userId = authProvider.currentUser?.id?.toString();
      if (userId != null) {
        final status = await provider.getThreadStatus(widget.threadId, userId);
        if (mounted) {
          setState(() {
            _isBookmarked = status['isBookmarked'] ?? false;
            _isFollowing = status['isFollowing'] ?? false;
          });
        }
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitReply() async {
    if (_replyController.text.trim().isEmpty) {
      StandardSnackbar.showWarning(context, 'กรุณากรอกข้อความตอบกลับ');
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final webboardProvider = context.read<WebboardProvider>();

    final result = await webboardProvider.createReply(
      threadId: widget.threadId,
      content: _replyController.text.trim(),
      authorId: authProvider.currentUser?.id?.toString() ?? 'anonymous',
      authorName: authProvider.currentUser?.fullName ?? 'ผู้ใช้ไม่ระบุชื่อ',
      authorAvatar: authProvider.currentUser?.avatarUrl,
      parentReplyId: _replyingToId,
    );

    if (result['success'] == true && mounted) {
      StandardSnackbar.showSuccess(context, 'ตอบกลับสำเร็จ');
      _replyController.clear();
      setState(() {
        _replyingToId = null;
        _replyingToName = null;
      });
      await _loadThreadDetail();
    } else if (mounted) {
      StandardSnackbar.showError(context, result['message'] ?? 'เกิดข้อผิดพลาด');
    }
  }

  Future<void> _voteThread(String voteType) async {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.currentUser?.id?.toString();
    
    if (userId == null) {
      StandardSnackbar.showWarning(context, 'กรุณาเข้าสู่ระบบ');
      return;
    }

    final provider = context.read<WebboardProvider>();
    final success = await provider.voteThread(widget.threadId, userId, voteType);
    
    if (success && mounted) {
      setState(() {
        _userThreadVotes[widget.threadId] = voteType;
      });
      await _loadThreadDetail();
    }
  }

  Future<void> _voteReply(String replyId, String voteType) async {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.currentUser?.id?.toString();
    
    if (userId == null) {
      StandardSnackbar.showWarning(context, 'กรุณาเข้าสู่ระบบ');
      return;
    }

    final provider = context.read<WebboardProvider>();
    final success = await provider.voteReply(replyId, userId, voteType);
    
    if (success && mounted) {
      setState(() {
        _userReplyVotes[replyId] = voteType;
      });
      await _loadThreadDetail();
    }
  }

  Future<void> _acceptAnswer(String replyId) async {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.currentUser?.id?.toString();
    
    // Check if user is thread author
    if (userId != _thread?.authorId) {
      StandardSnackbar.showWarning(context, 'เฉพาะเจ้าของกระทู้เท่านั้นที่เลือกคำตอบได้');
      return;
    }

    final provider = context.read<WebboardProvider>();
    final success = await provider.acceptAnswer(widget.threadId, replyId);
    
    if (success && mounted) {
      StandardSnackbar.showSuccess(context, 'เลือกคำตอบที่ดีที่สุดแล้ว');
      await _loadThreadDetail();
    }
  }

  void _setReplyingTo(String replyId, String authorName) {
    setState(() {
      _replyingToId = replyId;
      _replyingToName = authorName;
    });
    // Scroll to reply box
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _cancelReplyingTo() {
    setState(() {
      _replyingToId = null;
      _replyingToName = null;
    });
  }

  Future<void> _handleMenuAction(String action, bool isAdmin) async {
    switch (action) {
      case 'edit':
        await _showEditThreadDialog();
        break;
      case 'delete':
        await _showDeleteConfirmation();
        break;
      case 'pin':
        await _togglePin();
        break;
      case 'lock':
        await _toggleLock();
        break;
      case 'report':
        await _showReportDialog('thread', widget.threadId);
        break;
    }
  }

  Future<void> _showEditThreadDialog() async {
    final titleController = TextEditingController(text: _thread!.title);
    final editorController = QuillToHtmlConverter.fromHtml(_thread!.content);
    ThreadCategory selectedCategory = _thread!.category;
    List<String> tags = List.from(_thread!.tags);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'แก้ไขกระทู้',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'หัวข้อ',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<ThreadCategory>(
                value: selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'หมวดหมู่',
                  border: OutlineInputBorder(),
                ),
                items: ThreadCategory.values.map((cat) {
                  final thread = Thread(
                    id: '',
                    authorId: '',
                    authorName: '',
                    title: '',
                    content: '',
                    category: cat,
                    createdAt: DateTime.now(),
                  );
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(thread.categoryText),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) selectedCategory = value;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'เนื้อหา',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 350,
                child: QuillEditorWidget(
                  controller: editorController,
                  height: 300,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('ยกเลิก'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      final content = QuillToHtmlConverter.toHtml(editorController);
                      Navigator.pop(context);
                      
                      final provider = context.read<WebboardProvider>();
                      final authProvider = context.read<AuthProvider>();
                      final result = await provider.editThread(
                        threadId: widget.threadId,
                        title: titleController.text.trim(),
                        content: content,
                        category: selectedCategory.toString().split('.').last,
                        tags: tags,
                        authorId: authProvider.currentUser?.id?.toString() ?? '',
                      );

                      if (mounted) {
                        if (result['success'] == true) {
                          StandardSnackbar.showSuccess(context, 'แก้ไขกระทู้สำเร็จ');
                          await _loadThreadDetail();
                        } else {
                          StandardSnackbar.showError(
                            context,
                            result['message'] ?? 'เกิดข้อผิดพลาด',
                          );
                        }
                      }
                    },
                    child: const Text('บันทึก'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: const Text('คุณแน่ใจหรือไม่ว่าต้องการลบกระทู้นี้?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final provider = context.read<WebboardProvider>();
      final authProvider = context.read<AuthProvider>();
      final result = await provider.deleteThread(
        threadId: widget.threadId,
        authorId: authProvider.currentUser?.id?.toString() ?? '',
      );

      if (mounted) {
        if (result['success'] == true) {
          StandardSnackbar.showSuccess(context, 'ลบกระทู้สำเร็จ');
          context.pop(); // Go back to list
        } else {
          StandardSnackbar.showError(context, result['message'] ?? 'เกิดข้อผิดพลาด');
        }
      }
    }
  }

  Future<void> _togglePin() async {
    final provider = context.read<WebboardProvider>();
    final success = await provider.pinThread(widget.threadId, !_thread!.isPinned);

    if (mounted && success) {
      StandardSnackbar.showSuccess(
        context,
        _thread!.isPinned ? 'ยกเลิกปักหมุดแล้ว' : 'ปักหมุดกระทู้แล้ว',
      );
      await _loadThreadDetail();
    }
  }

  Future<void> _toggleLock() async {
    final provider = context.read<WebboardProvider>();
    final success = await provider.lockThread(widget.threadId, !_thread!.isLocked);

    if (mounted && success) {
      StandardSnackbar.showSuccess(
        context,
        _thread!.isLocked ? 'ปลดล็อกกระทู้แล้ว' : 'ล็อกกระทู้แล้ว',
      );
      await _loadThreadDetail();
    }
  }

  Future<void> _showReportDialog(String contentType, String contentId) async {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;

    if (user == null) {
      StandardSnackbar.showWarning(context, 'กรุณาเข้าสู่ระบบ');
      return;
    }

    showDialog(
      context: context,
      builder: (context) => ReportDialog(
        contentType: contentType,
        contentId: contentId,
        onReport: (reason, description) async {
          final provider = context.read<WebboardProvider>();
          final success = await provider.reportContent(
            contentType: contentType,
            contentId: contentId,
            reporterId: user.id.toString(),
            reporterName: user.username,
            reason: reason,
            description: description,
          );

          if (mounted && success) {
            StandardSnackbar.showSuccess(
              context,
              'รายงานสำเร็จ จะมีผู้ดูแลตรวจสอบในเร็วๆ นี้',
            );
          }
        },
      ),
    );
  }

  Future<void> _toggleBookmark() async {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.currentUser?.id?.toString();
    
    if (userId == null) {
      StandardSnackbar.showWarning(context, 'กรุณาเข้าสู่ระบบ');
      return;
    }

    final provider = context.read<WebboardProvider>();
    final success = await provider.bookmarkThread(widget.threadId, userId, !_isBookmarked);
    
    if (mounted && success) {
      setState(() {
        _isBookmarked = !_isBookmarked;
      });
      StandardSnackbar.showSuccess(
        context,
        _isBookmarked ? 'บันทึกกระทู้แล้ว' : 'ยกเลิกการบันทึกแล้ว',
      );
    }
  }

  Future<void> _toggleFollow() async {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.currentUser?.id?.toString();
    
    if (userId == null) {
      StandardSnackbar.showWarning(context, 'กรุณาเข้าสู่ระบบ');
      return;
    }

    final provider = context.read<WebboardProvider>();
    final result = _isFollowing 
      ? await provider.unfollowThread(threadId: widget.threadId, userId: userId)
      : await provider.followThread(threadId: widget.threadId, userId: userId);
    
    if (mounted && result['success'] == true) {
      setState(() {
        _isFollowing = !_isFollowing;
      });
      StandardSnackbar.showSuccess(
        context,
        _isFollowing ? 'ติดตามกระทู้แล้ว' : 'ยกเลิกการติดตามแล้ว',
      );
    }
  }

  Future<void> _handleReplyMenuAction(String action, ThreadReply reply) async {
    switch (action) {
      case 'edit':
        await _showEditReplyDialog(reply);
        break;
      case 'delete':
        await _showDeleteReplyConfirmation(reply);
        break;
      case 'report':
        await _showReportDialog('reply', reply.id);
        break;
    }
  }

  Future<void> _showEditReplyDialog(ThreadReply reply) async {
    final editorController = QuillToHtmlConverter.fromHtml(reply.content);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.7,
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'แก้ไขคำตอบ',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'เนื้อหา',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 350,
                child: QuillEditorWidget(
                  controller: editorController,
                  height: 300,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('ยกเลิก'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      final content = QuillToHtmlConverter.toHtml(editorController);
                      Navigator.pop(context);
                      
                      final provider = context.read<WebboardProvider>();
                      final authProvider = context.read<AuthProvider>();
                      final result = await provider.editReply(
                        replyId: reply.id,
                        content: content,
                        authorId: authProvider.currentUser?.id?.toString() ?? '',
                      );

                      if (mounted) {
                        if (result['success'] == true) {
                          StandardSnackbar.showSuccess(context, 'แก้ไขคำตอบสำเร็จ');
                          await _loadThreadDetail();
                        } else {
                          StandardSnackbar.showError(
                            context,
                            result['message'] ?? 'เกิดข้อผิดพลาด',
                          );
                        }
                      }
                    },
                    child: const Text('บันทึก'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteReplyConfirmation(ThreadReply reply) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: const Text('คุณแน่ใจหรือไม่ว่าต้องการลบคำตอบนี้?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final provider = context.read<WebboardProvider>();
      final authProvider = context.read<AuthProvider>();
      final result = await provider.deleteReply(
        replyId: reply.id,
        authorId: authProvider.currentUser?.id?.toString() ?? '',
      );

      if (mounted) {
        if (result['success'] == true) {
          StandardSnackbar.showSuccess(context, 'ลบคำตอบสำเร็จ');
          await _loadThreadDetail();
        } else {
          StandardSnackbar.showError(context, result['message'] ?? 'เกิดข้อผิดพลาด');
        }
      }
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredReplies = _replies;
      } else {
        _filteredReplies = _replies.where((reply) {
          return reply.content.toLowerCase().contains(query.toLowerCase()) ||
                 reply.authorName.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _filteredReplies = _replies;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StandardAppBar(
        type: AppBarType.main,
        title: 'รายละเอียดกระทู้',
        onBackPressed: () {
          // ✅ กลับหน้าก่อนหน้าจริงๆ (Webboard tab)
          html.window.history.back();
        },
        customActions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
            tooltip: 'ค้นหาในกระทู้',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _thread == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'ไม่พบกระทู้',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.pop(),
                        child: const Text('กลับ'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadThreadDetail,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_isSearching) _buildSearchBar(),
                        _buildThreadHeader(),
                        const SizedBox(height: 16),
                        _buildThreadContent(),
                        const SizedBox(height: 24),
                        _buildVoteSection(),
                        const SizedBox(height: 24),
                        _buildRepliesSection(),
                        const SizedBox(height: 24),
                        _buildReplyInput(),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'ค้นหาในคำตอบ...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged('');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey[100],
        ),
      ),
    );
  }

  Widget _buildThreadHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getCategoryColor(_thread!.category),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _thread!.categoryText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Title
            Text(
              _thread!.title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Author Info
            InkWell(
              onTap: () {
                context.push('/user-profile/${_thread!.authorId}');
              },
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: _thread!.authorAvatar != null
                        ? NetworkImage(_thread!.authorAvatar!)
                        : null,
                    child: _thread!.authorAvatar == null
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              _thread!.authorName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.arrow_forward, size: 14, color: AppTheme.primaryColor),
                          ],
                        ),
                        Text(
                          _formatDateTime(_thread!.createdAt),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                // Status badges
                if (_thread!.isPinned)
                  const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Icon(Icons.push_pin, color: Colors.orange, size: 20),
                  ),
                if (_thread!.isLocked)
                  const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Icon(Icons.lock, color: Colors.red, size: 20),
                  ),
                if (_thread!.hasAcceptedAnswer)
                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
                // Edited badge
                if (_thread!.isEdited)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.shade300),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.edit, size: 12, color: Colors.orange.shade700),
                          const SizedBox(width: 4),
                          Text(
                            'แก้ไขแล้ว',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.orange.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const Spacer(),
                // Follow/Unfollow button
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    final userId = authProvider.currentUser?.id?.toString();
                    if (userId == null) return const SizedBox();
                    
                    return IconButton(
                      icon: Icon(
                        _isFollowing ? Icons.notifications_active : Icons.notifications_none,
                        color: _isFollowing ? AppTheme.primaryColor : Colors.grey,
                      ),
                      onPressed: _toggleFollow,
                      tooltip: _isFollowing ? 'เลิกติดตาม' : 'ติดตามกระทู้',
                    );
                  },
                ),
                // Report button (for non-authors)
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    final userId = authProvider.currentUser?.id?.toString();
                    final isAuthor = userId == _thread!.authorId;
                    
                    if (isAuthor) return const SizedBox();
                    
                    return IconButton(
                      icon: const Icon(Icons.flag_outlined),
                      onPressed: () => _showReportDialog('thread', widget.threadId),
                      tooltip: 'รายงานเนื้อหาไม่เหมาะสม',
                      color: Colors.red[400],
                    );
                  },
                ),
                // Menu button
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    final userId = authProvider.currentUser?.id?.toString();
                    final isAuthor = userId == _thread!.authorId;
                    final isAdmin = authProvider.currentUser?.role == 'ADMIN' || 
                                  authProvider.currentUser?.role == 'SUPER_ADMIN';
                    
                    return PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      onSelected: (value) => _handleMenuAction(value, isAdmin),
                      itemBuilder: (context) {
                        final items = <PopupMenuEntry<String>>[];
                        
                        // Author actions
                        if (isAuthor) {
                          items.addAll([
                            const PopupMenuItem(value: 'edit', child: Text('✏️ แก้ไข')),
                            const PopupMenuItem(value: 'delete', child: Text('🗑️ ลบ')),
                          ]);
                        }
                        
                        // Admin actions
                        if (isAdmin) {
                          if (items.isNotEmpty) items.add(const PopupMenuDivider());
                          items.addAll([
                            PopupMenuItem(
                              value: 'pin',
                              child: Text(_thread!.isPinned ? '📌 ยกเลิกปักหมุด' : '📌 ปักหมุด'),
                            ),
                            PopupMenuItem(
                              value: 'lock',
                              child: Text(_thread!.isLocked ? '🔓 ปลดล็อก' : '🔒 ล็อก'),
                            ),
                          ]);
                        }
                        
                        // Report action (for non-author)
                        if (!isAuthor) {
                          if (items.isNotEmpty) items.add(const PopupMenuDivider());
                          items.add(
                            const PopupMenuItem(
                              value: 'report',
                              child: Text('🚨 รายงาน'),
                            ),
                          );
                        }
                        
                        return items;
                      },
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Tags
            if (_thread!.tags.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _thread!.tags.map((tag) => Chip(
                  label: Text(tag),
                  backgroundColor: AppTheme.accentColor.withOpacity(0.2),
                  labelStyle: const TextStyle(fontSize: 13),
                )).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildThreadContent() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Html(
              data: _thread!.content,
              style: {
                "body": Style(
                  fontSize: FontSize(16),
                  lineHeight: const LineHeight(1.6),
                  margin: Margins.zero,
                  padding: HtmlPaddings.zero,
                ),
                "p": Style(margin: Margins.only(bottom: 8)),
                "ul": Style(margin: Margins.only(left: 16, bottom: 8)),
                "ol": Style(margin: Margins.only(left: 16, bottom: 8)),
                "li": Style(margin: Margins.only(bottom: 4)),
              },
            ),
            // Attachments
            if (_thread!.attachments.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'ไฟล์แนบ (${_thread!.attachments.length})',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _thread!.attachments.map((url) => _buildAttachmentChip(url)).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentChip(String url) {
    final fileName = url.split('/').last;
    final isImage = fileName.toLowerCase().endsWith('.jpg') ||
        fileName.toLowerCase().endsWith('.jpeg') ||
        fileName.toLowerCase().endsWith('.png') ||
        fileName.toLowerCase().endsWith('.gif') ||
        fileName.toLowerCase().endsWith('.webp');

    return ActionChip(
      avatar: Icon(isImage ? Icons.image : Icons.attach_file, size: 16),
      label: Text(
        fileName.length > 20 ? '${fileName.substring(0, 20)}...' : fileName,
        style: const TextStyle(fontSize: 12),
      ),
      onPressed: () {
        if (isImage) {
          _showImagePreview(url);
        } else {
          StandardSnackbar.showInfo(context, 'เปิดไฟล์: $fileName');
        }
      },
    );
  }

  void _showImagePreview(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4.0,
              child: Center(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.white),
                        const SizedBox(height: 16),
                        const Text(
                          'ไม่สามารถโหลดรูปภาพได้',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoteSection() {
    final currentVote = _userThreadVotes[widget.threadId];
    
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Upvote
                _buildVoteButton(
                  icon: Icons.thumb_up,
                  count: _thread!.upvoteCount,
                  isActive: currentVote == 'up',
                  onPressed: () => _voteThread('up'),
                  color: AppTheme.successColor,
                ),
                // Views
                Row(
                  children: [
                    const Icon(Icons.visibility, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '${_thread!.viewCount}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                // Replies
                Row(
                  children: [
                    const Icon(Icons.comment, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '${_thread!.replyCount}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                // Downvote
                _buildVoteButton(
                  icon: Icons.thumb_down,
                  count: _thread!.downvoteCount,
                  isActive: currentVote == 'down',
                  onPressed: () => _voteThread('down'),
                  color: AppTheme.errorColor,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Bookmark & Follow buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _toggleBookmark,
                icon: Icon(
                  _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: _isBookmarked ? AppTheme.primaryColor : Colors.grey,
                ),
                label: Text(
                  _isBookmarked ? 'บันทึกแล้ว' : 'บันทึกกระทู้',
                  style: TextStyle(
                    color: _isBookmarked ? AppTheme.primaryColor : Colors.grey[700],
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: _isBookmarked ? AppTheme.primaryColor : Colors.grey,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _toggleFollow,
                icon: Icon(
                  _isFollowing ? Icons.notifications_active : Icons.notifications_none,
                  color: _isFollowing ? AppTheme.primaryColor : Colors.grey,
                ),
                label: Text(
                  _isFollowing ? 'ติดตามแล้ว' : 'ติดตามกระทู้',
                  style: TextStyle(
                    color: _isFollowing ? AppTheme.primaryColor : Colors.grey[700],
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: _isFollowing ? AppTheme.primaryColor : Colors.grey,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Emoji reactions
        EmojiReactionsBar(
          contentType: 'thread',
          contentId: widget.threadId,
        ),
      ],
    );
  }

  Widget _buildVoteButton({
    required IconData icon,
    required int count,
    required bool isActive,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          children: [
            Icon(
              icon,
              color: isActive ? color : Colors.grey,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isActive ? color : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRepliesSection() {
    final repliesToShow = _filteredReplies.isEmpty && _isSearching ? [] : _filteredReplies;
    
    if (_replies.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.comment_outlined, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'ยังไม่มีคำตอบ',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                const Text(
                  'เป็นคนแรกที่ตอบกระทู้นี้',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (repliesToShow.isEmpty && _isSearching) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'ไม่พบคำตอบที่ตรงกับคำค้นหา',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'คำตอบ (${_replies.length})',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (_isSearching && repliesToShow.length != _replies.length)
              Text(
                'แสดง ${repliesToShow.length} จาก ${_replies.length}',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
          ],
        ),
        const SizedBox(height: 12),
        ...repliesToShow.map((reply) => _buildReplyCard(reply)).toList(),
      ],
    );
  }

  Widget _buildReplyCard(ThreadReply reply) {
    final isAuthor = reply.authorId == _thread?.authorId;
    final currentVote = _userReplyVotes[reply.id];
    final authProvider = context.read<AuthProvider>();
    final isThreadOwner = authProvider.currentUser?.id?.toString() == _thread?.authorId;

    return Card(
      margin: EdgeInsets.only(
        bottom: 12,
        left: reply.level > 0 ? 32 : 0, // Indent nested replies
      ),
      color: reply.isAnswer 
          ? AppTheme.successColor.withOpacity(0.1)
          : (reply.level > 0 ? Colors.grey[50] : null),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: reply.authorAvatar != null
                      ? NetworkImage(reply.authorAvatar!)
                      : null,
                  child: reply.authorAvatar == null
                      ? const Icon(Icons.person, size: 18)
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          InkWell(
                            onTap: () {
                              context.push('/user-profile/${reply.authorId}');
                            },
                            child: Text(
                              reply.authorName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                          if (isAuthor) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'เจ้าของกระทู้',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                          if (reply.isAnswer) ...[
                            const SizedBox(width: 6),
                            const Icon(Icons.check_circle, color: Colors.green, size: 16),
                            const SizedBox(width: 2),
                            const Text(
                              'คำตอบที่ดีที่สุด',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                          // Edited badge
                          if (reply.isEdited) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.orange.shade300, width: 0.5),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.edit, size: 10, color: Colors.orange.shade700),
                                  const SizedBox(width: 2),
                                  Text(
                                    'แก้ไขแล้ว',
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: Colors.orange.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        _formatDateTime(reply.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Content
            Html(
              data: reply.content,
              style: {
                "body": Style(
                  fontSize: FontSize(16),
                  lineHeight: const LineHeight(1.6),
                  margin: Margins.zero,
                  padding: HtmlPaddings.zero,
                ),
                "p": Style(margin: Margins.only(bottom: 8)),
                "ul": Style(margin: Margins.only(left: 16, bottom: 8)),
                "ol": Style(margin: Margins.only(left: 16, bottom: 8)),
                "li": Style(margin: Margins.only(bottom: 4)),
              },
            ),
            // Attachments
            if (reply.attachments.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: reply.attachments.map((url) => _buildAttachmentChip(url)).toList(),
              ),
            ],
            const SizedBox(height: 12),
            // Emoji reactions
            EmojiReactionsBar(
              contentType: 'reply',
              contentId: reply.id,
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 8),
            // Actions
            Row(
              children: [
                // Upvote
                InkWell(
                  onTap: () => _voteReply(reply.id, 'up'),
                  child: Row(
                    children: [
                      Icon(
                        Icons.thumb_up,
                        size: 18,
                        color: currentVote == 'up' ? AppTheme.successColor : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${reply.upvoteCount}',
                        style: TextStyle(
                          fontSize: 14,
                          color: currentVote == 'up' ? AppTheme.successColor : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Downvote
                InkWell(
                  onTap: () => _voteReply(reply.id, 'down'),
                  child: Row(
                    children: [
                      Icon(
                        Icons.thumb_down,
                        size: 18,
                        color: currentVote == 'down' ? AppTheme.errorColor : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${reply.downvoteCount}',
                        style: TextStyle(
                          fontSize: 14,
                          color: currentVote == 'down' ? AppTheme.errorColor : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Reply button (only for top-level replies)
                if (reply.level == 0)
                  TextButton.icon(
                    onPressed: () => _setReplyingTo(reply.id, reply.authorName),
                    icon: const Icon(Icons.reply, size: 16),
                    label: const Text('ตอบกลับ', style: TextStyle(fontSize: 14)),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                  ),
                const Spacer(),
                // Edit/Delete/Report buttons
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 18),
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(),
                  tooltip: 'ตัวเลือก',
                  onSelected: (value) => _handleReplyMenuAction(value, reply),
                  itemBuilder: (context) {
                    final isAuthor = authProvider.currentUser?.id?.toString() == reply.authorId;
                    final items = <PopupMenuEntry<String>>[];

                    if (isAuthor) {
                      items.addAll([
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 16),
                              SizedBox(width: 8),
                              Text('แก้ไข'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 16, color: Colors.red),
                              SizedBox(width: 8),
                              Text('ลบ', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ]);
                    }

                    // Report for non-author
                    if (!isAuthor) {
                      if (items.isNotEmpty) items.add(const PopupMenuDivider());
                      items.add(
                        const PopupMenuItem(
                          value: 'report',
                          child: Row(
                            children: [
                              Icon(Icons.report, size: 16, color: Colors.orange),
                              SizedBox(width: 8),
                              Text('รายงาน'),
                            ],
                          ),
                        ),
                      );
                    }

                    return items;
                  },
                ),
                // Accept answer (only thread owner, only top-level, not already answered)
                if (isThreadOwner && reply.level == 0 && !_thread!.hasAcceptedAnswer)
                  TextButton.icon(
                    onPressed: () => _acceptAnswer(reply.id),
                    icon: const Icon(Icons.check_circle_outline, size: 16),
                    label: const Text('เลือกคำตอบนี้', style: TextStyle(fontSize: 13)),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyInput() {
    if (_thread!.isLocked) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.lock, color: Colors.red),
              const SizedBox(width: 12),
              Text(
                'กระทู้นี้ถูกล็อก ไม่สามารถตอบกลับได้',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_replyingToName != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.reply, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'ตอบกลับ: $_replyingToName',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: _cancelReplyingTo,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            TextField(
              controller: _replyController,
              decoration: const InputDecoration(
                hintText: 'เขียนคำตอบของคุณ...',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    _replyController.clear();
                    _cancelReplyingTo();
                  },
                  child: const Text('ยกเลิก'),
                ),
                const SizedBox(width: 8),
                Consumer<WebboardProvider>(
                  builder: (context, provider, child) {
                    return ElevatedButton.icon(
                      onPressed: provider.isLoading ? null : _submitReply,
                      icon: provider.isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(Colors.white),
                              ),
                            )
                          : const Icon(Icons.send, size: 18),
                      label: Text(_replyingToName != null ? 'ตอบกลับ' : 'ส่งคำตอบ'),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(ThreadCategory category) {
    switch (category) {
      case ThreadCategory.cattle:
      case ThreadCategory.buffalo:
        return Colors.brown;
      case ThreadCategory.pig:
        return Colors.pink;
      case ThreadCategory.chicken:
      case ThreadCategory.duck:
        return Colors.orange;
      case ThreadCategory.goat:
      case ThreadCategory.sheep:
        return Colors.grey;
      case ThreadCategory.feed:
        return Colors.green;
      case ThreadCategory.health:
        return Colors.red;
      case ThreadCategory.breeding:
        return Colors.purple;
      case ThreadCategory.disease:
        return Colors.deepOrange;
      case ThreadCategory.marketing:
        return Colors.blue;
      case ThreadCategory.finance:
        return Colors.teal;
      case ThreadCategory.technology:
        return Colors.indigo;
      case ThreadCategory.general:
        return Colors.blueGrey;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'เมื่อสักครู่';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} นาทีที่แล้ว';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} ชั่วโมงที่แล้ว';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} วันที่แล้ว';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
