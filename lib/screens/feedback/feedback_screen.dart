import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
// import 'dart:io';
// import 'package:file_picker/file_picker.dart';
import '../../providers/feedback_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/feedback.dart' as FeedbackModel;
import '../../utils/responsive_helper.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _searchController = TextEditingController();
  
  // Form values
  FeedbackModel.FeedbackType _selectedType = FeedbackModel.FeedbackType.suggestion;
  FeedbackModel.FeedbackCategory _selectedCategory = FeedbackModel.FeedbackCategory.ui;
  FeedbackModel.FeedbackPriority _selectedPriority = FeedbackModel.FeedbackPriority.medium;
  int _rating = 5;
  List<String> _attachedFiles = [];
  
  // Filter values
  FeedbackModel.FeedbackType? _filterType;
  FeedbackModel.FeedbackStatus? _filterStatus;
  FeedbackModel.FeedbackCategory? _filterCategory;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Initialize feedback provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FeedbackProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ข้อเสนอแนะและความคิดเห็น'),
        backgroundColor: Color(0xFF228B22),
        foregroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.home, color: Colors.white),
          onPressed: () => context.go('/dashboard'),
          tooltip: 'กลับหน้าหลัก',
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.feedback),
              text: 'ส่งข้อเสนอแนะ',
            ),
            Tab(
              icon: Icon(Icons.history),
              text: 'ประวัติข้อเสนอแนะ',
            ),
            Tab(
              icon: Icon(Icons.analytics),
              text: 'สถิติและวิเคราะห์',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFeedbackForm(),
          _buildFeedbackHistory(),
          _buildAnalyticsDashboard(),
        ],
      ),
    );
  }

  Widget _buildFeedbackForm() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(ResponsiveHelper.getCardSpacing(context)),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(
                      Icons.feedback_outlined,
                      size: 64,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'เราต้องการรับฟังความคิดเห็นจากคุณ',
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'ข้อเสนอแนะของคุณจะช่วยให้เราปรับปรุงระบบให้ดียิ่งขึ้น',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Feedback Type
            Text(
              'ประเภทข้อเสนอแนะ',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: FeedbackModel.FeedbackType.values.map((type) {
                    return RadioListTile<FeedbackModel.FeedbackType>(
                      title: Text(_getFeedbackTypeText(type)),
                      subtitle: Text(_getFeedbackTypeDescription(type)),
                      value: type,
                      groupValue: _selectedType,
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
            Text(
              'หมวดหมู่',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
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
            
            const SizedBox(height: 24),
            
            // Contact Info
            Text(
              'ข้อมูลติดต่อ',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'อีเมล',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'กรุณากรอกอีเมล';
                      }
                      if (!value.contains('@')) {
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
                    decoration: const InputDecoration(
                      labelText: 'เบอร์โทรศัพท์',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'กรุณากรอกเบอร์โทรศัพท์';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Subject
            Text(
              'หัวข้อ',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _subjectController,
              decoration: const InputDecoration(
                labelText: 'หัวข้อข้อเสนอแนะ',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
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
            Text(
              'รายละเอียด',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _messageController,
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
            
            // Priority
            Text(
              'ระดับความสำคัญ',
              style: Theme.of(context).textTheme.titleLarge,
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
            
            // File Attachments
            Text(
              'แนบไฟล์ (ถ้ามี)',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _pickFiles,
                      icon: const Icon(Icons.attach_file),
                      label: const Text('เลือกไฟล์'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF8B4513),
                        foregroundColor: Colors.white,
                      ),
                    ),
                    if (_attachedFiles.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      ...(_attachedFiles.map((file) => ListTile(
                        leading: const Icon(Icons.insert_drive_file),
                        title: Text(file.split('/').last),
                        trailing: IconButton(
                          icon: const Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _attachedFiles.remove(file);
                            });
                          },
                        ),
                      ))),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Rating
            Text(
              'คะแนนความพึงพอใจ',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'ให้คะแนนความพึงพอใจต่อระบบ',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
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
                  return ElevatedButton(
                    onPressed: feedbackProvider.isLoading ? null : _submitFeedback,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: feedbackProvider.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('ส่งข้อเสนอแนะ'),
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
        var feedbacks = feedbackProvider.feedbacks;
        
        // Apply filters
        if (_filterType != null) {
          feedbacks = feedbacks.where((f) => f.type == _filterType).toList();
        }
        if (_filterStatus != null) {
          feedbacks = feedbacks.where((f) => f.status == _filterStatus).toList();
        }
        if (_filterCategory != null) {
          feedbacks = feedbacks.where((f) => f.category == _filterCategory).toList();
        }
        if (_searchQuery.isNotEmpty) {
          feedbacks = feedbacks.where((f) => 
            f.subject.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            f.message.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            f.userName.toLowerCase().contains(_searchQuery.toLowerCase())
          ).toList();
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
                  
                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FilterChip(
                          label: Text(_filterType?.toString().split('.').last ?? 'ประเภท'),
                          selected: _filterType != null,
                          onSelected: (selected) {
                            _showTypeFilter();
                          },
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: Text(_filterStatus?.toString().split('.').last ?? 'สถานะ'),
                          selected: _filterStatus != null,
                          onSelected: (selected) {
                            _showStatusFilter();
                          },
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: Text(_filterCategory?.toString().split('.').last ?? 'หมวดหมู่'),
                          selected: _filterCategory != null,
                          onSelected: (selected) {
                            _showCategoryFilter();
                          },
                        ),
                        const SizedBox(width: 8),
                        if (_filterType != null || _filterStatus != null || _filterCategory != null)
                          ActionChip(
                            label: const Text('ล้างตัวกรอง'),
                            onPressed: () {
                              setState(() {
                                _filterType = null;
                                _filterStatus = null;
                                _filterCategory = null;
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
                            _searchQuery.isNotEmpty || _filterType != null || _filterStatus != null || _filterCategory != null
                                ? 'ไม่พบข้อเสนอแนะที่ตรงกับเงื่อนไข'
                                : 'ยังไม่มีประวัติข้อเสนอแนะ',
                            style: Theme.of(context).textTheme.titleLarge,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getCardSpacing(context)),
                      itemCount: feedbacks.length,
                      itemBuilder: (context, index) {
            final feedback = feedbacks[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            feedback.subject,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        _buildStatusChip(feedback.status),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildTypeChip(feedback.type),
                        const SizedBox(width: 8),
                        _buildCategoryChip(feedback.category),
                        const Spacer(),
                        Row(
                          children: List.generate(5, (starIndex) {
                            return Icon(
                              starIndex < feedback.rating ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                              size: 16,
                            );
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      feedback.message,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.person, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          feedback.userName,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          _formatDateTime(feedback.createdAt),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    if (feedback.adminResponse != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Color(0xFF228B22).withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.admin_panel_settings, size: 16, color: Color(0xFF228B22)),
                                const SizedBox(width: 4),
                                Text(
                                  'การตอบกลับจากผู้ดูแลระบบ',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF228B22),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              feedback.adminResponse!,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            if (feedback.respondedAt != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                'ตอบกลับเมื่อ: ${_formatDateTime(feedback.respondedAt!)}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ],
                        ),
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
            ...FeedbackModel.FeedbackStatus.values.map((status) => ListTile(
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

  Widget _buildStatusChip(FeedbackModel.FeedbackStatus status) {
    Color color;
    switch (status) {
      case FeedbackModel.FeedbackStatus.pending:
        color = Color(0xFFDAA520);
        break;
      case FeedbackModel.FeedbackStatus.inProgress:
        color = Color(0xFF228B22);
        break;
      case FeedbackModel.FeedbackStatus.resolved:
        color = Color(0xFF228B22);
        break;
      case FeedbackModel.FeedbackStatus.closed:
        color = Color(0xFF8B4513);
        break;
    }
    
    return Chip(
      label: Text(
        _getStatusText(status),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
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

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final feedbackProvider = context.read<FeedbackProvider>();

    final feedback = FeedbackModel.Feedback(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: authProvider.currentUser?.phoneNumber ?? 'anonymous',
      userName: authProvider.currentUser?.fullName ?? 'ผู้ใช้ไม่ระบุชื่อ',
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      type: _selectedType,
      category: _selectedCategory,
      subject: _subjectController.text.trim(),
      message: _messageController.text.trim(),
      rating: _rating,
      attachments: _attachedFiles,
      priority: _selectedPriority,
      createdAt: DateTime.now(),
    );

    final success = await feedbackProvider.addFeedback(feedback);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ส่งข้อเสนอแนะเรียบร้อยแล้ว ขอบคุณสำหรับความคิดเห็น'),
            backgroundColor: Color(0xFF228B22),
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
        });
        
        // Switch to history tab
        _tabController.animateTo(1);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('เกิดข้อผิดพลาดในการส่งข้อเสนอแนะ กรุณาลองใหม่อีกครั้ง'),
            backgroundColor: Color(0xFFCD5C5C),
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
        return 'รอดำเนินการ';
      case FeedbackModel.FeedbackStatus.inProgress:
        return 'กำลังดำเนินการ';
      case FeedbackModel.FeedbackStatus.resolved:
        return 'แก้ไขแล้ว';
      case FeedbackModel.FeedbackStatus.closed:
        return 'ปิดเรื่อง';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
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

  Future<void> _pickFiles() async {
    // File picker disabled for web compatibility
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('การแนบไฟล์จะเปิดใช้งานในเวอร์ชันถัดไป')),
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
              Card(
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
              
              const SizedBox(height: 24),
              
              // Summary Cards
              Row(
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
              
              const SizedBox(height: 16),
              
              // Status Distribution
              Text(
                'สถานะข้อเสนอแนะ',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Row(
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
              
              const SizedBox(height: 24),
              
              // Type Distribution
              Text(
                'ประเภทข้อเสนอแนะ',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Column(
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
              
              const SizedBox(height: 24),
              
              // Recent Activity
              Text(
                'กิจกรรมล่าสุด',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: feedbackProvider.feedbacks.take(3).map((feedback) {
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
                        subtitle: Text('${feedback.userName} • ${_formatDateTime(feedback.createdAt)}'),
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

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
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
}
