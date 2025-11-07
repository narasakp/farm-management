import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'dart:html' as html; // สำหรับ browser history
import '../../providers/webboard_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/thread.dart';
import '../../models/thread_reply.dart';
import '../../widgets/app_bars/standard_app_bar.dart';
import '../../widgets/standard_snackbar.dart';
import '../../widgets/mentions_badge.dart';
import '../../widgets/advanced_search_dialog.dart';
import '../../widgets/quill_editor_widget.dart';
import '../../utils/tab_navigation_mixin.dart';
import '../../utils/responsive_helper.dart';
import '../../utils/app_theme.dart';

class WebboardScreen extends StatefulWidget {
  const WebboardScreen({super.key});

  @override
  State<WebboardScreen> createState() => _WebboardScreenState();
}

class _WebboardScreenState extends State<WebboardScreen>
    with TickerProviderStateMixin, TabNavigationMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _searchController = TextEditingController();
  late quill.QuillController _quillController;
  
  ThreadCategory _selectedCategory = ThreadCategory.general;
  List<String> _tags = [];
  List<PlatformFile> _selectedFiles = [];
  List<Thread> _bookmarkedThreads = [];
  bool _isLoadingBookmarks = false;
  List<Thread> _followedThreads = [];
  bool _isLoadingFollowed = false;
  
  ThreadCategory? _filterCategory;
  ThreadStatus? _filterStatus;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _quillController = quill.QuillController.basic();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadThreads();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _searchController.dispose();
    _quillController.dispose();
    super.dispose();
  }

  Future<void> _loadThreads() async {
    final provider = context.read<WebboardProvider>();
    await provider.loadThreads(
      category: _filterCategory,
      status: _filterStatus,
      search: _searchQuery.isEmpty ? null : _searchQuery,
    );
  }

  Future<void> _loadBookmarkedThreads() async {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.currentUser?.id?.toString();
    
    if (userId == null) {
      setState(() {
        _bookmarkedThreads = [];
        _isLoadingBookmarks = false;
      });
      return;
    }

    setState(() => _isLoadingBookmarks = true);
    final provider = context.read<WebboardProvider>();
    final threads = await provider.getBookmarkedThreads(userId);
    
    if (mounted) {
      setState(() {
        _bookmarkedThreads = threads;
        _isLoadingBookmarks = false;
      });
    }
  }

  Future<void> _loadFollowedThreads() async {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.currentUser?.id?.toString();
    
    if (userId == null) {
      setState(() {
        _followedThreads = [];
        _isLoadingFollowed = false;
      });
      return;
    }

    setState(() => _isLoadingFollowed = true);
    final provider = context.read<WebboardProvider>();
    final threads = await provider.getFollowedThreads(userId);
    
    if (mounted) {
      setState(() {
        _followedThreads = threads;
        _isLoadingFollowed = false;
      });
    }
  }

  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'webp', 'gif', 'svg', 'pdf', 'doc', 'docx', 'xls', 'xlsx', 'txt', 'zip'],
      );

      if (result != null) {
        setState(() {
          _selectedFiles = result.files;
        });
      }
    } catch (e) {
      print('Error picking files: $e');
    }
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  Future<void> _submitThread() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate Quill content
    if (QuillToHtmlConverter.isEmpty(_quillController)) {
      if (mounted) {
        StandardSnackbar.showError(context, 'กรุณากรอกเนื้อหากระทู้');
      }
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final webboardProvider = context.read<WebboardProvider>();

    // Convert Quill content to HTML
    final htmlContent = QuillToHtmlConverter.toHtml(_quillController);

    final result = await webboardProvider.createThread(
      title: _titleController.text.trim(),
      content: htmlContent,
      category: _selectedCategory,
      tags: _tags,
      authorId: authProvider.currentUser?.id?.toString() ?? 'anonymous',
      authorName: authProvider.currentUser?.fullName ?? 'ผู้ใช้ไม่ระบุชื่อ',
      authorAvatar: authProvider.currentUser?.avatarUrl,
      files: _selectedFiles.isNotEmpty ? _selectedFiles : null,
    );

    if (result['success'] == true) {
      if (mounted) {
        StandardSnackbar.showSuccess(
          context,
          'สร้างกระทู้สำเร็จ',
        );
        
        // Clear form
        _titleController.clear();
        _quillController.clear();
        setState(() {
          _selectedCategory = ThreadCategory.general;
          _tags = [];
          _selectedFiles = [];
        });
        
        // Switch to thread list tab
        _tabController.animateTo(0);
      }
    } else {
      if (mounted) {
        StandardSnackbar.showError(
          context,
          result['message'] ?? 'เกิดข้อผิดพลาด',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StandardAppBar(
        type: AppBarType.main,
        title: 'กระทู้ ถาม - ตอบ',
        onBackPressed: () {
          // ✅ ใช้ browser history.back() เพื่อกลับหน้าก่อนหน้าจริงๆ
          html.window.history.back();
        },
        customActions: [
          // Mentions Badge
          Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              final user = authProvider.currentUser;
              if (user != null) {
                return MentionsBadge(userId: user.id.toString());
              }
              return const SizedBox.shrink();
            },
          ),
          IconButton(
            icon: const Icon(Icons.manage_search),
            onPressed: () async {
              final result = await showDialog(
                context: context,
                builder: (context) => const AdvancedSearchDialog(),
              );
              if (result != null && result is Thread) {
                // Navigate to thread
                context.push('/thread/${result.id}');
              }
            },
            tooltip: 'ค้นหาขั้นสูง',
          ),
          IconButton(
            icon: const Icon(Icons.timeline),
            onPressed: () => context.push('/activity-feed'),
            tooltip: 'กิจกรรมล่าสุด',
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () => context.push('/webboard-stats'),
            tooltip: 'สถิติกระทู้',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: const Color.fromRGBO(255, 255, 255, 0.7), // ขาวจาง 70% contrast กับพื้นเขียว
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 16,
          ),
          onTap: (index) {
            if (index == 2) {
              _loadBookmarkedThreads();
            } else if (index == 3) {
              _loadFollowedThreads();
            }
          },
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.forum, size: 20),
                  SizedBox(width: 8),
                  Text('ดูกระทู้'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.add_circle_outline, size: 20),
                  SizedBox(width: 8),
                  Text('สร้างกระทู้'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.bookmark, size: 20),
                  SizedBox(width: 8),
                  Text('กระทู้ที่บันทึก'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.notifications_active, size: 20),
                  SizedBox(width: 8),
                  Text('กระทู้ที่ติดตาม'),
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildThreadList(),
          _buildCreateThread(),
          _buildBookmarkedList(),
          _buildFollowedList(),
        ],
      ),
    );
  }

  Widget _buildThreadList() {
    return Consumer<WebboardProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.threads.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            // Search & Filter Bar
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey[100],
              child: Column(
                children: [
                  // Search
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'ค้นหากระทู้...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                      _loadThreads();
                    },
                  ),
                  const SizedBox(height: 12),
                  // Filters
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // Category Filter
                        FilterChip(
                          label: Text(_filterCategory?.toString().split('.').last.toUpperCase() ?? 'หมวดหมู่'),
                          selected: _filterCategory != null,
                          onSelected: (selected) {
                            _showCategoryFilter();
                          },
                        ),
                        const SizedBox(width: 8),
                        // Status Filter
                        FilterChip(
                          label: Text(_filterStatus != null ? _getStatusText(_filterStatus!) : 'สถานะ'),
                          selected: _filterStatus != null,
                          onSelected: (selected) {
                            _showStatusFilter();
                          },
                        ),
                        const SizedBox(width: 8),
                        // Clear Filters
                        if (_filterCategory != null || _filterStatus != null)
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _filterCategory = null;
                                _filterStatus = null;
                              });
                              _loadThreads();
                            },
                            icon: const Icon(Icons.clear),
                            label: const Text('ล้างตัวกรอง'),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Thread List
            Expanded(
              child: provider.threads.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.forum_outlined, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'ยังไม่มีกระทู้',
                            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () => _tabController.animateTo(1),
                            child: const Text('สร้างกระทู้แรก'),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadThreads,
                      child: ListView.builder(
                        itemCount: provider.threads.length,
                        padding: const EdgeInsets.all(16),
                        itemBuilder: (context, index) {
                          final thread = provider.threads[index];
                          return _buildThreadCard(thread);
                        },
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildThreadCard(Thread thread) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          context.push('/webboard/${thread.id}');
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: thread.authorAvatar != null
                        ? NetworkImage(thread.authorAvatar!)
                        : null,
                    child: thread.authorAvatar == null
                        ? const Icon(Icons.person, size: 16)
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          thread.authorName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          _formatDateTime(thread.createdAt),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Category Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(thread.category),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      thread.categoryText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Title
              Text(
                thread.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              // Content Preview
              Text(
                thread.content,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              // Tags
              if (thread.tags.isNotEmpty)
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: thread.tags.map((tag) => Chip(
                    label: Text(tag),
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  )).toList(),
                ),
              const SizedBox(height: 12),
              // Stats
              Row(
                children: [
                  Icon(Icons.visibility, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${thread.viewCount}',
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.comment, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${thread.replyCount}',
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.thumb_up, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${thread.upvoteCount}',
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                  const Spacer(),
                  // Status Badge
                  if (thread.isPinned)
                    const Icon(Icons.push_pin, size: 16, color: Colors.orange),
                  if (thread.isLocked)
                    const Icon(Icons.lock, size: 16, color: Colors.red),
                  if (thread.hasAcceptedAnswer)
                    const Icon(Icons.check_circle, size: 16, color: Colors.green),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreateThread() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'หัวข้อกระทู้',
                border: OutlineInputBorder(),
                hintText: 'ระบุหัวข้อกระทู้ที่ต้องการถาม',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'กรุณากรอกหัวข้อกระทู้';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Category
            DropdownButtonFormField<ThreadCategory>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'หมวดหมู่',
                border: OutlineInputBorder(),
              ),
              items: ThreadCategory.values.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(_getCategoryText(category)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCategory = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            // Content (Rich Text Editor with Quill)
            const Text(
              'เนื้อหากระทู้',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Container(
              height: 450,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: QuillEditorWidget(
                controller: _quillController,
                hint: 'เขียนเนื้อหากระทู้ของคุณ... (รองรับ Rich Text Formatting)',
                height: 400,
              ),
            ),
            const SizedBox(height: 16),
            // Files
            OutlinedButton.icon(
              onPressed: _pickFiles,
              icon: const Icon(Icons.attach_file),
              label: const Text('แนบไฟล์ (ถ้ามี)'),
            ),
            if (_selectedFiles.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _selectedFiles.asMap().entries.map((entry) {
                  final index = entry.key;
                  final file = entry.value;
                  return Chip(
                    label: Text(file.name),
                    onDeleted: () => _removeFile(index),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 24),
            // Submit Button
            SizedBox(
              width: double.infinity,
              child: Consumer<WebboardProvider>(
                builder: (context, provider, child) {
                  return ElevatedButton(
                    onPressed: provider.isLoading ? null : _submitThread,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: provider.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('สร้างกระทู้', style: TextStyle(fontSize: 16)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryFilter() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('เลือกหมวดหมู่'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('ทั้งหมด'),
                onTap: () {
                  setState(() {
                    _filterCategory = null;
                  });
                  Navigator.pop(context);
                  _loadThreads();
                },
              ),
              ...ThreadCategory.values.map((category) {
                return ListTile(
                  title: Text(_getCategoryText(category)),
                  selected: _filterCategory == category,
                  onTap: () {
                    setState(() {
                      _filterCategory = category;
                    });
                    Navigator.pop(context);
                    _loadThreads();
                  },
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  void _showStatusFilter() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('เลือกสถานะ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('ทั้งหมด'),
              onTap: () {
                setState(() {
                  _filterStatus = null;
                });
                Navigator.pop(context);
                _loadThreads();
              },
            ),
            ...ThreadStatus.values.map((status) {
              return ListTile(
                title: Text(_getStatusText(status)),
                selected: _filterStatus == status,
                onTap: () {
                  setState(() {
                    _filterStatus = status;
                  });
                  Navigator.pop(context);
                  _loadThreads();
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  String _getCategoryText(ThreadCategory category) {
    switch (category) {
      case ThreadCategory.cattle:
        return 'โคเนื้อ';
      case ThreadCategory.buffalo:
        return 'กระบือ';
      case ThreadCategory.pig:
        return 'สุกร';
      case ThreadCategory.chicken:
        return 'ไก่';
      case ThreadCategory.duck:
        return 'เป็ด';
      case ThreadCategory.goat:
        return 'แพะ';
      case ThreadCategory.sheep:
        return 'แกะ';
      case ThreadCategory.feed:
        return 'อาหารสัตว์';
      case ThreadCategory.health:
        return 'สุขภาพสัตว์';
      case ThreadCategory.breeding:
        return 'การผสมพันธุ์';
      case ThreadCategory.disease:
        return 'โรคระบาด';
      case ThreadCategory.marketing:
        return 'การตลาด';
      case ThreadCategory.finance:
        return 'การเงิน';
      case ThreadCategory.technology:
        return 'เทคโนโลยี';
      case ThreadCategory.general:
        return 'ทั่วไป';
    }
  }

  String _getStatusText(ThreadStatus status) {
    switch (status) {
      case ThreadStatus.open:
        return 'เปิด';
      case ThreadStatus.answered:
        return 'มีคำตอบแล้ว';
      case ThreadStatus.solved:
        return 'แก้ไขแล้ว';
      case ThreadStatus.closed:
        return 'ปิด';
    }
  }

  Widget _buildBookmarkedList() {
    if (_isLoadingBookmarks) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_bookmarkedThreads.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_border, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'ยังไม่มีกระทู้ที่บันทึกไว้',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            const Text(
              'กดไอคอน bookmark ในกระทู้ที่สนใจ',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBookmarkedThreads,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _bookmarkedThreads.length,
        itemBuilder: (context, index) {
          final thread = _bookmarkedThreads[index];
          return _buildThreadCard(thread);
        },
      ),
    );
  }

  Widget _buildFollowedList() {
    if (_isLoadingFollowed) {
      return const Center(child: CircularProgressIndicator());
    }

    final authProvider = context.read<AuthProvider>();
    if (authProvider.currentUser == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'กรุณาเข้าสู่ระบบ',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            const Text(
              'เพื่อดูกระทู้ที่ติดตาม',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (_followedThreads.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'ยังไม่มีกระทู้ที่ติดตาม',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            const Text(
              'กดไอคอน 🔔 ในกระทู้ที่สนใจเพื่อรับการแจ้งเตือน',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFollowedThreads,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _followedThreads.length,
        itemBuilder: (context, index) {
          final thread = _followedThreads[index];
          return _buildThreadCard(thread);
        },
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
