import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
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
  
  // Form values
  FeedbackModel.FeedbackType _selectedType = FeedbackModel.FeedbackType.suggestion;
  FeedbackModel.FeedbackCategory _selectedCategory = FeedbackModel.FeedbackCategory.ui;
  int _rating = 5;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
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
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.home_rounded, size: 28),
            color: Color(0xFF8B4513),
            onPressed: () => context.go('/dashboard'),
            tooltip: 'หน้าแรก',
          ),
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
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFeedbackForm(),
          _buildFeedbackHistory(),
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
        final feedbacks = feedbackProvider.feedbacks;
        
        if (feedbacks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.history,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  'ยังไม่มีประวัติข้อเสนอแนะ',
                  style: Theme.of(context).textTheme.titleLarge,
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
        );
      },
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
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildTypeChip(FeedbackModel.FeedbackType type) {
    return Chip(
      label: Text(
        _getFeedbackTypeText(type),
        style: const TextStyle(fontSize: 12),
      ),
      backgroundColor: Color(0xFF228B22).withOpacity(0.1),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildCategoryChip(FeedbackModel.FeedbackCategory category) {
    return Chip(
      label: Text(
        _getFeedbackCategoryText(category),
        style: const TextStyle(fontSize: 12),
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
          _rating = 5;
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
}
