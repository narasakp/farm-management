import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import '../../providers/feedback_provider.dart';
import '../../providers/feedback_replies_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/feedback.dart' as FeedbackModel;
import '../../models/feedback_reply.dart';
import '../../widgets/app_bars/standard_app_bar.dart';
import '../../widgets/standard_snackbar.dart';
import '../../utils/tab_navigation_mixin.dart';
import '../../utils/responsive_helper.dart';
import '../../config/api_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../admin/audit_dashboard_screen.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

// 🆕 Sort Options Enum
enum SortOption {
  newest('ล่าสุด', Icons.schedule),
  oldest('เก่าที่สุด', Icons.history),
  highestRating('ดาวสูงสุด', Icons.star),
  mostReplies('ตอบกลับมากสุด', Icons.forum),
  mostUpvotes('คะแนนสูงสุด', Icons.thumb_up);

  final String label;
  final IconData icon;
  const SortOption(this.label, this.icon);
}

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen>
    with TickerProviderStateMixin, TabNavigationMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _searchController = TextEditingController();
  
  // Scroll controller for auto-scroll to error
  final _scrollController = ScrollController();
  
  // Focus nodes for fields
  final _emailFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();
  final _subjectFocusNode = FocusNode();
  final _messageFocusNode = FocusNode();

  // Form values
  FeedbackModel.FeedbackType _selectedType =
      FeedbackModel.FeedbackType.suggestion;
  FeedbackModel.FeedbackCategory _selectedCategory =
      FeedbackModel.FeedbackCategory.ui;
  FeedbackModel.FeedbackPriority _selectedPriority =
      FeedbackModel.FeedbackPriority.medium;
  int _rating = 5;
  List<String> _attachedFiles = [];
  List<PlatformFile> _selectedFiles = [];

  // Filter values
  FeedbackModel.FeedbackType? _filterType;
  FeedbackModel.FeedbackStatus? _filterStatus;
  FeedbackModel.FeedbackCategory? _filterCategory;
  String _searchQuery = '';
  
  // 🆕 Advanced Filter & Sort
  SortOption _sortOption = SortOption.newest;
  DateTime? _filterDateFrom;
  DateTime? _filterDateTo;
  
  bool _isTabControllerInitialized = false;
  bool? _previousAuthState;
  String? _previousUserRole;

  // Expanded feedback items (show/hide details)
  final Set<String> _expandedFeedbacks = {};
  
  // Active reply inputs (feedback id -> TextEditingController)
  final Map<String, TextEditingController> _replyControllers = {};
  final Set<String> _activeReplyInputs = {};
  
  // Hidden items refresh counter
  int _hiddenItemsRefreshKey = 0;

  @override
  void initState() {
    super.initState();
    // TabController length จะถูกกำหนดใน didChangeDependencies
    // เพื่อให้ได้ auth status ก่อน

    // Initialize feedback provider และโหลดข้อมูลจาก API
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FeedbackProvider>().initialize();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final authProvider = context.read<AuthProvider>();
    final isAuthenticated = authProvider.isLoggedIn;

    // เช็คว่าเป็น admin หรือ super_admin
    final userRole = authProvider.currentUser?.role?.toUpperCase();
    final isAdmin = userRole == 'ADMIN' || userRole == 'SUPER_ADMIN';

    // Initialize หรือ reinitialize TabController เมื่อ auth status หรือ role เปลี่ยน
    if (!_isTabControllerInitialized || 
        _previousAuthState != isAuthenticated ||
        _previousUserRole != userRole) {
      // Dispose old controller ถ้ามี
      if (_isTabControllerInitialized) {
        disposeTabNavigation();
        _tabController.dispose();
      }

      // Guest: 1 tab, Admin: 5 tabs, User: 3 tabs
      final tabLength = !isAuthenticated ? 1 : (isAdmin ? 5 : 3);
      _tabController = TabController(length: tabLength, vsync: this);

      // ⚠️ Security: Guest → fallback to '/', User → fallback to '/dashboard'
      final fallbackRoute = isAuthenticated ? '/dashboard' : '/';
      initTabNavigation(_tabController,
          initialTab: 0, fallbackRoute: fallbackRoute);

      _isTabControllerInitialized = true;
      _previousAuthState = isAuthenticated;
      _previousUserRole = userRole;
    }
  }

  @override
  void dispose() {
    disposeTabNavigation();
    _tabController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    _emailFocusNode.dispose();
    _phoneFocusNode.dispose();
    _subjectFocusNode.dispose();
    _messageFocusNode.dispose();
    // Dispose reply controllers
    for (var controller in _replyControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ตรวจสอบ auth status
    final authProvider = context.watch<AuthProvider>();
    final isAuthenticated = authProvider.isLoggedIn;
    
    // เช็คว่าเป็น admin หรือ super_admin (สำหรับแสดงแท็บจัดการและประวัติ)
    final userRole = authProvider.currentUser?.role?.toUpperCase();
    final isAdmin = userRole == 'ADMIN' || userRole == 'SUPER_ADMIN';

    // กำหนด tabs ตาม auth status และ role
    List<Tab> tabs;
    if (!isAuthenticated) {
      tabs = const [
        Tab(icon: Icon(Icons.feedback), text: 'ส่งข้อเสนอแนะ'),
      ];
    } else if (isAdmin) {
      tabs = const [
        Tab(icon: Icon(Icons.feedback), text: 'ส่งข้อเสนอแนะ'),
        Tab(icon: Icon(Icons.admin_panel_settings), text: 'จัดการ'),
        Tab(icon: Icon(Icons.track_changes), text: 'ติดตาม'),
        Tab(icon: Icon(Icons.history), text: 'ประวัติ'),
        Tab(icon: Icon(Icons.visibility_off), text: 'ซ่อนไว้'),
        Tab(icon: Icon(Icons.analytics), text: 'สถิติ'),
      ];
    } else {
      tabs = const [
        Tab(icon: Icon(Icons.feedback), text: 'ส่งข้อเสนอแนะ'),
        Tab(icon: Icon(Icons.track_changes), text: 'ติดตาม'),
        Tab(icon: Icon(Icons.analytics), text: 'สถิติและวิเคราะห์'),
      ];
    }

    // กำหนด tab views ตาม auth status และ role
    List<Widget> tabViews;
    if (!isAuthenticated) {
      tabViews = [
        _buildFeedbackForm(),
      ];
    } else if (isAdmin) {
      tabViews = [
        _buildFeedbackForm(),
        _buildAdminManagement(),    // แท็บจัดการ (pending only)
        _buildFeedbackHistory(),     // แท็บติดตาม (own feedback)
        _buildAdminHistory(),        // แท็บประวัติ (approved/rejected)
        _buildHiddenItems(),         // แท็บที่ซ่อนไว้ (soft deleted)
        _buildAnalyticsDashboard(),
      ];
    } else {
      tabViews = [
        _buildFeedbackForm(),
        _buildFeedbackHistory(),
        _buildAnalyticsDashboard(),
      ];
    }

    return Scaffold(
      appBar: _isTabControllerInitialized
          ? StandardAppBar(
              type: AppBarType.main, // ชั้นที่ 1
              title: 'ข้อเสนอแนะและความคิดเห็น',
              onBackPressed: handleSmartBackPress,
              showSearch: false, // ไม่มี search icon
              customActions: [
                // Audit Dashboard button (SUPER_ADMIN/ADMIN only)
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    if (authProvider.currentUser?.canManageFeedback ?? false) {
                      return IconButton(
                        icon: const Icon(Icons.security, color: Colors.white),
                        tooltip: 'Audit Dashboard',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AuditDashboardScreen(),
                            ),
                          );
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
              bottom: TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white.withOpacity(0.7),
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                tabs: tabs,
              ),
            )
          : null,
      body: _isTabControllerInitialized
          ? TabBarView(
              controller: _tabController,
              children: tabViews,
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildFeedbackForm() {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: EdgeInsets.all(ResponsiveHelper.getCardSpacing(context)),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF228B22).withOpacity(0.1),
                      Colors.white,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Color(0xFF228B22),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.feedback_outlined,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'เราต้องการรับฟังความคิดเห็นจากคุณ',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: Color(0xFF228B22),
                                  fontWeight: FontWeight.bold,
                                ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'ข้อเสนอแนะของคุณจะช่วยให้เราปรับปรุงระบบให้ดียิ่งขึ้น',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Color(0xFF8B4513),
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Feedback Type
            Row(
              children: [
                Icon(Icons.category, color: Color(0xFF228B22), size: 20),
                const SizedBox(width: 8),
                Text(
                  'ประเภทข้อเสนอแนะ',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Color(0xFF228B22),
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: FeedbackModel.FeedbackType.values.map((type) {
                    return RadioListTile<FeedbackModel.FeedbackType>(
                      title: Text(
                        _getFeedbackTypeText(type),
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        _getFeedbackTypeDescription(type),
                        style: TextStyle(color: Color(0xFF8B4513)),
                      ),
                      value: type,
                      groupValue: _selectedType,
                      activeColor: Color(0xFF228B22),
                      onChanged: (value) {
                        setState(() {
                          _selectedType = value!;
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Category
            DropdownButtonFormField<FeedbackModel.FeedbackCategory>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'เลือกหมวดหมู่',
                border: OutlineInputBorder(),
              ),
              items: FeedbackModel.FeedbackCategory.values.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(_getFeedbackCategoryText(category)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),

            // Contact Info (แสดงเฉพาะผู้ที่ไม่ได้ login)
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                final isLoggedIn = authProvider.currentUser != null;
                
                // ถ้า login แล้ว ไม่แสดงข้อมูลติดต่อเลย
                if (isLoggedIn) {
                  return const SizedBox(height: 24);
                }
                
                // ถ้ายังไม่ login แสดงฟอร์มข้อมูลติดต่อ (บังคับกรอก)
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _emailController,
                            focusNode: _emailFocusNode,
                            decoration: const InputDecoration(
                              labelText: 'อีเมล *',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.email),
                              helperText: 'กรุณากรอกอีเมลเพื่อติดต่อกลับ',
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              // บังคับกรอกสำหรับผู้เยี่ยมชม (guest)
                              if (value == null || value.isEmpty) {
                                return 'กรุณากรอกอีเมล';
                              }
                              
                              final email = value.trim();
                              
                              // ต้องมี @ เพียงตัวเดียว
                              if (!email.contains('@') || email.indexOf('@') != email.lastIndexOf('@')) {
                                return 'รูปแบบอีเมลไม่ถูกต้อง (ต้องมี @ เพียงตัวเดียว)';
                              }
                              
                              // แยก local และ domain
                              final parts = email.split('@');
                              if (parts.length != 2) {
                                return 'รูปแบบอีเมลไม่ถูกต้อง';
                              }
                              
                              final local = parts[0];
                              final domain = parts[1];
                              
                              // Local part ต้องไม่ว่าง
                              if (local.isEmpty) {
                                return 'กรุณาระบุชื่ออีเมลก่อน @';
                              }
                              
                              // Domain ต้องมี . และมีอักษรหลัง .
                              if (!domain.contains('.')) {
                                return 'รูปแบบอีเมลไม่ถูกต้อง (ต้องมี . หลัง @)\nตัวอย่าง: name@domain.com';
                              }
                              
                              final domainParts = domain.split('.');
                              if (domainParts.length < 2) {
                                return 'รูปแบบอีเมลไม่ถูกต้อง';
                              }
                              
                              // ตรวจสอบว่าแต่ละส่วนของ domain ไม่ว่าง
                              for (var part in domainParts) {
                                if (part.isEmpty) {
                                  return 'รูปแบบอีเมลไม่ถูกต้อง';
                                }
                              }
                              
                              // ตรวจสอบ extension (ส่วนหลัง . สุดท้าย)
                              final extension = domainParts.last;
                              if (extension.length < 2 || !RegExp(r'^[a-zA-Z]+$').hasMatch(extension)) {
                                return 'รูปแบบอีเมลไม่ถูกต้อง (extension ต้องเป็นอักษรอย่างน้อย 2 ตัว)';
                              }
                              
                              // Final regex check
                              final emailRegex = RegExp(
                                r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
                              );
                              if (!emailRegex.hasMatch(email)) {
                                return 'รูปแบบอีเมลไม่ถูกต้อง';
                              }
                              
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _phoneController,
                            focusNode: _phoneFocusNode,
                            decoration: const InputDecoration(
                              labelText: 'เบอร์โทรศัพท์ *',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.phone),
                              helperText: 'กรุณากรอกเบอร์โทรศัพท์เพื่อติดต่อกลับ',
                            ),
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              // บังคับกรอกสำหรับผู้เยี่ยมชม (guest)
                              if (value == null || value.isEmpty) {
                                return 'กรุณากรอกเบอร์โทรศัพท์';
                              }
                              
                              // ลบขีด/เว้นวรรค/วงเล็บ
                              final cleanPhone = value.trim().replaceAll(RegExp(r'[\s\-().]'), '');
                              
                              // Thai phone patterns:
                              // มือถือ: 06x, 08x, 09x (10 หลัก)
                              final mobileRegex = RegExp(r'^0[689]\d{8}$');
                              // กรุงเทพ: 02 (9 หลัก)
                              final bkkRegex = RegExp(r'^02\d{7}$');
                              // ต่างจังหวัด: 03x-07x (9 หลัก)
                              final provinceRegex = RegExp(r'^0[3-7]\d{7}$');
                              
                              if (!mobileRegex.hasMatch(cleanPhone) && 
                                  !bkkRegex.hasMatch(cleanPhone) && 
                                  !provinceRegex.hasMatch(cleanPhone)) {
                                return 'รูปแบบเบอร์โทรไม่ถูกต้อง\n• มือถือ: 06x, 08x, 09x (10 หลัก)\n• บ้าน: 02-07x (9 หลัก)';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                );
              },
            ),

            // Subject
            TextFormField(
              controller: _subjectController,
              focusNode: _subjectFocusNode,
              decoration: InputDecoration(
                labelText: 'เรื่องที่เสนอแนะ',
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'กรุณากรอกหัวข้อ';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Message
            Row(
              children: [
                Icon(Icons.message, color: Color(0xFF8B4513), size: 20),
                const SizedBox(width: 8),
                Text(
                  'รายละเอียด',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Color(0xFF228B22),
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _messageController,
              focusNode: _messageFocusNode,
              decoration: const InputDecoration(
                labelText: 'รายละเอียดข้อเสนอแนะ',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.message),
                alignLabelWithHint: true,
              ),
              maxLines: 5,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'กรุณากรอกรายละเอียด';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // File Attachments Section
            Row(
              children: [
                Icon(Icons.attach_file, color: Color(0xFF8B4513), size: 20),
                const SizedBox(width: 8),
                Text(
                  'แนบไฟล์ (ถ้ามี)',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Color(0xFF228B22),
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // File Picker Button
            OutlinedButton.icon(
              onPressed: _pickFiles,
              icon: const Icon(Icons.cloud_upload),
              label: const Text('เลือกไฟล์'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                side: const BorderSide(color: Color(0xFF228B22)),
                foregroundColor: Color(0xFF228B22),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Supported file types info
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'รองรับ: รูปภาพ (JPG, PNG, WEBP, GIF, SVG), เอกสาร (PDF, DOC, XLS), และไฟล์อื่นๆ (TXT, ZIP) • สูงสุด 10 ไฟล์',
                        style: TextStyle(color: Colors.blue[900], fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Selected files list
            if (_selectedFiles.isNotEmpty) ...[
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.description, size: 20, color: Color(0xFF228B22)),
                          const SizedBox(width: 8),
                          Text(
                            'ไฟล์ที่เลือก (${_selectedFiles.length})',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      ..._selectedFiles.asMap().entries.map((entry) {
                        final index = entry.key;
                        final file = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Icon(
                                _getFileIcon(file.extension ?? ''),
                                size: 20,
                                color: Color(0xFF8B4513),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      file.name,
                                      style: const TextStyle(fontSize: 13),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      _formatFileSize(file.size),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, size: 20),
                                onPressed: () => _removeFile(index),
                                tooltip: 'ลบไฟล์',
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Priority
            Row(
              children: [
                Icon(Icons.priority_high, color: Color(0xFFDAA520), size: 20),
                const SizedBox(width: 8),
                Text(
                  'ระดับความสำคัญ',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Color(0xFF228B22),
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<FeedbackModel.FeedbackPriority>(
              value: _selectedPriority,
              decoration: const InputDecoration(
                labelText: 'เลือกระดับความสำคัญ',
                border: OutlineInputBorder(),
              ),
              items: FeedbackModel.FeedbackPriority.values.map((priority) {
                return DropdownMenuItem(
                  value: priority,
                  child: Text(_getPriorityText(priority)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPriority = value!;
                });
              },
            ),

            const SizedBox(height: 24),

            // Rating
            Row(
              children: [
                Icon(Icons.star, color: Color(0xFFDAA520), size: 20),
                const SizedBox(width: 8),
                Text(
                  'คะแนนความพึงพอใจ',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Color(0xFF228B22),
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ให้คะแนนความพึงพอใจต่อระบบ',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            index < _rating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 40,
                          ),
                          onPressed: () {
                            setState(() {
                              _rating = index + 1;
                            });
                          },
                        );
                      }),
                    ),
                    Text(
                      '$_rating ดาว',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: Consumer<FeedbackProvider>(
                builder: (context, feedbackProvider, child) {
                  return ElevatedButton.icon(
                    onPressed:
                        feedbackProvider.isLoading ? null : _submitFeedback,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF228B22),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                    icon: feedbackProvider.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.send),
                    label: Text(
                      'ส่งข้อเสนอแนะ',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackHistory() {
    return Consumer<FeedbackProvider>(
      builder: (context, feedbackProvider, child) {
        // แสดง feedback ที่อนุมัติแล้วและกำลังดำเนินการ (approved, inProgress, completed)
        // ไม่แสดง: pending (อยู่ที่แท็บ "จัดการ"), rejected, closed (อยู่ที่แท็บ "ประวัติ")
        var feedbacks = feedbackProvider.feedbacks
            .where((f) => 
                f.status != FeedbackModel.FeedbackStatus.pending &&
                f.status != FeedbackModel.FeedbackStatus.rejected &&
                f.status != FeedbackModel.FeedbackStatus.closed)
            .toList();
        
        print('📋 [FeedbackHistory] Total feedbacks: ${feedbacks.length}');
        for (var f in feedbacks) {
          print('  - ${f.subject}: status=${f.status.name}, attachments=${f.attachments.length}');
        }

        // Apply filters
        if (_filterType != null) {
          feedbacks = feedbacks.where((f) => f.type == _filterType).toList();
        }
        if (_filterStatus != null) {
          feedbacks =
              feedbacks.where((f) => f.status == _filterStatus).toList();
        }
        if (_filterCategory != null) {
          feedbacks =
              feedbacks.where((f) => f.category == _filterCategory).toList();
        }
        if (_searchQuery.isNotEmpty) {
          feedbacks = feedbacks
              .where((f) =>
                  f.subject
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase()) ||
                  f.message
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase()) ||
                  f.userName.toLowerCase().contains(_searchQuery.toLowerCase()))
              .toList();
        }
        
        // 🆕 Date Range Filter
        if (_filterDateFrom != null) {
          feedbacks = feedbacks.where((f) {
            final feedbackDate = f.createdAt;
            return feedbackDate.isAfter(_filterDateFrom!) || 
                   feedbackDate.isAtSameMomentAs(_filterDateFrom!);
          }).toList();
        }
        if (_filterDateTo != null) {
          feedbacks = feedbacks.where((f) {
            final feedbackDate = f.createdAt;
            final endOfDay = DateTime(_filterDateTo!.year, _filterDateTo!.month, _filterDateTo!.day, 23, 59, 59);
            return feedbackDate.isBefore(endOfDay) || 
                   feedbackDate.isAtSameMomentAs(endOfDay);
          }).toList();
        }
        
        // 🆕 Sort Logic
        switch (_sortOption) {
          case SortOption.newest:
            feedbacks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            break;
          case SortOption.oldest:
            feedbacks.sort((a, b) => a.createdAt.compareTo(b.createdAt));
            break;
          case SortOption.highestRating:
            feedbacks.sort((a, b) => b.rating.compareTo(a.rating));
            break;
          case SortOption.mostReplies:
            feedbacks.sort((a, b) => b.replyCount.compareTo(a.replyCount));
            break;
          case SortOption.mostUpvotes:
            feedbacks.sort((a, b) => b.votes.compareTo(a.votes));
            break;
        }

        return Column(
          children: [
            // Search and Filter Bar
            Padding(
              padding: EdgeInsets.all(ResponsiveHelper.getCardSpacing(context)),
              child: Column(
                children: [
                  // Search Bar
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'ค้นหาข้อเสนอแนะ',
                      prefixIcon: const Icon(Icons.search),
                      border: const OutlineInputBorder(),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // 🆕 Advanced Search Controls Row
                  Row(
                    children: [
                      // Sort Dropdown
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: Icon(_sortOption.icon, size: 18),
                          label: Text(_sortOption.label),
                          onPressed: _showSortOptions,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Date Range Button
                      OutlinedButton.icon(
                        icon: const Icon(Icons.date_range, size: 18),
                        label: Text(
                          _filterDateFrom != null || _filterDateTo != null
                              ? 'วันที่ ✓'
                              : 'วันที่',
                        ),
                        onPressed: _showDateRangeFilter,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          backgroundColor: _filterDateFrom != null || _filterDateTo != null
                              ? Colors.blue.withOpacity(0.1)
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FilterChip(
                          label: Text(_filterType?.toString().split('.').last ??
                              'ประเภท'),
                          selected: _filterType != null,
                          onSelected: (selected) {
                            _showTypeFilter();
                          },
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: Text(
                              _filterStatus?.toString().split('.').last ??
                                  'สถานะ'),
                          selected: _filterStatus != null,
                          onSelected: (selected) {
                            _showStatusFilter();
                          },
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: Text(
                              _filterCategory?.toString().split('.').last ??
                                  'หมวดหมู่'),
                          selected: _filterCategory != null,
                          onSelected: (selected) {
                            _showCategoryFilter();
                          },
                        ),
                        const SizedBox(width: 8),
                        if (_filterType != null ||
                            _filterStatus != null ||
                            _filterCategory != null ||
                            _filterDateFrom != null ||
                            _filterDateTo != null)
                          ActionChip(
                            avatar: const Icon(Icons.clear, size: 18),
                            label: const Text('ล้างตัวกรอง'),
                            onPressed: () {
                              setState(() {
                                _filterType = null;
                                _filterStatus = null;
                                _filterCategory = null;
                                _filterDateFrom = null;
                                _filterDateTo = null;
                              });
                            },
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Results
            Expanded(
              child: feedbacks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isNotEmpty ||
                                    _filterType != null ||
                                    _filterStatus != null ||
                                    _filterCategory != null
                                ? 'ไม่พบข้อเสนอแนะที่ตรงกับเงื่อนไข'
                                : 'ยังไม่มีประวัติข้อเสนอแนะ',
                            style: Theme.of(context).textTheme.titleLarge,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveHelper.getCardSpacing(context)),
                      itemCount: feedbacks.length,
                      itemBuilder: (context, index) {
                        final feedback = feedbacks[index];
                        final isExpanded =
                            _expandedFeedbacks.contains(feedback.id);

                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header (Always visible) - Clickable for expand/collapse
                                Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F5E9), // Soft Green - สีเขียวอ่อน
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(8),
                                    hoverColor: Colors.grey[200], // สีเทาเมื่อ hover
                                    onTap: () async {
                                      setState(() {
                                        if (isExpanded) {
                                          _expandedFeedbacks.remove(feedback.id);
                                        } else {
                                          _expandedFeedbacks.add(feedback.id);
                                          // โหลด replies เมื่อ expand
                                          context
                                              .read<FeedbackRepliesProvider>()
                                              .loadReplies(feedback.id);
                                          // นับ views
                                          context
                                              .read<FeedbackProvider>()
                                              .incrementViews(feedback.id);
                                        }
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Row(
                                              children: [
                                                Icon(
                                                  isExpanded
                                                      ? Icons.expand_less
                                                      : Icons.expand_more,
                                                  color: const Color(0xFF228B22),
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        feedback.subject,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .titleLarge,
                                                      ),
                                                      if (feedback.editedAt != null) ...[
                                                        const SizedBox(height: 4),
                                                        _buildEditedBadge(
                                                          feedback.editedBy,
                                                          feedback.editedAt!,
                                                          onTap: () => _showFeedbackHistoryDialog(feedback.id),
                                                        ),
                                                      ],
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          _buildStatusChip(feedback.status),
                                          // Admin Menu (•••) - เฉพาะ SUPER_ADMIN/ADMIN
                                          Consumer<AuthProvider>(
                                            builder: (context, authProvider, child) {
                                              if (authProvider.currentUser?.canManageFeedback ?? false) {
                                                return PopupMenuButton<String>(
                                                  icon: const Icon(Icons.more_vert, size: 20),
                                                  tooltip: 'ตัวเลือก',
                                                  onSelected: (value) {
                                                    if (value == 'edit') {
                                                      _showEditFeedbackDialog(feedback);
                                                    } else if (value == 'hide') {
                                                      _showHideFeedbackDialog(feedback);
                                                    } else if (value == 'delete') {
                                                      _showDeleteFeedbackDialog(feedback);
                                                    }
                                                  },
                                                  itemBuilder: (context) => [
                                                    const PopupMenuItem(
                                                      value: 'edit',
                                                      child: Row(
                                                        children: [
                                                          Icon(Icons.edit, size: 18),
                                                          SizedBox(width: 8),
                                                          Text('แก้ไข'),
                                                        ],
                                                      ),
                                                    ),
                                                    const PopupMenuItem(
                                                      value: 'hide',
                                                      child: Row(
                                                        children: [
                                                          Icon(Icons.visibility_off, size: 18, color: Colors.orange),
                                                          SizedBox(width: 8),
                                                          Text('ซ่อน', style: TextStyle(color: Colors.orange)),
                                                        ],
                                                      ),
                                                    ),
                                                    const PopupMenuItem(
                                                      value: 'delete',
                                                      child: Row(
                                                        children: [
                                                          Icon(Icons.delete, size: 18, color: Colors.red),
                                                          SizedBox(width: 8),
                                                          Text('ลบ', style: TextStyle(color: Colors.red)),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              }
                                              return const SizedBox.shrink();
                                            },
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          _buildTypeChip(feedback.type),
                                          const SizedBox(width: 8),
                                          _buildCategoryChip(feedback.category),
                                        ],
                                      ),

                                      // Submitter info (always visible)
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(Icons.person,
                                              size: 14, color: Colors.grey[600]),
                                          const SizedBox(width: 4),
                                          Text(
                                            'โดย ${feedback.userName}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color: Colors.grey[700],
                                                ),
                                          ),
                                          const SizedBox(width: 12),
                                          Icon(Icons.access_time,
                                              size: 14, color: Colors.grey[600]),
                                          const SizedBox(width: 4),
                                          Text(
                                            _formatDateTime(feedback.createdAt),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color: Colors.grey[700],
                                                ),
                                          ),
                                          const Spacer(),
                                          // Expand/Collapse button
                                          TextButton.icon(
                                            onPressed: () {
                                              setState(() {
                                                if (isExpanded) {
                                                  _expandedFeedbacks.remove(feedback.id);
                                                } else {
                                                  _expandedFeedbacks.add(feedback.id);
                                                  context
                                                      .read<FeedbackRepliesProvider>()
                                                      .loadReplies(feedback.id);
                                                  context
                                                      .read<FeedbackProvider>()
                                                      .incrementViews(feedback.id);
                                                }
                                              });
                                            },
                                            icon: Icon(
                                              isExpanded ? Icons.expand_less : Icons.expand_more,
                                              size: 16,
                                            ),
                                            label: Text(
                                              isExpanded ? 'ยุบ' : 'ขยาย',
                                              style: const TextStyle(fontSize: 14),
                                            ),
                                            style: TextButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              minimumSize: Size.zero,
                                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                      ),
                                    ),
                                  ),
                                ),

                                // Details (Collapsible) - Above Stats
                                if (isExpanded) ...[
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F8F1), // เขียวอ่อนมากๆ - เข้ากลุ่มกับ Header
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Message
                                        Text(
                                          feedback.message,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                        ),
                                        const SizedBox(height: 16),
                                        
                                        // Attachments Preview (ถ้ามี)
                                        if (feedback.attachments.isNotEmpty) ...[
                                          Container(
                                            color: const Color(0xFFF1F8F1),
                                            padding: const EdgeInsets.all(8),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '📎 ไฟล์แนบ (${feedback.attachments.length})',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                _buildAttachmentsPreview(feedback.attachments),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                        ],
                                        
                                        // Rating (ความพึงพอใจ)
                                        Row(
                                          children: [
                                            Icon(Icons.sentiment_satisfied_alt,
                                                size: 18,
                                                color: Colors.grey[600]),
                                            const SizedBox(width: 8),
                                            Text(
                                              'คะแนนความพึงพอใจ:',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey[700],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Row(
                                              children: List.generate(5, (starIndex) {
                                                return Icon(
                                                  starIndex < feedback.rating
                                                      ? Icons.star
                                                      : Icons.star_border,
                                                  color: Colors.amber,
                                                  size: 16,
                                                );
                                              }),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '(${feedback.rating}/5)',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 26), // 18 (icon) + 8 (spacing)
                                          child: Text(
                                            '(ของผู้ส่งข้อเสนอแนะ)',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey[500],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],

                                // Stats (StackOverflow style) - Outside InkWell
                                const SizedBox(height: 12),
                                Consumer3<FeedbackProvider,
                                      FeedbackRepliesProvider, AuthProvider>(
                                    builder: (context, feedbackProvider,
                                        repliesProvider, authProvider, child) {
                                      // ดึงข้อมูลล่าสุดจาก provider
                                      final currentFeedback =
                                          feedbackProvider.feedbacks.firstWhere(
                                        (f) => f.id == feedback.id,
                                        orElse: () => feedback,
                                      );

                                      // ใช้ replyCount จาก backend ก่อน expand, หลัง expand ใช้จาก repliesProvider (real-time)
                                      final hasLoadedReplies = repliesProvider
                                          .getRepliesForFeedback(feedback.id)
                                          .isNotEmpty;
                                      final replyCount = hasLoadedReplies
                                          ? repliesProvider
                                              .getReplyCount(feedback.id)
                                          : currentFeedback.replyCount;

                                      final lastActivityTime =
                                          currentFeedback.lastActivity ??
                                              currentFeedback.createdAt;

                                      return Row(
                                        children: [
                                          // Votes with vote buttons
                                          _buildVoteStatItem(
                                            value: currentFeedback.votes,
                                            label: 'คะแนน',
                                            color: currentFeedback.votes > 0
                                                ? Colors.green
                                                : (currentFeedback.votes < 0 ? Colors.red : Colors.grey),
                                            feedbackId: feedback.id,
                                            isLoggedIn: authProvider.isLoggedIn,
                                          ),
                                          const SizedBox(width: 16),

                                          // Replies
                                          _buildStatItem(
                                            value: replyCount,
                                            label: 'ตอบกลับ',
                                            icon: Icons.chat_bubble_outline,
                                            color: replyCount > 0
                                                ? const Color(0xFF228B22)
                                                : Colors.grey,
                                          ),
                                          const SizedBox(width: 16),

                                          // Views
                                          _buildStatItem(
                                            value: currentFeedback.views,
                                            label: 'เปิดดู',
                                            icon: Icons.visibility,
                                            color: Colors.grey[600]!,
                                          ),
                                          const SizedBox(width: 16),

                                          // Status Badge (เฉพาะ SUPER_ADMIN/ADMIN)
                                          if (authProvider.currentUser?.canManageFeedback ?? false)
                                            feedback.status == FeedbackModel.FeedbackStatus.approved
                                                ? _buildStatusSelectionMenu(feedback, authProvider)
                                                : _buildStatusDropdown(feedback, authProvider),
                                          const Spacer(),

                                          // Last activity
                                          if (currentFeedback.lastActivity !=
                                              null) ...[
                                            Icon(Icons.access_time,
                                                size: 12,
                                                color: Colors.grey[500]),
                                            const SizedBox(width: 4),
                                            Text(
                                              'ล่าสุด ${_formatDateTime(lastActivityTime)}',
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey[600]),
                                            ),
                                          ],
                                        ],
                                      );
                                    },
                                  ),

                                // Replies Section
                                if (isExpanded) ...[
                                  const SizedBox(height: 16),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white, // สีขาว - แยกจาก Feedback
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildRepliesList(feedback.id),
                                      ],
                                    ),
                                  ),

                                  // User Actions
                                  Consumer<AuthProvider>(
                                    builder: (context, authProvider, child) {
                                      // ตรวจสอบว่า login แล้วหรือไม่
                                      // - ทุก role ที่ login: สามารถตอบกลับได้
                                      // - ADMIN/RESEARCHER: สามารถเปลี่ยนสถานะได้ด้วย
                                      final isAuthenticated =
                                          authProvider.isLoggedIn;

                                      if (!isAuthenticated)
                                        return const SizedBox.shrink();

                                      final canManage = authProvider
                                            .currentUser
                                            ?.canManageFeedback ??
                                          false;

                                      return Column(
                                        children: [
                                          const SizedBox(height: 12),
                                          // Comment Input Box (Facebook Style)
                                          _activeReplyInputs.contains(feedback.id)
                                              ? _buildInlineReplyInput(feedback.id, authProvider)
                                              : InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      _activeReplyInputs.add(feedback.id);
                                                      _replyControllers[feedback.id] ??= TextEditingController();
                                                    });
                                                  },
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 10,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey[100],
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        CircleAvatar(
                                                          radius: 16,
                                                          backgroundColor: const Color(0xFF228B22),
                                                          child: Text(
                                                            authProvider.currentUser?.fullName
                                                                .substring(0, 1)
                                                                .toUpperCase() ??
                                                                'U',
                                                            style: const TextStyle(
                                                              color: Colors.white,
                                                              fontSize: 14,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(width: 12),
                                                        Expanded(
                                                          child: Text(
                                                            'แสดงความคิดเห็นในชื่อ ${authProvider.currentUser?.fullName ?? "ผู้ใช้"}',
                                                            style: TextStyle(
                                                              color: Colors.grey[600],
                                                              fontSize: 14,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                          const SizedBox(height: 8),
                                          ],
                                        );
                                      },
                                    ),
                                  ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  void _showTypeFilter() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('เลือกประเภท'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('ทั้งหมด'),
              leading: Radio<FeedbackModel.FeedbackType?>(
                value: null,
                groupValue: _filterType,
                onChanged: (value) {
                  setState(() {
                    _filterType = value;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
            ...FeedbackModel.FeedbackType.values.map((type) => ListTile(
                  title: Text(_getFeedbackTypeText(type)),
                  leading: Radio<FeedbackModel.FeedbackType?>(
                    value: type,
                    groupValue: _filterType,
                    onChanged: (value) {
                      setState(() {
                        _filterType = value;
                      });
                      Navigator.pop(context);
                    },
                  ),
                )),
          ],
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
              leading: Radio<FeedbackModel.FeedbackStatus?>(
                value: null,
                groupValue: _filterStatus,
                onChanged: (value) {
                  setState(() {
                    _filterStatus = value;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
            // ไม่แสดง "อนุมัติแล้ว" ในตัวกรอง (เป็นสถานะชั่วคราว)
            ...FeedbackModel.FeedbackStatus.values
                .where((status) => status != FeedbackModel.FeedbackStatus.approved)
                .map((status) => ListTile(
                  title: Text(_getStatusText(status)),
                  leading: Radio<FeedbackModel.FeedbackStatus?>(
                    value: status,
                    groupValue: _filterStatus,
                    onChanged: (value) {
                      setState(() {
                        _filterStatus = value;
                      });
                      Navigator.pop(context);
                    },
                  ),
                )),
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('ทั้งหมด'),
              leading: Radio<FeedbackModel.FeedbackCategory?>(
                value: null,
                groupValue: _filterCategory,
                onChanged: (value) {
                  setState(() {
                    _filterCategory = value;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
            ...FeedbackModel.FeedbackCategory.values.map((category) => ListTile(
                  title: Text(_getFeedbackCategoryText(category)),
                  leading: Radio<FeedbackModel.FeedbackCategory?>(
                    value: category,
                    groupValue: _filterCategory,
                    onChanged: (value) {
                      setState(() {
                        _filterCategory = value;
                      });
                      Navigator.pop(context);
                    },
                  ),
                )),
          ],
        ),
      ),
    );
  }

  // 🆕 Show Sort Options Dialog
  void _showSortOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('เรียงลำดับ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: SortOption.values.map((option) => ListTile(
            leading: Icon(option.icon, 
              color: _sortOption == option ? Theme.of(context).primaryColor : null,
            ),
            title: Text(option.label),
            trailing: _sortOption == option 
                ? Icon(Icons.check, color: Theme.of(context).primaryColor)
                : null,
            selected: _sortOption == option,
            onTap: () {
              setState(() {
                _sortOption = option;
              });
              Navigator.pop(context);
            },
          )).toList(),
        ),
      ),
    );
  }

  // 🆕 Show Date Range Filter Dialog
  void _showDateRangeFilter() async {
    await showDialog(
      context: context,
      builder: (context) {
        DateTime? tempDateFrom = _filterDateFrom;
        DateTime? tempDateTo = _filterDateTo;
        
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('กรองตามวันที่'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Date From
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: Text(tempDateFrom != null 
                        ? 'จาก: ${tempDateFrom!.day}/${tempDateFrom!.month}/${tempDateFrom!.year + 543}'
                        : 'เลือกวันเริ่มต้น'),
                    trailing: tempDateFrom != null 
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setDialogState(() {
                                tempDateFrom = null;
                              });
                            },
                          )
                        : null,
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: tempDateFrom ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setDialogState(() {
                          tempDateFrom = picked;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  // Date To
                  ListTile(
                    leading: const Icon(Icons.event),
                    title: Text(tempDateTo != null 
                        ? 'ถึง: ${tempDateTo!.day}/${tempDateTo!.month}/${tempDateTo!.year + 543}'
                        : 'เลือกวันสิ้นสุด'),
                    trailing: tempDateTo != null 
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setDialogState(() {
                                tempDateTo = null;
                              });
                            },
                          )
                        : null,
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: tempDateTo ?? DateTime.now(),
                        firstDate: tempDateFrom ?? DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setDialogState(() {
                          tempDateTo = picked;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('ยกเลิก'),
                ),
                FilledButton(
                  onPressed: () {
                    setState(() {
                      _filterDateFrom = tempDateFrom;
                      _filterDateTo = tempDateTo;
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('ตกลง'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 🆕 Status Selection Menu (สำหรับ approved status)
  Widget _buildStatusSelectionMenu(FeedbackModel.Feedback feedback, AuthProvider authProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1976D2).withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF1976D2),
          width: 1.5,
        ),
      ),
      child: PopupMenuButton<FeedbackModel.FeedbackStatus>(
        initialValue: null,
        tooltip: 'เลือกสถานะใหม่',
        offset: const Offset(0, 40),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'เลือกสถานะใหม่',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1976D2),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.arrow_drop_down,
              color: Color(0xFF1976D2),
              size: 20,
            ),
          ],
        ),
        itemBuilder: (context) => [
          PopupMenuItem(
            value: FeedbackModel.FeedbackStatus.inProgress,
            child: Row(
              children: [
                const Icon(Icons.pending_actions, color: Color(0xFF1976D2), size: 20),
                const SizedBox(width: 12),
                Text(
                  _getStatusText(FeedbackModel.FeedbackStatus.inProgress),
                  style: const TextStyle(
                    color: Color(0xFF1976D2),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuItem(
            value: FeedbackModel.FeedbackStatus.resolved,
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Color(0xFF228B22), size: 20),
                const SizedBox(width: 12),
                Text(
                  _getStatusText(FeedbackModel.FeedbackStatus.resolved),
                  style: const TextStyle(
                    color: Color(0xFF228B22),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuItem(
            value: FeedbackModel.FeedbackStatus.closed,
            child: Row(
              children: [
                const Icon(Icons.cancel, color: Color(0xFF8B4513), size: 20),
                const SizedBox(width: 12),
                Text(
                  _getStatusText(FeedbackModel.FeedbackStatus.closed),
                  style: const TextStyle(
                    color: Color(0xFF8B4513),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
        onSelected: (newStatus) {
          _updateFeedbackStatus(feedback.id, newStatus);
        },
      ),
    );
  }

  Widget _buildStatusChip(FeedbackModel.FeedbackStatus status) {
    // 🚫 ซ่อนปุ่ม chip เมื่อสถานะ = approved (แสดง dropdown แทน)
    if (status == FeedbackModel.FeedbackStatus.approved) {
      return const SizedBox.shrink();
    }

    Color color;
    switch (status) {
      case FeedbackModel.FeedbackStatus.pending:
        color = Color(0xFFDAA520); // ส้ม - รออนุมัติ
        break;
      case FeedbackModel.FeedbackStatus.approved:
        color = Color(0xFF1976D2); // น้ำเงิน - อนุมัติแล้ว (เปลี่ยนเป็นสีน้ำเงินเหมือน inProgress)
        break;
      case FeedbackModel.FeedbackStatus.rejected:
        color = Color(0xFFCD5C5C); // แดง - ปฏิเสธ
        break;
      case FeedbackModel.FeedbackStatus.inProgress:
        color = Color(0xFF1976D2); // น้ำเงิน - กำลังดำเนินการ
        break;
      case FeedbackModel.FeedbackStatus.resolved:
        color = Color(0xFF228B22); // เขียว - แก้ไขแล้ว
        break;
      case FeedbackModel.FeedbackStatus.closed:
        color = Color(0xFF8B4513); // น้ำตาล - ปิดเรื่อง
        break;
    }

    return Chip(
      label: Text(
        _getStatusText(status),
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(color: Colors.white),
      ),
      backgroundColor: color,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildTypeChip(FeedbackModel.FeedbackType type) {
    return Chip(
      label: Text(
        _getFeedbackTypeText(type),
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      backgroundColor: Color(0xFF228B22).withOpacity(0.1),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildCategoryChip(FeedbackModel.FeedbackCategory category) {
    return Chip(
      label: Text(
        _getFeedbackCategoryText(category),
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      backgroundColor: Color(0xFF228B22).withOpacity(0.1),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  // Get display name with fallback chain
  String _getUserDisplayName(AuthProvider authProvider) {
    final user = authProvider.currentUser;

    // Debug: พิมพ์ข้อมูล user
    print('🔍 DEBUG _getUserDisplayName:');
    print('  user == null: ${user == null}');
    if (user != null) {
      print('  firstName: "${user.firstName}"');
      print('  lastName: "${user.lastName}"');
      print('  fullName: "${user.fullName}"');
      print('  fullName.trim(): "${user.fullName.trim()}"');
      print('  fullName.trim().isNotEmpty: ${user.fullName.trim().isNotEmpty}');
      print('  username: "${user.username}"');
      print('  email: "${user.email}"');
    }

    if (user == null) {
      print('  ❌ Result: ผู้เยี่ยมชม (user is null)');
      return 'ผู้เยี่ยมชม';
    }

    // Fallback chain:
    // 1. ชื่อเต็ม (firstName + lastName)
    final fullNameTrimmed = user.fullName.trim();
    if (fullNameTrimmed.isNotEmpty) {
      print('  ✅ Result: $fullNameTrimmed (from fullName)');
      return fullNameTrimmed;
    }

    // 2. displayName - (ข้ามเพราะ User model ไม่มี)

    // 3. username
    if (user.username.trim().isNotEmpty) {
      print('  ✅ Result: ${user.username} (from username)');
      return user.username;
    }

    // 4. อีเมล
    if (user.email.trim().isNotEmpty) {
      print('  ✅ Result: ${user.email} (from email)');
      return user.email;
    }

    // 5. ผู้เยี่ยมชม (fallback สุดท้าย)
    print('  ❌ Result: ผู้เยี่ยมชม (no data)');
    return 'ผู้เยี่ยมชม';
  }

  // File picker methods
  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          // Images
          'jpg', 'jpeg', 'jfif', 'png', 'webp', 'gif', 'svg',
          // Documents
          'pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx',
          // Text & Data
          'txt', 'csv', 'json', 'xml',
          // Archives
          'zip', 'rar', '7z',
          // Others
          'mp4', 'avi', 'mov', 'mp3', 'wav',
        ],
        allowMultiple: true,
        withData: true, // For web
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          // จำกัดสูงสุด 10 ไฟล์
          final totalFiles = _selectedFiles.length + result.files.length;
          if (totalFiles > 10) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('สามารถแนบไฟล์ได้สูงสุด 10 ไฟล์ (เลือกอยู่ ${_selectedFiles.length} ไฟล์)'),
                backgroundColor: Colors.orange,
              ),
            );
            // เพิ่มเฉพาะไฟล์ที่ไม่เกิน 10
            final remaining = 10 - _selectedFiles.length;
            _selectedFiles.addAll(result.files.take(remaining));
          } else {
            _selectedFiles.addAll(result.files);
          }
          
          // อัปเดต attachments (ใช้ชื่อไฟล์)
          _attachedFiles = _selectedFiles.map((f) => f.name).toList();
        });
      }
    } catch (e) {
      print('Error picking files: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('เกิดข้อผิดพลาดในการเลือกไฟล์: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
      _attachedFiles = _selectedFiles.map((f) => f.name).toList();
    });
  }

  IconData _getFileIcon(String extension) {
    final ext = extension.toLowerCase();
    
    // Images
    if (['jpg', 'jpeg', 'jfif', 'png', 'webp', 'gif', 'svg'].contains(ext)) {
      return Icons.image;
    }
    
    // PDF
    if (ext == 'pdf') {
      return Icons.picture_as_pdf;
    }
    
    // Documents
    if (['doc', 'docx'].contains(ext)) {
      return Icons.description;
    }
    
    // Spreadsheets
    if (['xls', 'xlsx', 'csv'].contains(ext)) {
      return Icons.table_chart;
    }
    
    // Presentations
    if (['ppt', 'pptx'].contains(ext)) {
      return Icons.slideshow;
    }
    
    // Archives
    if (['zip', 'rar', '7z'].contains(ext)) {
      return Icons.folder_zip;
    }
    
    // Videos
    if (['mp4', 'avi', 'mov'].contains(ext)) {
      return Icons.video_file;
    }
    
    // Audio
    if (['mp3', 'wav'].contains(ext)) {
      return Icons.audio_file;
    }
    
    // Text files
    if (['txt', 'json', 'xml'].contains(ext)) {
      return Icons.article;
    }
    
    // Default
    return Icons.insert_drive_file;
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  // Helper function to validate Thai phone number
  bool _isValidThaiPhone(String phone) {
    final cleanPhone = phone.trim().replaceAll(RegExp(r'[\s\-().]'), '');
    final mobileRegex = RegExp(r'^0[689]\d{8}$');
    final bkkRegex = RegExp(r'^02\d{7}$');
    final provinceRegex = RegExp(r'^0[3-7]\d{7}$');
    return mobileRegex.hasMatch(cleanPhone) || 
           bkkRegex.hasMatch(cleanPhone) || 
           provinceRegex.hasMatch(cleanPhone);
  }

  Future<void> _submitFeedback() async {
    final authProvider = context.read<AuthProvider>();
    final isLoggedIn = authProvider.currentUser != null;
    
    if (!_formKey.currentState!.validate()) {
      // เลื่อนไปที่ field แรกที่มี error
      await Future.delayed(const Duration(milliseconds: 100));
      
      // ตรวจสอบแต่ละ field ตามลำดับ (ข้าม email/phone ถ้า login แล้ว)
      if (!isLoggedIn && 
          (_emailController.text.trim().isEmpty || 
           !RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(_emailController.text.trim()) ||
           !_emailController.text.contains('.') ||
           _emailController.text.split('@').length != 2)) {
        _emailFocusNode.requestFocus();
        _scrollController.animateTo(
          0, // Email อยู่ด้านบน
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      } else if (!isLoggedIn &&
                 (_phoneController.text.trim().isEmpty ||
                  !_isValidThaiPhone(_phoneController.text.trim()))) {
        _phoneFocusNode.requestFocus();
        _scrollController.animateTo(
          0, // Phone อยู่ด้านบนด้วย
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      } else if (_subjectController.text.trim().isEmpty) {
        _subjectFocusNode.requestFocus();
        _scrollController.animateTo(
          200, // Subject อยู่ถัดลงมา
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      } else if (_messageController.text.trim().isEmpty) {
        _messageFocusNode.requestFocus();
        _scrollController.animateTo(
          400, // Message อยู่ถัดลงมา
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
      
      return;
    }

    final feedbackProvider = context.read<FeedbackProvider>();

    // 1. อัปโหลดไฟล์ก่อน (ถ้ามี)
    List<String> fileUrls = [];
    if (_selectedFiles.isNotEmpty) {
      print('📤 Uploading ${_selectedFiles.length} files...');
      fileUrls = await feedbackProvider.uploadFiles(_selectedFiles);
      
      if (fileUrls.isEmpty && _selectedFiles.isNotEmpty) {
        // อัปโหลดล้มเหลว
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ ไม่สามารถอัปโหลดไฟล์ได้\n${feedbackProvider.errorMessage ?? ""}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
        return;
      }
      
      print('✅ Uploaded ${fileUrls.length} files');
    }

    // 2. ใช้ข้อมูลจาก user profile ถ้า login แล้ว, ถ้าไม่ใช้จากฟอร์ม
    String? email;
    String? phone;
    
    if (isLoggedIn) {
      // User login แล้ว: ใช้ข้อมูลจาก profile (อาจเป็น null)
      email = authProvider.currentUser?.email?.isNotEmpty == true 
          ? authProvider.currentUser?.email 
          : null;
      phone = authProvider.currentUser?.phoneNumber?.isNotEmpty == true 
          ? authProvider.currentUser?.phoneNumber 
          : null;
    } else {
      // Guest: ใช้ข้อมูลจากฟอร์ม (บังคับกรอกจาก validator)
      email = _emailController.text.trim();
      phone = _phoneController.text.trim();
    }

    // 3. สร้าง feedback object พร้อม file URLs
    final userId = authProvider.currentUser?.id?.toString() ?? 'anonymous';
    
    // 🔍 DEBUG: พิมพ์ข้อมูล user
    print('🔍 DEBUG _submitFeedback:');
    print('  - isLoggedIn: $isLoggedIn');
    print('  - currentUser: ${authProvider.currentUser}');
    print('  - currentUser.id: ${authProvider.currentUser?.id}');
    print('  - currentUser.username: ${authProvider.currentUser?.username}');
    print('  - userId (final): $userId');
    
    final feedback = FeedbackModel.Feedback(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      userName: _getUserDisplayName(authProvider),
      email: email,
      phone: phone,
      type: _selectedType,
      category: _selectedCategory,
      subject: _subjectController.text.trim(),
      message: _messageController.text.trim(),
      rating: _rating,
      attachments: fileUrls, // ใช้ URLs จากการอัปโหลด
      priority: _selectedPriority,
      createdAt: DateTime.now(),
    );

    try {
      // 4. ส่ง feedback ไป backend
      final success = await feedbackProvider.addFeedback(feedback);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ ส่งข้อเสนอแนะเรียบร้อยแล้ว\nรออนุมัติจากผู้ดูแลระบบ'),
              backgroundColor: Color(0xFF228B22),
              duration: Duration(seconds: 3),
            ),
          );

          // Clear form
          _formKey.currentState!.reset();
          _subjectController.clear();
          _messageController.clear();
          _emailController.clear();
          _phoneController.clear();
          setState(() {
            _selectedType = FeedbackModel.FeedbackType.suggestion;
            _selectedCategory = FeedbackModel.FeedbackCategory.ui;
            _selectedPriority = FeedbackModel.FeedbackPriority.medium;
            _rating = 5;
            _attachedFiles.clear();
            _selectedFiles.clear();
          });

          // แสดง dialog แจ้งเตือน
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Row(
                children: const [
                  Icon(Icons.check_circle, color: Color(0xFF228B22), size: 28),
                  SizedBox(width: 12),
                  Text('ส่งสำเร็จ'),
                ],
              ),
              content: const Text(
                'ข้อเสนอแนะของคุณถูกส่งเรียบร้อยแล้ว\n\n'
                '📝 ข้อเสนอแนะจะแสดงในหน้าประวัติหลังจากผู้ดูแลระบบอนุมัติ\n\n'
                'ขอบคุณสำหรับความคิดเห็นที่มีค่า',
                style: TextStyle(fontSize: 15),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('ตกลง'),
                ),
              ],
            ),
          );
        } else {
          // แสดง error message จาก provider
          final errorMsg = feedbackProvider.errorMessage ?? 
                          'เกิดข้อผิดพลาดในการส่งข้อเสนอแนะ';
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ $errorMsg'),
              backgroundColor: Colors.red[700],
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'ลองอีกครั้ง',
                textColor: Colors.white,
                onPressed: () {
                  _submitFeedback();
                },
              ),
            ),
          );

          // แสดง error dialog สำหรับ error ที่สำคัญ
          if (errorMsg.contains('เชื่อมต่อ') || errorMsg.contains('เซิร์ฟเวอร์')) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[700], size: 28),
                    const SizedBox(width: 12),
                    const Text('เกิดข้อผิดพลาด'),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      errorMsg,
                      style: const TextStyle(fontSize: 15),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),
                    const Text(
                      '💡 แนะนำ:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text('• ตรวจสอบการเชื่อมต่ออินเทอร์เน็ต'),
                    const Text('• ลองรีเฟรชหน้าเว็บ'),
                    const Text('• ติดต่อผู้ดูแลระบบหากปัญหายังคงอยู่'),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('ปิด'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _submitFeedback();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF228B22),
                    ),
                    child: const Text('ลองอีกครั้ง'),
                  ),
                ],
              ),
            );
          }
        }
      }
    } catch (e) {
      // จัดการ error ที่ไม่คาดคิด
      print('❌ Unexpected error in _submitFeedback: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ เกิดข้อผิดพลาดที่ไม่คาดคิด: ${e.toString()}'),
            backgroundColor: Colors.red[700],
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  String _getFeedbackTypeText(FeedbackModel.FeedbackType type) {
    switch (type) {
      case FeedbackModel.FeedbackType.suggestion:
        return 'ข้อเสนอแนะ';
      case FeedbackModel.FeedbackType.bug:
        return 'แจ้งปัญหา';
      case FeedbackModel.FeedbackType.feature:
        return 'ขอฟีเจอร์ใหม่';
      case FeedbackModel.FeedbackType.complaint:
        return 'ร้องเรียน';
      case FeedbackModel.FeedbackType.compliment:
        return 'ชื่นชม';
    }
  }

  String _getFeedbackTypeDescription(FeedbackModel.FeedbackType type) {
    switch (type) {
      case FeedbackModel.FeedbackType.suggestion:
        return 'เสนอแนะการปรับปรุงระบบ';
      case FeedbackModel.FeedbackType.bug:
        return 'รายงานข้อผิดพลาดหรือปัญหา';
      case FeedbackModel.FeedbackType.feature:
        return 'ขอฟีเจอร์หรือความสามารถใหม่';
      case FeedbackModel.FeedbackType.complaint:
        return 'ร้องเรียนเกี่ยวกับการใช้งาน';
      case FeedbackModel.FeedbackType.compliment:
        return 'ชื่นชมและให้กำลังใจ';
    }
  }

  String _getFeedbackCategoryText(FeedbackModel.FeedbackCategory category) {
    switch (category) {
      case FeedbackModel.FeedbackCategory.ui:
        return 'หน้าจอ/การใช้งาน';
      case FeedbackModel.FeedbackCategory.performance:
        return 'ประสิทธิภาพ';
      case FeedbackModel.FeedbackCategory.data:
        return 'ข้อมูล';
      case FeedbackModel.FeedbackCategory.export:
        return 'การส่งออกข้อมูล';
      case FeedbackModel.FeedbackCategory.livestock:
        return 'การจัดการปศุสัตว์';
      case FeedbackModel.FeedbackCategory.survey:
        return 'การสำรวจ';
      case FeedbackModel.FeedbackCategory.trading:
        return 'การซื้อขาย';
      case FeedbackModel.FeedbackCategory.transport:
        return 'การขนส่ง';
      case FeedbackModel.FeedbackCategory.other:
        return 'อื่นๆ';
    }
  }

  String _getStatusText(FeedbackModel.FeedbackStatus status) {
    switch (status) {
      case FeedbackModel.FeedbackStatus.pending:
        return 'รออนุมัติ';
      case FeedbackModel.FeedbackStatus.approved:
        return 'อนุมัติแล้ว';
      case FeedbackModel.FeedbackStatus.rejected:
        return 'ปฏิเสธ';
      case FeedbackModel.FeedbackStatus.inProgress:
        return 'กำลังดำเนินการ';
      case FeedbackModel.FeedbackStatus.resolved:
        return 'แก้ไขแล้ว';
      case FeedbackModel.FeedbackStatus.closed:
        return 'ปิดเรื่อง';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    // แปลงเป็นเวลาท้องถิ่น (ไทย) +7 ชั่วโมง
    // SQLite CURRENT_TIMESTAMP เป็น UTC ต้องบวก 7 ชั่วโมงเพื่อเป็นเวลาไทย
    DateTime localTime;

    // ตรวจสอบว่าเป็น UTC หรือไม่
    if (dateTime.isUtc) {
      // ถ้าเป็น UTC แปลงเป็น local
      localTime = dateTime.toLocal();
    } else {
      // ถ้าไม่เป็น UTC ให้ถือว่าเป็น UTC แล้วแปลงเป็น local
      // เพราะ SQLite CURRENT_TIMESTAMP ให้เวลา UTC แต่ไม่ระบุ timezone
      localTime = DateTime.utc(
        dateTime.year,
        dateTime.month,
        dateTime.day,
        dateTime.hour,
        dateTime.minute,
        dateTime.second,
      ).toLocal();
    }

    // รูปแบบไทย: dd/mm/yyyy HH.mm น.
    final day = localTime.day.toString().padLeft(2, '0');
    final month = localTime.month.toString().padLeft(2, '0');
    final year = localTime.year.toString();
    final hour = localTime.hour.toString().padLeft(2, '0');
    final minute = localTime.minute.toString().padLeft(2, '0');

    return '$day/$month/$year $hour.$minute น.';
  }

  String _getPriorityText(FeedbackModel.FeedbackPriority priority) {
    switch (priority) {
      case FeedbackModel.FeedbackPriority.low:
        return 'ต่ำ';
      case FeedbackModel.FeedbackPriority.medium:
        return 'ปานกลาง';
      case FeedbackModel.FeedbackPriority.high:
        return 'สูง';
      case FeedbackModel.FeedbackPriority.urgent:
        return 'เร่งด่วน';
    }
  }


  // Build stat item (StackOverflow style)
  Widget _buildStatItem({
    required int value,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
        ),
      ],
    );
  }

  // Build vote stat item with vote buttons (StackOverflow style)
  Widget _buildVoteStatItem({
    required int value,
    required String label,
    required Color color,
    required String feedbackId,
    required bool isLoggedIn,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Vote buttons
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLoggedIn)
              InkWell(
                onTap: () async {
                  final feedbackProvider = context.read<FeedbackProvider>();
                  final authProvider = context.read<AuthProvider>();
                  final success = await feedbackProvider.voteFeedback(
                    feedbackId: feedbackId,
                    userId: authProvider.currentUser?.id ?? 'anonymous',
                    voteType: 'up',
                  );
                  if (success && mounted) {
                    setState(() {});
                  }
                },
                child: Icon(Icons.arrow_upward, size: 16, color: const Color(0xFF228B22)),
              ),
            const SizedBox(width: 4),
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(width: 4),
            if (isLoggedIn)
              InkWell(
                onTap: () async {
                  final feedbackProvider = context.read<FeedbackProvider>();
                  final authProvider = context.read<AuthProvider>();
                  final success = await feedbackProvider.voteFeedback(
                    feedbackId: feedbackId,
                    userId: authProvider.currentUser?.id ?? 'anonymous',
                    voteType: 'down',
                  );
                  if (success && mounted) {
                    setState(() {});
                  }
                },
                child: Icon(Icons.arrow_downward, size: 16, color: Colors.grey[600]),
              ),
          ],
        ),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
        ),
      ],
    );
  }

  // Build message with @mention highlighting
  Widget _buildMessageWithMentions(String message, {double fontSize = 14}) {
    // Regex: @ตามด้วยตัวอักษร (รองรับภาษาไทย) จนถึง space
    final mentionRegex = RegExp(r'@[^\s]+');
    final matches = mentionRegex.allMatches(message);

    if (matches.isEmpty) {
      return Text(message, style: TextStyle(fontSize: fontSize));
    }

    final spans = <TextSpan>[];
    int currentPosition = 0;

    for (final match in matches) {
      // Add text before @mention
      if (match.start > currentPosition) {
        spans.add(TextSpan(
          text: message.substring(currentPosition, match.start),
          style: TextStyle(fontSize: fontSize, color: Colors.black),
        ));
      }

      // Add @mention with highlight
      // แปลง underscore กลับเป็น space เพื่อแสดงผล
      final mentionText = match.group(0)!.replaceAll('_', ' ');
      spans.add(TextSpan(
        text: mentionText,
        style: TextStyle(
          fontSize: fontSize,
          color: const Color(0xFF228B22),
          fontWeight: FontWeight.bold,
        ),
      ));

      currentPosition = match.end;
    }

    // Add remaining text
    if (currentPosition < message.length) {
      spans.add(TextSpan(
        text: message.substring(currentPosition),
        style: TextStyle(fontSize: fontSize, color: Colors.black),
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }

  // Build Replies List Widget
  Widget _buildRepliesList(String feedbackId) {
    return Consumer<FeedbackRepliesProvider>(
      builder: (context, repliesProvider, child) {
        final topLevelReplies = repliesProvider.getTopLevelReplies(feedbackId);

        if (topLevelReplies.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: topLevelReplies.map((reply) {
            return _buildReplyItem(reply, feedbackId);
          }).toList(),
        );
      },
    );
  }

  // Build individual Reply Item (with nested replies) - Facebook Style
  Widget _buildReplyItem(FeedbackReply reply, String feedbackId) {
    return Consumer<FeedbackRepliesProvider>(
      key: ValueKey('reply_${reply.id}'),
      builder: (context, repliesProvider, child) {
        final nestedReplies =
            repliesProvider.getNestedReplies(feedbackId, reply.id);

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFF228B22),
                child: Text(
                  reply.userName.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Message bubble (แบบ Facebook)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD), // สีฟ้าอ่อน - สำหรับ Comments
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // User name with menu
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      reply.userName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    if (reply.editedAt != null) ...[
                                      const SizedBox(height: 4),
                                      _buildEditedBadge(
                                        reply.editedBy,
                                        reply.editedAt!,
                                        onTap: () => _showReplyHistoryDialog(feedbackId, reply),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              // Admin Menu (•••) - เฉพาะ SUPER_ADMIN/ADMIN
                              Consumer<AuthProvider>(
                                builder: (context, authProvider, child) {
                                  if (authProvider.currentUser?.canManageFeedback ?? false) {
                                    return PopupMenuButton<String>(
                                      icon: const Icon(Icons.more_horiz, size: 18),
                                      tooltip: 'ตัวเลือก',
                                      padding: EdgeInsets.zero,
                                      onSelected: (value) {
                                        if (value == 'edit') {
                                          _showEditReplyDialog(feedbackId, reply);
                                        } else if (value == 'hide') {
                                          _showHideReplyDialog(feedbackId, reply);
                                        } else if (value == 'delete') {
                                          _showDeleteReplyDialog(feedbackId, reply);
                                        }
                                      },
                                      itemBuilder: (context) => [
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
                                          value: 'hide',
                                          child: Row(
                                            children: [
                                              Icon(Icons.visibility_off, size: 16, color: Colors.orange),
                                              SizedBox(width: 8),
                                              Text('ซ่อน', style: TextStyle(color: Colors.orange)),
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
                                      ],
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          // Message (with @mention highlighting)
                          _buildMessageWithMentions(reply.message, fontSize: 15),
                        ],
                      ),
                    ),

                    // Actions (Facebook style: เวลา · ถูกใจ · ตอบกลับ)
                    Padding(
                      padding: const EdgeInsets.only(left: 12, top: 4),
                      child: Row(
                        children: [
                          // เวลา
                          Text(
                            _formatDateTime(reply.createdAt),
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey[600]),
                          ),

                          Consumer<AuthProvider>(
                            builder: (context, authProvider, child) {
                              if (!authProvider.isLoggedIn)
                                return const SizedBox.shrink();

                              return Row(
                                children: [
                                  // Separator
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    child: Text('·',
                                        style:
                                            TextStyle(color: Colors.grey[600])),
                                  ),

                                  // Vote up link
                                  InkWell(
                                    onTap: () async {
                                      final repliesProvider = context
                                          .read<FeedbackRepliesProvider>();
                                      await repliesProvider.voteReply(
                                        feedbackId: feedbackId,
                                        replyId: reply.id,
                                        userId: authProvider.currentUser?.id ??
                                            'anonymous',
                                        voteType: 'up',
                                      );
                                    },
                                    child: Icon(
                                      Icons.arrow_upward,
                                      size: 16,
                                      color: const Color(0xFF228B22),
                                    ),
                                  ),

                                  // Vote count (real-time update)
                                  Consumer<FeedbackRepliesProvider>(
                                    builder: (context, repliesProvider, child) {
                                      final allReplies = repliesProvider.getRepliesForFeedback(feedbackId);
                                      final currentReply = allReplies.firstWhere(
                                        (r) => r.id == reply.id,
                                        orElse: () => reply,
                                      );
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 4),
                                        child: Text(
                                          currentReply.votes.toString(),
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: currentReply.votes > 0 ? Colors.green[700] : (currentReply.votes < 0 ? Colors.red[700] : Colors.grey[600]),
                                          ),
                                        ),
                                      );
                                    },
                                  ),

                                  // Vote down link
                                  InkWell(
                                    onTap: () async {
                                      final repliesProvider = context
                                          .read<FeedbackRepliesProvider>();
                                      await repliesProvider.voteReply(
                                        feedbackId: feedbackId,
                                        replyId: reply.id,
                                        userId: authProvider.currentUser?.id ??
                                            'anonymous',
                                        voteType: 'down',
                                      );
                                    },
                                    child: Icon(
                                      Icons.arrow_downward,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),

                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    child: Text('·',
                                        style:
                                            TextStyle(color: Colors.grey[600])),
                                  ),

                                  // ตอบกลับ link
                                  InkWell(
                                    onTap: () => _showReplyDialog(
                                      feedbackId,
                                      parentReplyId: reply.id,
                                      replyToUserName: reply.userName,
                                    ),
                                    child: Text(
                                      'ตอบกลับ',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    // Nested replies (Level 2) - แบบ Facebook
                    if (nestedReplies.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      ...nestedReplies.map((nestedReply) {
                        return Padding(
                          key: ValueKey('nested_reply_${nestedReply.id}'),
                          padding: const EdgeInsets.only(
                              left: 40, bottom: 12), // เยื้องเข้ามา
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Avatar ของ nested reply
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: Colors.grey[400],
                                child: Text(
                                  nestedReply.userName
                                      .substring(0, 1)
                                      .toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),

                              // Content
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Message bubble
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE3F2FD), // สีฟ้าอ่อน - สำหรับ Comments
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // User name with menu
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      nestedReply.userName,
                                                      style: const TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    if (nestedReply.editedAt != null) ...[
                                                      const SizedBox(height: 4),
                                                      _buildEditedBadge(
                                                        nestedReply.editedBy,
                                                        nestedReply.editedAt!,
                                                        onTap: () => _showReplyHistoryDialog(feedbackId, nestedReply),
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                              ),
                                              // Admin Menu (•••) - เฉพาะ SUPER_ADMIN/ADMIN
                                              Consumer<AuthProvider>(
                                                builder: (context, authProvider, child) {
                                                  if (authProvider.currentUser?.canManageFeedback ?? false) {
                                                    return PopupMenuButton<String>(
                                                      icon: const Icon(Icons.more_horiz, size: 18),
                                                      tooltip: 'ตัวเลือก',
                                                      padding: EdgeInsets.zero,
                                                      onSelected: (value) {
                                                        if (value == 'edit') {
                                                          _showEditReplyDialog(feedbackId, nestedReply);
                                                        } else if (value == 'hide') {
                                                          _showHideReplyDialog(feedbackId, nestedReply);
                                                        } else if (value == 'delete') {
                                                          _showDeleteReplyDialog(feedbackId, nestedReply);
                                                        }
                                                      },
                                                      itemBuilder: (context) => [
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
                                                          value: 'hide',
                                                          child: Row(
                                                            children: [
                                                              Icon(Icons.visibility_off, size: 16, color: Colors.orange),
                                                              SizedBox(width: 8),
                                                              Text('ซ่อน', style: TextStyle(color: Colors.orange)),
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
                                                      ],
                                                    );
                                                  }
                                                  return const SizedBox.shrink();
                                                },
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          // Message (with @mention highlighting)
                                          _buildMessageWithMentions(
                                              nestedReply.message,
                                              fontSize: 15),
                                        ],
                                      ),
                                    ),

                                    // Actions (แบบ Facebook)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 12, top: 4),
                                      child: Row(
                                        children: [
                                          // เวลา
                                          Text(
                                            _formatDateTime(
                                                nestedReply.createdAt),
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[600]),
                                          ),

                                          Consumer<AuthProvider>(
                                            builder:
                                                (context, authProvider, child) {
                                              if (!authProvider.isLoggedIn)
                                                return const SizedBox.shrink();

                                              return Row(
                                                children: [
                                                  // Vote up
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 6),
                                                    child: Text('·',
                                                        style: TextStyle(
                                                            color: Colors
                                                                .grey[600],
                                                            fontSize: 11)),
                                                  ),
                                                  InkWell(
                                                    onTap: () async {
                                                      final repliesProvider =
                                                          context.read<
                                                              FeedbackRepliesProvider>();
                                                      await repliesProvider
                                                              .voteReply(
                                                        feedbackId: feedbackId,
                                                        replyId: nestedReply.id,
                                                        userId: authProvider
                                                                .currentUser
                                                                ?.id ??
                                                            'anonymous',
                                                        voteType: 'up',
                                                      );
                                                    },
                                                    child: Icon(
                                                      Icons.arrow_upward,
                                                      size: 16,
                                                      color: const Color(0xFF228B22),
                                                    ),
                                                  ),

                                                  // Vote count (real-time update)
                                                  Consumer<FeedbackRepliesProvider>(
                                                    builder: (context, repliesProvider, child) {
                                                      final allReplies = repliesProvider.getRepliesForFeedback(feedbackId);
                                                      final currentNestedReply = allReplies.firstWhere(
                                                        (r) => r.id == nestedReply.id,
                                                        orElse: () => nestedReply,
                                                      );
                                                      return Padding(
                                                        padding: const EdgeInsets.symmetric(horizontal: 4),
                                                        child: Text(
                                                          currentNestedReply.votes.toString(),
                                                          style: TextStyle(
                                                            fontSize: 15,
                                                            fontWeight: FontWeight.bold,
                                                            color: currentNestedReply.votes > 0 ? Colors.green[700] : (currentNestedReply.votes < 0 ? Colors.red[700] : Colors.grey[600]),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),

                                                  // Vote down
                                                  InkWell(
                                                    onTap: () async {
                                                      final repliesProvider =
                                                          context.read<
                                                              FeedbackRepliesProvider>();
                                                      await repliesProvider
                                                              .voteReply(
                                                        feedbackId: feedbackId,
                                                        replyId: nestedReply.id,
                                                        userId: authProvider
                                                                .currentUser
                                                                ?.id ??
                                                            'anonymous',
                                                        voteType: 'down',
                                                      );
                                                    },
                                                    child: Icon(
                                                      Icons.arrow_downward,
                                                      size: 16,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),

                                                  // ปุ่มตอบกลับ (สำหรับ level 2)
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 6),
                                                    child: Text('·',
                                                        style: TextStyle(
                                                            color: Colors
                                                                .grey[600],
                                                            fontSize: 11)),
                                                  ),
                                                  InkWell(
                                                    onTap: () =>
                                                        _showReplyDialog(
                                                      feedbackId,
                                                      parentReplyId: reply.id,
                                                      replyToUserName:
                                                          nestedReply.userName,
                                                    ),
                                                    child: Text(
                                                      'ตอบกลับ',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.grey[700],
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Reply Dialog (สำหรับทุกคน)
  void _showReplyDialog(String feedbackId,
      {String? parentReplyId, String? replyToUserName}) {
    // ถ้ามี replyToUserName ให้ใส่ @mention ไว้ล่วงหน้า
    // แทน space ด้วย underscore เพื่อให้ highlight ได้
    final mentionName = replyToUserName?.replaceAll(' ', '_') ?? '';
    final mentionText = mentionName.isNotEmpty ? '@$mentionName ' : '';
    final replyController = TextEditingController(text: mentionText);

    // ตั้ง cursor ไว้หลัง @mention
    if (mentionText.isNotEmpty) {
      replyController.selection = TextSelection.fromPosition(
        TextPosition(offset: mentionText.length),
      );
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.reply, color: Color(0xFF228B22)),
            const SizedBox(width: 8),
            // ใช้ชื่อเดิมที่มี space (replyToUserName) ไม่ใช่ mentionName
            Text(parentReplyId != null
                ? 'ตอบกลับ @$replyToUserName'
                : 'ตอบกลับ'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (parentReplyId != null && replyToUserName != null) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'ตอบกลับ: $replyToUserName',
                  style: const TextStyle(
                      fontSize: 12, fontStyle: FontStyle.italic),
                ),
              ),
              const SizedBox(height: 16),
            ],
            TextField(
              controller: replyController,
              decoration: const InputDecoration(
                labelText: 'ข้อความของคุณ',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
                hintText: 'พิมพ์ข้อความตอบกลับ...',
              ),
              maxLines: 5,
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () async {
              final message = replyController.text.trim();
              if (message.isNotEmpty) {
                final authProvider = context.read<AuthProvider>();
                final repliesProvider = context.read<FeedbackRepliesProvider>();

                final userId = authProvider.currentUser?.id ?? 'anonymous';
                final userName = _getUserDisplayName(authProvider);

                final success = await repliesProvider.addReply(
                  feedbackId: feedbackId,
                  userId: userId,
                  userName: userName,
                  message: message,
                  parentReplyId: parentReplyId,
                );

                if (mounted) {
                  Navigator.pop(context);
                  
                  // Reload feedback data to update lastActivity
                  if (success) {
                    context.read<FeedbackProvider>().initialize();
                  }
                  
                  if (success) {
                    StandardSnackbar.showSuccess(context, 'ตอบกลับสำเร็จ');
                  } else {
                    StandardSnackbar.showError(context, 'เกิดข้อผิดพลาด');
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF228B22)),
            child: const Text('ส่ง', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Build inline reply input widget
  Widget _buildInlineReplyInput(String feedbackId, AuthProvider authProvider) {
    final controller = _replyControllers[feedbackId]!;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: const Color(0xFF228B22),
            child: Text(
              authProvider.currentUser?.fullName.substring(0, 1).toUpperCase() ?? 'U',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              autofocus: true,
              maxLines: 3,
              minLines: 1,
              decoration: InputDecoration(
                hintText: 'แสดงความคิดเห็นในชื่อ ${authProvider.currentUser?.fullName ?? "ผู้ใช้"}',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
              onSubmitted: (_) => _submitInlineReply(feedbackId),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              // ปุ่มส่ง
              IconButton(
                onPressed: () => _submitInlineReply(feedbackId),
                icon: const Icon(Icons.send, color: Color(0xFF228B22)),
                tooltip: 'ส่ง',
              ),
              // ปุ่มยกเลิก
              IconButton(
                onPressed: () {
                  setState(() {
                    controller.clear();
                    _activeReplyInputs.remove(feedbackId);
                  });
                },
                icon: const Icon(Icons.close, color: Colors.grey),
                tooltip: 'ยกเลิก',
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Submit inline reply (without dialog)
  Future<void> _submitInlineReply(String feedbackId) async {
    final controller = _replyControllers[feedbackId];
    if (controller == null) return;
    
    final message = controller.text.trim();
    if (message.isEmpty) return;
    
    final authProvider = context.read<AuthProvider>();
    final repliesProvider = context.read<FeedbackRepliesProvider>();
    
    final userId = authProvider.currentUser?.id ?? 'anonymous';
    final userName = _getUserDisplayName(authProvider);
    
    final success = await repliesProvider.addReply(
      feedbackId: feedbackId,
      userId: userId,
      userName: userName,
      message: message,
      parentReplyId: null, // top-level reply
    );
    
    if (mounted) {
      if (success) {
        // Clear input and hide
        controller.clear();
        setState(() {
          _activeReplyInputs.remove(feedbackId);
        });
        
        // Reload feedback data to update lastActivity
        context.read<FeedbackProvider>().initialize();
        
        if (success) {
          StandardSnackbar.showSuccess(context, 'ตอบกลับสำเร็จ');
        } else {
          StandardSnackbar.showError(context, 'เกิดข้อผิดพลาด');
        }
      }
    }
  }

  // Update Feedback Status
  Future<void> _updateFeedbackStatus(
      String feedbackId, FeedbackModel.FeedbackStatus newStatus) async {
    final authProvider = context.read<AuthProvider>();
    final feedbackProvider = context.read<FeedbackProvider>();
    final success = await feedbackProvider.updateFeedbackStatus(
      feedbackId,
      newStatus,
      respondedByUserName: _getUserDisplayName(authProvider),
    );

    if (mounted) {
      if (success) {
        StandardSnackbar.showSuccess(context, 'อัปเดตสถานะสำเร็จ');
      } else {
        StandardSnackbar.showError(context, 'เกิดข้อผิดพลาด');
      }
    }
  }

  // Admin Management Tab - สำหรับอนุมัติ feedback
  Widget _buildAdminManagement() {
    return Consumer<FeedbackProvider>(
      builder: (context, feedbackProvider, child) {
        // แสดงเฉพาะ feedback ที่ pending (รออนุมัติ)
        final pendingFeedbacks = feedbackProvider.feedbacks
            .where((f) => f.status == FeedbackModel.FeedbackStatus.pending)
            .toList();

        if (pendingFeedbacks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline, 
                    size: 80, 
                    color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'ไม่มีข้อเสนอแนะที่รออนุมัติ',
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

        return ListView.builder(
          padding: EdgeInsets.all(ResponsiveHelper.getCardSpacing(context)),
          itemCount: pendingFeedbacks.length,
          itemBuilder: (context, index) {
            final feedback = pendingFeedbacks[index];
            print('🔍 [Feedback] ID: ${feedback.id}, Subject: ${feedback.subject}, Attachments: ${feedback.attachments.length}');
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.orange[200]!, width: 2),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orange[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.pending_actions, 
                                      color: Colors.orange[800]),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                feedback.subject,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  _buildTypeChip(feedback.type),
                                  const SizedBox(width: 8),
                                  _buildCategoryChip(feedback.category),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Admin Menu (•••) - เฉพาะ SUPER_ADMIN/ADMIN
                        Consumer<AuthProvider>(
                          builder: (context, authProvider, child) {
                            if (authProvider.currentUser?.canManageFeedback ?? false) {
                              return PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert, size: 20),
                                tooltip: 'ตัวเลือก',
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _showEditFeedbackDialog(feedback);
                                  } else if (value == 'hide') {
                                    _showHideFeedbackDialog(feedback);
                                  } else if (value == 'delete') {
                                    _showDeleteFeedbackDialog(feedback);
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit, size: 18),
                                        SizedBox(width: 8),
                                        Text('แก้ไข'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'hide',
                                    child: Row(
                                      children: [
                                        Icon(Icons.visibility_off, size: 18, color: Colors.orange),
                                        SizedBox(width: 8),
                                        Text('ซ่อน', style: TextStyle(color: Colors.orange)),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete, size: 18, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text('ลบ', style: TextStyle(color: Colors.red)),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 12),
                    
                    // Message
                    Text(
                      feedback.message,
                      style: const TextStyle(fontSize: 14),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Attachments Preview (ถ้ามี)
                    if (feedback.attachments.isNotEmpty) ...[
                      Container(
                        color: const Color(0xFFF1F8F1),
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '📎 ไฟล์แนบ (${feedback.attachments.length})',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildAttachmentsPreview(feedback.attachments),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    
                    
                    // Submitter Info
                    Row(
                      children: [
                        Icon(Icons.person, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          feedback.userName,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          _formatDateTime(feedback.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 12),
                    
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _approveFeedback(feedback),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF228B22),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            icon: const Icon(Icons.check_circle),
                            label: const Text('อนุมัติ'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _rejectFeedback(feedback),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red[700],
                              side: BorderSide(color: Colors.red[700]!),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            icon: const Icon(Icons.cancel),
                            label: const Text('ปฏิเสธ'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // อนุมัติ feedback
  Future<void> _approveFeedback(FeedbackModel.Feedback feedback) async {
    final feedbackProvider = context.read<FeedbackProvider>();
    
    // อัปเดต status เป็น approved
    final success = await feedbackProvider.updateFeedbackStatus(
      feedback.id,
      FeedbackModel.FeedbackStatus.approved,
      adminResponse: 'อนุมัติโดยผู้ดูแลระบบ',
    );
    
    if (mounted) {
      StandardSnackbar.showSuccess(context, 'อนุมัติข้อเสนอแนะ "${feedback.subject}" แล้ว');
    }
  }

  // ปฏิเสธ feedback
  Future<void> _rejectFeedback(FeedbackModel.Feedback feedback) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการปฏิเสธ'),
        content: Text('คุณต้องการปฏิเสธข้อเสนอแนะ "${feedback.subject}" หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('ปฏิเสธ'),
          ),
        ],
      ),
    );
    
    if (confirmed == true && mounted) {
      final feedbackProvider = context.read<FeedbackProvider>();
      
      // อัปเดต status เป็น rejected
      final success = await feedbackProvider.updateFeedbackStatus(
        feedback.id,
        FeedbackModel.FeedbackStatus.rejected,
        adminResponse: 'ข้อเสนอแนะนี้ถูกปฏิเสธโดยผู้ดูแลระบบ',
      );
      
      if (mounted) {
        StandardSnackbar.showSuccess(context, 'ปฏิเสธข้อเสนอแนะ "${feedback.subject}" แล้ว');
      }
    }
  }

  // ย้ายไปจัดการ (เปลี่ยน rejected → pending)
  Future<void> _moveToPending(FeedbackModel.Feedback feedback) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.undo, color: Colors.blue),
            SizedBox(width: 8),
            Text('ย้ายไปจัดการ'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('คุณต้องการย้ายข้อเสนอแนะ "${feedback.subject}" กลับไปยังแท็บ "จัดการ" หรือไม่?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[300]!),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'ข้อเสนอแนะจะกลับเป็นสถานะ "รอดำเนินการ"',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('ย้าย'),
          ),
        ],
      ),
    );
    
    if (confirmed == true && mounted) {
      final feedbackProvider = context.read<FeedbackProvider>();
      final authProvider = context.read<AuthProvider>();
      
      // อัปเดต status เป็น pending
      final success = await feedbackProvider.updateFeedbackStatus(
        feedback.id,
        FeedbackModel.FeedbackStatus.pending,
        adminResponse: null, // ล้าง admin response
        respondedByUserName: authProvider.currentUser?.username,
      );
      
      if (mounted) {
        if (success) {
          StandardSnackbar.showSuccess(
            context, 
            'ย้ายข้อเสนอแนะ "${feedback.subject}" ไปยังแท็บ "จัดการ" แล้ว'
          );
        } else {
          StandardSnackbar.showError(context, 'เกิดข้อผิดพลาดในการย้าย');
        }
      }
    }
  }

  // Hidden Items Tab (Soft Deleted Items)
  Widget _buildHiddenItems() {
    return Consumer2<FeedbackProvider, FeedbackRepliesProvider>(
      builder: (context, feedbackProvider, repliesProvider, child) {
        return FutureBuilder<List<dynamic>>(
          key: ValueKey(_hiddenItemsRefreshKey), // Force rebuild on restore
          future: Future.wait([
            feedbackProvider.getHiddenFeedback(),
            repliesProvider.getHiddenReplies(),
          ]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text(
                      'เกิดข้อผิดพลาด: ${snapshot.error}',
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  ],
                ),
              );
            }

            final data = snapshot.data ?? [];
            final hiddenFeedbacks = data.isNotEmpty ? data[0] as List<FeedbackModel.Feedback> : <FeedbackModel.Feedback>[];
            final hiddenReplies = data.length > 1 ? data[1] as List<FeedbackReply> : <FeedbackReply>[];

            if (hiddenFeedbacks.isEmpty && hiddenReplies.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.visibility_off_outlined, 
                         size: 64, 
                         color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'ไม่มีข้อมูลที่ซ่อนไว้',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'รายการที่คุณซ่อนไว้จะแสดงที่นี่',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _hiddenItemsRefreshKey++; // Force refresh
                });
              },
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Use 2-column layout for wider screens
                  final isWideScreen = constraints.maxWidth > 800;
                  
                  if (isWideScreen) {
                    // Two-column layout
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left Column: Hidden Feedbacks
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ข้อเสนอแนะที่ซ่อน (${hiddenFeedbacks.length})',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                if (hiddenFeedbacks.isEmpty)
                                  Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.grey[300]!),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'ไม่มีข้อเสนอแนะที่ซ่อน',
                                        style: TextStyle(color: Colors.grey[600]),
                                      ),
                                    ),
                                  )
                                else
                                  ...hiddenFeedbacks.map((feedback) => _buildHiddenFeedbackCard(feedback)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Right Column: Hidden Replies
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ความคิดเห็นที่ซ่อน (${hiddenReplies.length})',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                if (hiddenReplies.isEmpty)
                                  Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.grey[300]!),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'ไม่มีความคิดเห็นที่ซ่อน',
                                        style: TextStyle(color: Colors.grey[600]),
                                      ),
                                    ),
                                  )
                                else
                                  ...hiddenReplies.map((reply) => _buildHiddenReplyCard(reply)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    // Single column layout for narrow screens
                    return ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        // Hidden Feedback Section
                        Text(
                          'ข้อเสนอแนะที่ซ่อน (${hiddenFeedbacks.length})',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (hiddenFeedbacks.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(24),
                            margin: const EdgeInsets.only(bottom: 24),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Center(
                              child: Text(
                                'ไม่มีข้อเสนอแนะที่ซ่อน',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ),
                          )
                        else
                          ...hiddenFeedbacks.map((feedback) => _buildHiddenFeedbackCard(feedback)),
                        const SizedBox(height: 24),
                        
                        // Hidden Replies Section
                        Text(
                          'ความคิดเห็นที่ซ่อน (${hiddenReplies.length})',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (hiddenReplies.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Center(
                              child: Text(
                                'ไม่มีความคิดเห็นที่ซ่อน',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ),
                          )
                        else
                          ...hiddenReplies.map((reply) => _buildHiddenReplyCard(reply)),
                      ],
                    );
                  }
                },
              ),
            );
          },
        );
      },
    );
  }

  // Build hidden feedback card with restore button
  Widget _buildHiddenFeedbackCard(FeedbackModel.Feedback feedback) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.orange[200]!, width: 2),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.orange[50]!,
              Colors.white,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.visibility_off, 
                                color: Colors.orange[800]),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          feedback.subject,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _buildTypeChip(feedback.type),
                            const SizedBox(width: 8),
                            _buildCategoryChip(feedback.category),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Restore button
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      if (authProvider.currentUser?.canManageFeedback ?? false) {
                        return IconButton(
                          icon: const Icon(Icons.restore, color: Colors.green),
                          tooltip: 'กู้คืน',
                          onPressed: () => _showRestoreFeedbackDialog(feedback),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Description
              Text(
                feedback.message,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 12),
              
              // Metadata
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person_off, size: 16, color: Colors.orange[700]),
                        const SizedBox(width: 8),
                        Text(
                          'ซ่อนโดย: ${feedback.deletedBy ?? 'ไม่ระบุ'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Text(
                          'ซ่อนเมื่อ: ${_formatDateTime(feedback.deletedAt!)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build hidden reply card with restore button
  Widget _buildHiddenReplyCard(FeedbackReply reply) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.orange[200]!, width: 2),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.orange[50]!,
              Colors.white,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.comment, 
                                color: Colors.orange[800], size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ความคิดเห็นที่ซ่อน',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'จาก: ${reply.userName}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Restore button
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      if (authProvider.currentUser?.canManageFeedback ?? false) {
                        return IconButton(
                          icon: const Icon(Icons.restore, color: Colors.green),
                          tooltip: 'กู้คืน',
                          onPressed: () => _showRestoreReplyDialog(reply),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Reply message
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Text(
                  reply.message,
                  style: const TextStyle(fontSize: 14),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Metadata
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person_off, size: 16, color: Colors.orange[700]),
                        const SizedBox(width: 8),
                        Text(
                          'ซ่อนโดย: ${reply.deletedBy ?? 'ไม่ระบุ'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Text(
                          'ซ่อนเมื่อ: ${_formatDateTime(reply.deletedAt!)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Show restore confirmation dialog
  void _showRestoreFeedbackDialog(FeedbackModel.Feedback feedback) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.restore, color: Colors.green),
            SizedBox(width: 8),
            Text('กู้คืนข้อเสนอแนะ'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('คุณต้องการกู้คืนข้อเสนอแนะ "${feedback.subject}" หรือไม่?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[300]!),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.green, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'ข้อมูลจะกลับมาแสดงในระบบอีกครั้ง',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            onPressed: () async {
              Navigator.pop(context);

              final authProvider = context.read<AuthProvider>();
              final currentUser = authProvider.currentUser;
              
              final success = await context.read<FeedbackProvider>().restoreFeedback(
                feedback.id,
                restoredBy: currentUser?.username,
                adminId: currentUser?.id,
                adminUsername: currentUser?.username,
              );

              if (mounted) {
                if (success) {
                  StandardSnackbar.showSuccess(context, 'กู้คืนข้อเสนอแนะสำเร็จ');
                  setState(() {
                    _hiddenItemsRefreshKey++; // Force refresh hidden items tab
                  });
                } else {
                  StandardSnackbar.showError(context, 'เกิดข้อผิดพลาดในการกู้คืน');
                }
              }
            },
            child: const Text('กู้คืน'),
          ),
        ],
      ),
    );
  }

  // Show restore reply confirmation dialog
  void _showRestoreReplyDialog(FeedbackReply reply) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.restore, color: Colors.green),
            SizedBox(width: 8),
            Text('กู้คืนความคิดเห็น'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('คุณต้องการกู้คืนความคิดเห็นนี้หรือไม่?'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                reply.message,
                style: const TextStyle(fontSize: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[300]!),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.green, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'ความคิดเห็นจะกลับมาแสดงในระบบอีกครั้ง',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            onPressed: () async {
              Navigator.pop(context);

              final authProvider = context.read<AuthProvider>();
              final currentUser = authProvider.currentUser;
              
              final success = await context.read<FeedbackRepliesProvider>().restoreReply(
                feedbackId: reply.feedbackId,
                replyId: reply.id,
                restoredBy: currentUser?.username,
                adminId: currentUser?.id,
                adminUsername: currentUser?.username,
              );

              if (mounted) {
                if (success) {
                  StandardSnackbar.showSuccess(context, 'กู้คืนความคิดเห็นสำเร็จ');
                  setState(() {
                    _hiddenItemsRefreshKey++; // Force refresh hidden items tab
                  });
                } else {
                  StandardSnackbar.showError(context, 'เกิดข้อผิดพลาดในการกู้คืน');
                }
              }
            },
            child: const Text('กู้คืน'),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsDashboard() {
    return Consumer<FeedbackProvider>(
      builder: (context, feedbackProvider, child) {
        final stats = feedbackProvider.getStatistics();
        final avgRating = feedbackProvider.getAverageRating();

        return SingleChildScrollView(
          padding: EdgeInsets.all(ResponsiveHelper.getCardSpacing(context)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.analytics,
                            size: 64,
                            color: Color(0xFF228B22),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'สถิติและวิเคราะห์ข้อเสนอแนะ',
                            style: Theme.of(context).textTheme.headlineSmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'ภาพรวมข้อเสนอแนะและความคิดเห็นทั้งหมด',
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Summary Cards - Centered
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'ทั้งหมด',
                          '${stats['total']}',
                          Icons.feedback,
                          Color(0xFF228B22),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'คะแนนเฉลี่ย',
                          '${avgRating.toStringAsFixed(1)}',
                          Icons.star,
                          Color(0xFFDAA520),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Status Distribution - Centered
              Center(
                child: Text(
                  'สถานะข้อเสนอแนะ',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'รอดำเนินการ',
                          '${stats['pending']}',
                          Icons.pending,
                          Color(0xFFDAA520),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatCard(
                          'กำลังดำเนินการ',
                          '${stats['inProgress']}',
                          Icons.work,
                          Color(0xFF228B22),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatCard(
                          'แก้ไขแล้ว',
                          '${stats['resolved']}',
                          Icons.check_circle,
                          Color(0xFF228B22),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatCard(
                          'ปิดเรื่อง',
                          '${stats['closed']}',
                          Icons.close,
                          Color(0xFF8B4513),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Type Distribution - Centered
              Center(
                child: Text(
                  'ประเภทข้อเสนอแนะ',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'ข้อเสนอแนะ',
                              '${stats['suggestions']}',
                              Icons.lightbulb,
                              Color(0xFF228B22),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildStatCard(
                              'แจ้งปัญหา',
                              '${stats['bugs']}',
                              Icons.bug_report,
                              Color(0xFFCD5C5C),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildStatCard(
                              'ขอฟีเจอร์ใหม่',
                              '${stats['features']}',
                              Icons.new_releases,
                              Color(0xFFDAA520),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'ร้องเรียน',
                              '${stats['complaints']}',
                              Icons.report_problem,
                              Color(0xFFCD5C5C),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildStatCard(
                              'ชื่นชม',
                              '${stats['compliments']}',
                              Icons.thumb_up,
                              Color(0xFF228B22),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Container()), // Empty space
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Recent Activity - Centered
              Center(
                child: Text(
                  'กิจกรรมล่าสุด',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children:
                        feedbackProvider.feedbacks.take(3).map((feedback) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getTypeColor(feedback.type),
                          child: Icon(
                            _getTypeIcon(feedback.type),
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        title: Text(feedback.subject),
                        subtitle: Text(
                            '${feedback.userName} • ${_formatDateTime(feedback.createdAt)}'),
                        trailing: _buildStatusChip(feedback.status),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Build attachments preview for list view (thumbnail row)
  Widget _buildAttachmentsPreview(List<String> attachments) {
    print('🖼️ [Attachments] Building preview for ${attachments.length} files');
    print('📎 [Attachments] URLs: $attachments');
    
    const maxDisplay = 5;
    final displayCount = attachments.length > maxDisplay ? maxDisplay : attachments.length;
    final remaining = attachments.length - displayCount;
    
    return Container(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: displayCount + (remaining > 0 ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == displayCount) {
            // Show "+N" badge
            return _buildMoreBadge(remaining);
          }
          
          final url = attachments[index];
          final isImage = _isImageFile(url);
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => _handleAttachmentTap(url),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 60,
                decoration: BoxDecoration(
                  color: isImage ? Colors.grey[200] : _getFileBackgroundColor(url),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _getFileBorderColor(url)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: isImage
                      ? Image.network(
                          '${ApiConfig.baseUrl}$url',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stack) => Icon(
                            Icons.broken_image,
                            color: Colors.grey[400],
                          ),
                        )
                      : Center(
                          child: Icon(
                            _getFileIconFromUrl(url),
                            size: 30,
                            color: _getFileIconColor(url),
                          ),
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildMoreBadge(int count) {
    return Container(
      width: 60,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[400]!),
      ),
      child: Center(
        child: Text(
          '+$count',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
      ),
    );
  }
  
  bool _isImageFile(String url) {
    final ext = url.toLowerCase();
    return ext.endsWith('.jpg') ||
        ext.endsWith('.jpeg') ||
        ext.endsWith('.jfif') ||
        ext.endsWith('.png') ||
        ext.endsWith('.webp') ||
        ext.endsWith('.gif') ||
        ext.endsWith('.svg');
  }
  
  IconData _getFileIconFromUrl(String url) {
    final ext = url.toLowerCase();
    
    if (ext.endsWith('.pdf')) return Icons.picture_as_pdf;
    if (ext.endsWith('.doc') || ext.endsWith('.docx')) return Icons.description;
    if (ext.endsWith('.xls') || ext.endsWith('.xlsx')) return Icons.table_chart;
    if (ext.endsWith('.ppt') || ext.endsWith('.pptx')) return Icons.slideshow;
    if (ext.endsWith('.zip') || ext.endsWith('.rar') || ext.endsWith('.7z')) return Icons.folder_zip;
    if (ext.endsWith('.mp4') || ext.endsWith('.avi') || ext.endsWith('.mov')) return Icons.video_file;
    if (ext.endsWith('.mp3') || ext.endsWith('.wav')) return Icons.audio_file;
    if (ext.endsWith('.txt') || ext.endsWith('.csv')) return Icons.article;
    
    return Icons.insert_drive_file;
  }
  
  Color _getFileBackgroundColor(String url) {
    final ext = url.toLowerCase();
    
    if (ext.endsWith('.pdf')) return Colors.red[50]!;
    if (ext.endsWith('.doc') || ext.endsWith('.docx')) return Colors.blue[50]!;
    if (ext.endsWith('.xls') || ext.endsWith('.xlsx')) return Colors.green[50]!;
    if (ext.endsWith('.ppt') || ext.endsWith('.pptx')) return Colors.orange[50]!;
    
    return Colors.grey[200]!;
  }
  
  Color _getFileBorderColor(String url) {
    final ext = url.toLowerCase();
    
    if (ext.endsWith('.pdf')) return Colors.red[200]!;
    if (ext.endsWith('.doc') || ext.endsWith('.docx')) return Colors.blue[200]!;
    if (ext.endsWith('.xls') || ext.endsWith('.xlsx')) return Colors.green[200]!;
    if (ext.endsWith('.ppt') || ext.endsWith('.pptx')) return Colors.orange[200]!;
    
    return Colors.grey[300]!;
  }
  
  Color _getFileIconColor(String url) {
    final ext = url.toLowerCase();
    
    if (ext.endsWith('.pdf')) return Colors.red[700]!;
    if (ext.endsWith('.doc') || ext.endsWith('.docx')) return Colors.blue[700]!;
    if (ext.endsWith('.xls') || ext.endsWith('.xlsx')) return Colors.green[700]!;
    if (ext.endsWith('.ppt') || ext.endsWith('.pptx')) return Colors.orange[700]!;
    
    return Colors.grey[600]!;
  }
  
  void _handleAttachmentTap(String url) {
    final isImage = _isImageFile(url);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isImage ? 'รูปภาพ' : 'ไฟล์แนบ'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isImage) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    '${ApiConfig.baseUrl}$url',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stack) => Container(
                      height: 200,
                      color: Colors.grey[200],
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.broken_image, size: 48, color: Colors.grey[400]),
                            const SizedBox(height: 8),
                            Text('ไม่สามารถโหลดรูปภาพ', style: TextStyle(color: Colors.grey[600])),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: _getFileBackgroundColor(url),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _getFileBorderColor(url), width: 2),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _getFileIconFromUrl(url),
                        size: 64,
                        color: _getFileIconColor(url),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        url.split('/').last,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ปิด'),
          ),
          ElevatedButton.icon(
            onPressed: () => _downloadFile(url),
            icon: const Icon(Icons.download),
            label: const Text('ดาวน์โหลด'),
          ),
        ],
      ),
    );
  }
  
  void _downloadFile(String url) async {
    final fullUrl = '${ApiConfig.baseUrl}$url';
    print('🔽 [Download] Opening: $fullUrl');
    
    // สำหรับ Flutter Web ใช้ window.open
    try {
      html.window.open(fullUrl, '_blank');
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('เปิดไฟล์ในแท็บใหม่แล้ว'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('❌ [Download] Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ไม่สามารถเปิดไฟล์: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(FeedbackModel.FeedbackType type) {
    switch (type) {
      case FeedbackModel.FeedbackType.suggestion:
        return Color(0xFF228B22);
      case FeedbackModel.FeedbackType.bug:
        return Color(0xFFCD5C5C);
      case FeedbackModel.FeedbackType.feature:
        return Color(0xFFDAA520);
      case FeedbackModel.FeedbackType.complaint:
        return Color(0xFFCD5C5C);
      case FeedbackModel.FeedbackType.compliment:
        return Color(0xFF228B22);
    }
  }

  // Admin History Tab - แสดง feedback ที่ rejected หรือ closed (เฉพาะ ADMIN, SUPER_ADMIN)
  Widget _buildAdminHistory() {
    return Consumer<FeedbackProvider>(
      builder: (context, feedbackProvider, child) {
        // กรองเฉพาะ feedback ที่ rejected หรือ closed (สำหรับแท็บ "ประวัติ")
        // ไม่รวม approved (เป็นสถานะชั่วคราว ต้องไปแสดงที่แท็บ "ติดตาม" แทน)
        var feedbacks = feedbackProvider.feedbacks
            .where((f) => 
                f.status == FeedbackModel.FeedbackStatus.rejected ||
                f.status == FeedbackModel.FeedbackStatus.closed)
            .toList();
        
        print('📋 [AdminHistory] Total feedbacks: ${feedbacks.length}');
        for (var f in feedbacks) {
          print('  - ${f.subject}: status=${f.status.name}, attachments=${f.attachments.length}');
        }

        if (feedbacks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'ไม่มีประวัติข้อเสนอแนะ',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'ข้อเสนอแนะที่ถูกปฏิเสธหรือปิดจะแสดงที่นี่',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(ResponsiveHelper.getCardSpacing(context)),
          itemCount: feedbacks.length,
          itemBuilder: (context, index) {
            final feedback = feedbacks[index];
            final isRejected = feedback.status == FeedbackModel.FeedbackStatus.rejected;
            
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isRejected ? Colors.red[200]! : Colors.grey[300]!,
                  width: 2,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isRejected ? Colors.red[100] : Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            isRejected ? Icons.cancel : Icons.archive,
                            color: isRejected ? Colors.red[800] : Colors.grey[700],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                feedback.subject,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  _buildTypeChip(feedback.type),
                                  const SizedBox(width: 8),
                                  _buildStatusChip(feedback.status),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Admin Menu (•••) - เฉพาะ SUPER_ADMIN/ADMIN
                        Consumer<AuthProvider>(
                          builder: (context, authProvider, child) {
                            if (authProvider.currentUser?.canManageFeedback ?? false) {
                              return PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert, size: 20),
                                tooltip: 'ตัวเลือก',
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _showEditFeedbackDialog(feedback);
                                  } else if (value == 'move_to_pending') {
                                    _moveToPending(feedback);
                                  } else if (value == 'hide') {
                                    _showHideFeedbackDialog(feedback);
                                  } else if (value == 'delete') {
                                    _showDeleteFeedbackDialog(feedback);
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit, size: 18),
                                        SizedBox(width: 8),
                                        Text('แก้ไข'),
                                      ],
                                    ),
                                  ),
                                  // แสดงตัวเลือก "ย้ายไปจัดการ" เฉพาะ rejected feedback
                                  if (isRejected)
                                    const PopupMenuItem(
                                      value: 'move_to_pending',
                                      child: Row(
                                        children: [
                                          Icon(Icons.undo, size: 18, color: Colors.blue),
                                          SizedBox(width: 8),
                                          Text('ย้ายไปจัดการ', style: TextStyle(color: Colors.blue)),
                                        ],
                                      ),
                                    ),
                                  const PopupMenuItem(
                                    value: 'hide',
                                    child: Row(
                                      children: [
                                        Icon(Icons.visibility_off, size: 18, color: Colors.orange),
                                        SizedBox(width: 8),
                                        Text('ซ่อน', style: TextStyle(color: Colors.orange)),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete, size: 18, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text('ลบ', style: TextStyle(color: Colors.red)),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 12),
                    
                    // Message
                    Text(
                      feedback.message,
                      style: const TextStyle(fontSize: 14),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Attachments Preview (ถ้ามี)
                    if (feedback.attachments.isNotEmpty) ...[
                      Container(
                        color: const Color(0xFFF1F8F1),
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '📎 ไฟล์แนบ (${feedback.attachments.length})',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildAttachmentsPreview(feedback.attachments),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    
                    // Admin Response (if any)
                    if (feedback.adminResponse != null && 
                        feedback.adminResponse!.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.admin_panel_settings, 
                                    size: 16, 
                                    color: Colors.grey[700]),
                                const SizedBox(width: 4),
                                Text(
                                  'คำตอบจากผู้ดูแล:',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              feedback.adminResponse!,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    
                    // Submitter Info
                    Row(
                      children: [
                        Icon(Icons.person, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          feedback.userName,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          _formatDateTime(feedback.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  IconData _getTypeIcon(FeedbackModel.FeedbackType type) {
    switch (type) {
      case FeedbackModel.FeedbackType.suggestion:
        return Icons.lightbulb;
      case FeedbackModel.FeedbackType.bug:
        return Icons.bug_report;
      case FeedbackModel.FeedbackType.feature:
        return Icons.new_releases;
      case FeedbackModel.FeedbackType.complaint:
        return Icons.report_problem;
      case FeedbackModel.FeedbackType.compliment:
        return Icons.thumb_up;
    }
  }

  // Status Dropdown Widget สำหรับแถบ stats
  Widget _buildStatusDropdown(FeedbackModel.Feedback feedback, AuthProvider authProvider) {
    // Helper function สำหรับดึงสี status
    Color getStatusColor(FeedbackModel.FeedbackStatus status) {
      switch (status) {
        case FeedbackModel.FeedbackStatus.pending:
          return const Color(0xFFDAA520);
        case FeedbackModel.FeedbackStatus.approved:
          return const Color(0xFF1976D2);
        case FeedbackModel.FeedbackStatus.rejected:
          return const Color(0xFFCD5C5C);
        case FeedbackModel.FeedbackStatus.inProgress:
          return const Color(0xFF1976D2);
        case FeedbackModel.FeedbackStatus.resolved:
          return const Color(0xFF228B22);
        case FeedbackModel.FeedbackStatus.closed:
          return const Color(0xFF8B4513);
      }
    }

    // Helper function สำหรับดึง icon status
    IconData getStatusIcon(FeedbackModel.FeedbackStatus status) {
      switch (status) {
        case FeedbackModel.FeedbackStatus.pending:
          return Icons.schedule;
        case FeedbackModel.FeedbackStatus.approved:
          return Icons.check_circle_outline;
        case FeedbackModel.FeedbackStatus.rejected:
          return Icons.cancel;
        case FeedbackModel.FeedbackStatus.inProgress:
          return Icons.pending_actions;
        case FeedbackModel.FeedbackStatus.resolved:
          return Icons.check_circle;
        case FeedbackModel.FeedbackStatus.closed:
          return Icons.cancel;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: getStatusColor(feedback.status).withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: getStatusColor(feedback.status),
          width: 1.5,
        ),
      ),
      child: PopupMenuButton<FeedbackModel.FeedbackStatus>(
        initialValue: feedback.status,
        tooltip: 'เปลี่ยนสถานะ',
        offset: const Offset(0, 40),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _getStatusText(feedback.status),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: getStatusColor(feedback.status),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              color: getStatusColor(feedback.status),
              size: 20,
            ),
          ],
        ),
        itemBuilder: (context) {
          final items = [
            FeedbackModel.FeedbackStatus.inProgress,
            FeedbackModel.FeedbackStatus.resolved,
            FeedbackModel.FeedbackStatus.closed,
          ];
          
          // Add current status if not in list (to prevent error)
          // ⚠️ ไม่เพิ่ม "approved" เข้าไปใน dropdown (เป็นสถานะชั่วคราว)
          if (!items.contains(feedback.status) && 
              feedback.status != FeedbackModel.FeedbackStatus.approved) {
            items.insert(0, feedback.status);
          }
          
          return items.map((status) {
            return PopupMenuItem(
              value: status,
              child: Row(
                children: [
                  Icon(
                    getStatusIcon(status),
                    color: getStatusColor(status),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _getStatusText(status),
                    style: TextStyle(
                      color: getStatusColor(status),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }).toList();
        },
        onSelected: (newStatus) {
          if (newStatus != feedback.status) {
            _updateFeedbackStatus(feedback.id, newStatus);
          }
        },
      ),
    );
  }

  // Show edit feedback dialog
  void _showEditFeedbackDialog(FeedbackModel.Feedback feedback) {
    final subjectController = TextEditingController(text: feedback.subject);
    final messageController = TextEditingController(text: feedback.message);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('แก้ไขข้อเสนอแนะ'),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: subjectController,
                decoration: const InputDecoration(
                  labelText: 'หัวข้อ',
                  border: OutlineInputBorder(),
                ),
                maxLines: 1,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: messageController,
                decoration: const InputDecoration(
                  labelText: 'รายละเอียด',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () async {
              final subject = subjectController.text.trim();
              final message = messageController.text.trim();

              if (subject.isEmpty || message.isEmpty) {
                StandardSnackbar.showWarning(context, 'กรุณากรอกข้อมูลให้ครบถ้วน');
                return;
              }

              Navigator.pop(context);

              final authProvider = context.read<AuthProvider>();
              final success = await context.read<FeedbackProvider>().editFeedback(
                    feedback.id,
                    subject: subject,
                    message: message,
                    editedBy: authProvider.currentUser?.username,
                  );

              if (mounted) {
                if (success) {
                  StandardSnackbar.showSuccess(context, 'แก้ไขข้อเสนอแนะสำเร็จ');
                } else {
                  StandardSnackbar.showError(context, 'เกิดข้อผิดพลาดในการแก้ไข');
                }
              }
            },
            child: const Text('บันทึก'),
          ),
        ],
      ),
    );
  }

  // Show delete feedback confirmation
  void _showDeleteFeedbackDialog(FeedbackModel.Feedback feedback) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.delete, color: Colors.red),
            SizedBox(width: 8),
            Text('ลบข้อเสนอแนะ'),
          ],
        ),
        content: Text('คุณต้องการลบข้อเสนอแนะ "${feedback.subject}" หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);

              final authProvider = context.read<AuthProvider>();
              final currentUser = authProvider.currentUser;
              
              final success = await context.read<FeedbackProvider>().deleteFeedback(
                feedback.id,
                deletedBy: currentUser?.username,
                adminId: currentUser?.id,
                adminUsername: currentUser?.username,
              );

              if (mounted) {
                if (success) {
                  StandardSnackbar.showSuccess(context, 'ลบข้อเสนอแนะสำเร็จ');
                } else {
                  StandardSnackbar.showError(context, 'เกิดข้อผิดพลาดในการลบ');
                }
              }
            },
            child: const Text('ลบ'),
          ),
        ],
      ),
    );
  }

  // Show edit reply dialog
  void _showEditReplyDialog(String feedbackId, FeedbackReply reply) {
    final messageController = TextEditingController(text: reply.message);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('แก้ไขความคิดเห็น'),
        content: TextField(
          controller: messageController,
          decoration: const InputDecoration(
            labelText: 'ข้อความ',
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
          maxLines: 5,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () async {
              final message = messageController.text.trim();

              if (message.isEmpty) {
                StandardSnackbar.showWarning(context, 'กรุณากรอกข้อความ');
                return;
              }

              Navigator.pop(context);

              final authProvider = context.read<AuthProvider>();
              final success =
                  await context.read<FeedbackRepliesProvider>().editReply(
                        feedbackId: feedbackId,
                        replyId: reply.id,
                        message: message,
                        editedBy: authProvider.currentUser?.username,
                      );

              if (mounted) {
                if (success) {
                  StandardSnackbar.showSuccess(context, 'แก้ไขความคิดเห็นสำเร็จ');
                } else {
                  StandardSnackbar.showError(context, 'เกิดข้อผิดพลาดในการแก้ไข');
                }
              }
            },
            child: const Text('บันทึก'),
          ),
        ],
      ),
    );
  }

  // Show delete reply confirmation
  void _showDeleteReplyDialog(String feedbackId, FeedbackReply reply) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.delete, color: Colors.red),
            SizedBox(width: 8),
            Text('ลบความคิดเห็น'),
          ],
        ),
        content: const Text('คุณต้องการลบความคิดเห็นนี้หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);

              final authProvider = context.read<AuthProvider>();
              final currentUser = authProvider.currentUser;
              
              final success =
                  await context.read<FeedbackRepliesProvider>().deleteReply(
                        feedbackId: feedbackId,
                        replyId: reply.id,
                        deletedBy: currentUser?.username,
                        adminId: currentUser?.id,
                        adminUsername: currentUser?.username,
                      );

              if (mounted) {
                if (success) {
                  StandardSnackbar.showSuccess(context, 'ลบความคิดเห็นสำเร็จ');
                } else {
                  StandardSnackbar.showError(context, 'เกิดข้อผิดพลาดในการลบ');
                }
              }
            },
            child: const Text('ลบ'),
          ),
        ],
      ),
    );
  }

  // Show hide feedback confirmation (Soft Delete - ซ่อนจากหน้าจอ)
  void _showHideFeedbackDialog(FeedbackModel.Feedback feedback) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.visibility_off, color: Colors.orange),
            SizedBox(width: 8),
            Text('ซ่อนข้อเสนอแนะ'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('คุณต้องการซ่อนข้อเสนอแนะ "${feedback.subject}" หรือไม่?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[300]!),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'ข้อมูลจะไม่แสดงในหน้าจอ แต่ยังอยู่ในระบบ',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            onPressed: () async {
              Navigator.pop(context);

              final authProvider = context.read<AuthProvider>();
              final currentUser = authProvider.currentUser;
              
              final success = await context.read<FeedbackProvider>().deleteFeedback(
                feedback.id,
                deletedBy: currentUser?.username,
                adminId: currentUser?.id,
                adminUsername: currentUser?.username,
              );

              if (mounted) {
                if (success) {
                  StandardSnackbar.showSuccess(context, 'ซ่อนข้อเสนอแนะสำเร็จ (Soft Delete)');
                } else {
                  StandardSnackbar.showError(context, 'เกิดข้อผิดพลาดในการซ่อน');
                }
              }
            },
            child: const Text('ซ่อน'),
          ),
        ],
      ),
    );
  }

  // Show hide reply confirmation (Soft Delete - ซ่อนจากหน้าจอ)
  void _showHideReplyDialog(String feedbackId, FeedbackReply reply) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.visibility_off, color: Colors.orange),
            SizedBox(width: 8),
            Text('ซ่อนความคิดเห็น'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('คุณต้องการซ่อนความคิดเห็นนี้หรือไม่?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[300]!),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'ข้อมูลจะไม่แสดงในหน้าจอ แต่ยังอยู่ในระบบ',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            onPressed: () async {
              Navigator.pop(context);

              final authProvider = context.read<AuthProvider>();
              final currentUser = authProvider.currentUser;
              
              final success =
                  await context.read<FeedbackRepliesProvider>().deleteReply(
                        feedbackId: feedbackId,
                        replyId: reply.id,
                        deletedBy: currentUser?.username,
                        adminId: currentUser?.id,
                        adminUsername: currentUser?.username,
                      );

              if (mounted) {
                if (success) {
                  StandardSnackbar.showSuccess(context, 'ซ่อนความคิดเห็นสำเร็จ (Soft Delete)');
                } else {
                  StandardSnackbar.showError(context, 'เกิดข้อผิดพลาดในการซ่อน');
                }
              }
            },
            child: const Text('ซ่อน'),
          ),
        ],
      ),
    );
  }

  // Build edited badge (clickable to show history)
  Widget _buildEditedBadge(String? editedBy, DateTime editedAt, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.orange[50],
          border: Border.all(color: Colors.orange[300]!, width: 1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.edit, size: 10, color: Colors.orange[700]),
            const SizedBox(width: 4),
            Text(
              'แก้ไขแล้ว${editedBy != null ? ' โดย $editedBy' : ''}',
              style: TextStyle(
                fontSize: 10,
                color: Colors.orange[800],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 2),
            Icon(Icons.history, size: 10, color: Colors.orange[700]),
          ],
        ),
      ),
    );
  }

  // Show edit history dialog for feedback
  void _showFeedbackHistoryDialog(String feedbackId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.history, size: 24),
            SizedBox(width: 8),
            Text('ประวัติการแก้ไข'),
          ],
        ),
        content: SizedBox(
          width: 600,
          height: 400,
          child: FutureBuilder(
            future: _fetchFeedbackHistory(feedbackId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (snapshot.hasError) {
                return Center(
                  child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'),
                );
              }
              
              final history = snapshot.data as List<dynamic>? ?? [];
              
              if (history.isEmpty) {
                return const Center(
                  child: Text('ไม่มีประวัติการแก้ไข'),
                );
              }
              
              return ListView.builder(
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final item = history[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.edit, size: 18),
                      ),
                      title: Text('แก้ไข${item['field_name']}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('โดย: ${item['edited_by']}'),
                          Text('เวลา: ${_formatDateTimeString(item['edited_at'])}'),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'เดิม: ${item['old_value'] ?? '-'}',
                              style: const TextStyle(
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text('ใหม่: ${item['new_value'] ?? '-'}'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ปิด'),
          ),
        ],
      ),
    );
  }

  // Fetch feedback history from API
  Future<List<dynamic>> _fetchFeedbackHistory(String feedbackId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/feedback/$feedbackId/history'),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'] ?? [];
    }
    
    throw Exception('Failed to load history');
  }

  // Show edit history dialog for reply
  void _showReplyHistoryDialog(String feedbackId, FeedbackReply reply) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.history, size: 24),
            SizedBox(width: 8),
            Text('ประวัติการแก้ไข'),
          ],
        ),
        content: SizedBox(
          width: 600,
          height: 400,
          child: FutureBuilder(
            future: _fetchReplyHistory(feedbackId, reply.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (snapshot.hasError) {
                return Center(
                  child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'),
                );
              }
              
              final history = snapshot.data as List<dynamic>? ?? [];
              
              if (history.isEmpty) {
                return const Center(
                  child: Text('ไม่มีประวัติการแก้ไข'),
                );
              }
              
              return ListView.builder(
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final item = history[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.edit, size: 18),
                      ),
                      title: Text('แก้ไข${item['field_name']}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('โดย: ${item['edited_by']}'),
                          Text('เวลา: ${_formatDateTimeString(item['edited_at'])}'),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'เดิม: ${item['old_value'] ?? '-'}',
                              style: const TextStyle(
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text('ใหม่: ${item['new_value'] ?? '-'}'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ปิด'),
          ),
        ],
      ),
    );
  }

  // Fetch reply history from API
  Future<List<dynamic>> _fetchReplyHistory(String feedbackId, String replyId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/feedback/$feedbackId/replies/$replyId/history'),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'] ?? [];
    }
    
    throw Exception('Failed to load reply history');
  }

  // Format datetime string (for API responses)
  String _formatDateTimeString(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }
}
