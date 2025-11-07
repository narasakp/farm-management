import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart' as provider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/production_auth_provider.dart';
import '../../providers/rbac_provider.dart';
import '../../providers/farm_provider.dart';
import '../../providers/survey_provider.dart';
import '../../providers/financial_provider.dart';
import '../../providers/production_provider.dart';
import '../../utils/responsive_helper.dart';
import '../../widgets/app_drawer.dart';
import '../../services/search_service.dart';
import '../../widgets/app_bars/standard_app_bar.dart';
import '../../config/admin_navigation_config.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  bool _showAllMenus = false; // ✅ สำหรับแสดง/ซ่อนเมนูทั้งหมดบน mobile
  String _searchQuery = '';
  String _selectedCategory = 'ทั้งหมด';
  SearchResults? _searchResults;
  bool _isLoadingSearch = false;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final farmProvider = provider.Provider.of<FarmProvider>(context, listen: false);
    final surveyProvider = provider.Provider.of<SurveyProvider>(context, listen: false);
    await farmProvider.loadSampleData();
    await surveyProvider.loadSurveys();
    
    // Load RBAC permissions (รอให้ auth state พร้อมก่อน)
    final container = ProviderScope.containerOf(context);
    final authState = container.read(productionAuthProvider);
    if (authState.isAuthenticated && authState.accessToken != null) {
      final rbacNotifier = container.read(rbacProvider.notifier);
      await rbacNotifier.loadPermissions();
    }
  }
  
  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = null;
        _isLoadingSearch = false;
      });
      return;
    }
    
    setState(() {
      _isLoadingSearch = true;
    });
    
    final authState = ref.read(productionAuthProvider);
    if (authState.accessToken != null) {
      final results = await SearchService.search(
        query,
        authState.accessToken!,
        category: _selectedCategory,
      );
      
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isLoadingSearch = false;
        });
      }
    } else {
      setState(() {
        _isLoadingSearch = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ ตรวจสอบ Authentication State
    final authState = ref.watch(productionAuthProvider);
    
    // ✅ ถ้า Session หมดอายุ redirect ไป login
    if (!authState.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/login');
      });
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: const AppDrawer(), // ✅ แสดงเมื่อ authenticated เท่านั้น
      appBar: StandardAppBar(
        type: AppBarType.root,  // ระดับ 0: Dashboard (Root screen)
        title: 'แดชบอร์ด',
        showSearch: false,  // ซ่อนไอคอนค้นหา (มี search bar ในหน้าอยู่แล้ว)
        showNotifications: false,
      ),
      body: Container(
        color: Colors.white,
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: SingleChildScrollView(
            padding: ResponsiveHelper.getScreenPadding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              // Header with greeting
              _buildHeader(),
              SizedBox(height: ResponsiveHelper.getCardSpacing(context)),
              
              // Search Results (แสดงเมื่อมีการค้นหา)
              if (_isSearching) ...[
                _buildSearchResults(),
                SizedBox(height: ResponsiveHelper.getCardSpacing(context)),
              ],
              
              // สถิติรวม - Desktop Style (ซ่อนเมื่อมีการค้นหา)
              if (!_isSearching) Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'สถิติรวม',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  SizedBox(height: ResponsiveHelper.getCardSpacing(context)),
                      provider.Consumer<SurveyProvider>(
                        builder: (context, surveyProvider, _) {
                          final stats = surveyProvider.getSurveyStatistics();
                          final totalAnimals = stats['totalAnimals'] ?? 0;
                          final totalFarms = stats['totalSurveys'] ?? 0;
                          
                          return ResponsiveLayout(
                            mobile: provider.Consumer2<FinancialProvider, ProductionProvider>(
                              builder: (context, financialProvider, productionProvider, _) {
                                // คำนวณข้อมูล
                                final totalIncome = financialProvider.getTotalIncome('current_user');
                                final formattedIncome = '฿${(totalIncome / 1000).toStringAsFixed(0)}K';
                                
                                final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
                                final recentProduction = productionProvider.productionRecords
                                  .where((record) => record.date.isAfter(thirtyDaysAgo))
                                  .toList();
                                
                                double totalProduction = 0;
                                for (var record in recentProduction) {
                                  totalProduction += record.quantity;
                                }
                                final formattedProduction = '${totalProduction.toStringAsFixed(0)}';
                                
                                return Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildStatCardEmoji(
                                            'ปศุสัตว์',
                                            totalAnimals.toString(),
                                            '🐂',
                                            Colors.blue,
                                            onTap: () => context.go('/livestock-management'),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: _buildStatCardEmoji(
                                            'เกษตรกร',
                                            totalFarms.toString(),
                                            '👨‍🌾',
                                            Colors.green,
                                            onTap: () => context.go('/survey-list'),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildStatCardEmoji(
                                            'ผลผลิต',
                                            formattedProduction,
                                            '📦',
                                            const Color(0xFF4682B4),
                                            onTap: () => context.go('/production-management'),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: _buildStatCardEmoji(
                                            'รายรับ',
                                            formattedIncome,
                                            '💰',
                                            const Color(0xFFDAA520),
                                            onTap: () => context.go('/financial'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            ),
                            tablet: provider.Consumer2<FinancialProvider, ProductionProvider>(
                              builder: (context, financialProvider, productionProvider, _) {
                                // คำนวณข้อมูลเดียวกับ desktop
                                final totalIncome = financialProvider.getTotalIncome('current_user');
                                final formattedIncome = '฿${(totalIncome / 1000).toStringAsFixed(0)}K';
                                
                                final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
                                final recentProduction = productionProvider.productionRecords
                                  .where((record) => record.date.isAfter(thirtyDaysAgo))
                                  .toList();
                                
                                double totalProduction = 0;
                                for (var record in recentProduction) {
                                  totalProduction += record.quantity;
                                }
                                final formattedProduction = '${totalProduction.toStringAsFixed(0)}';
                                
                                return Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildStatCardEmoji(
                                            'ปศุสัตว์ทั้งหมด',
                                            totalAnimals.toString(),
                                            '🐂',
                                            const Color(0xFF8B4513),
                                            onTap: () => context.go('/livestock-management'),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: _buildStatCardEmoji(
                                            'เกษตรกรทั้งหมด',
                                            totalFarms.toString(),
                                            '👨‍🌾',
                                            const Color(0xFF228B22),
                                            onTap: () => context.go('/survey-list'),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: _buildStatCard(
                                            'รายการซื้อขาย',
                                            '12',
                                            Icons.storefront,
                                            const Color(0xFFDAA520),
                                            onTap: () => context.go('/trading-list'),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildStatCard(
                                            'รายการขนส่ง',
                                            '8',
                                            Icons.local_shipping,
                                            const Color(0xFF4682B4),
                                            onTap: () => context.go('/transport-list'),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: _buildStatCardEmoji(
                                            'ผลผลิตรวม',
                                            formattedProduction,
                                            '📦',
                                            const Color(0xFF9C27B0),
                                            onTap: () => context.go('/production-management'),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: _buildStatCardEmoji(
                                            'รายรับรวม',
                                            formattedIncome,
                                            '💰',
                                            const Color(0xFFDAA520),
                                            onTap: () => context.go('/financial'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            ),
                        desktop: provider.Consumer2<FinancialProvider, ProductionProvider>(
                          builder: (context, financialProvider, productionProvider, _) {
                            // คำนวณรายรับรวม (ของผู้ login)
                            final totalIncome = financialProvider.getTotalIncome('current_user');
                            final formattedIncome = '฿${totalIncome.toStringAsFixed(0)}';
                            
                            // คำนวณผลผลิตรวม (ของผู้ login) - รวม 30 วันล่าสุด
                            final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
                            final recentProduction = productionProvider.productionRecords
                              .where((record) => record.date.isAfter(thirtyDaysAgo))
                              .toList();
                            
                            double totalProduction = 0;
                            for (var record in recentProduction) {
                              totalProduction += record.quantity;
                            }
                            final formattedProduction = '${totalProduction.toStringAsFixed(0)} กก.';
                            
                            return Row(
                              children: [
                                Expanded(
                                  child: _buildStatCardEmoji(
                                    'ปศุสัตว์ทั้งหมด',
                                    totalAnimals.toString(),
                                    '🐂',
                                    const Color(0xFF8B4513), // Brown
                                    onTap: () => context.go('/livestock-management'),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: _buildStatCardEmoji(
                                    'เกษตรกรทั้งหมด',
                                    totalFarms.toString(),
                                    '👨‍🌾',
                                    const Color(0xFF228B22), // Forest Green
                                    onTap: () => context.go('/survey-list'),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: _buildStatCard(
                                    'รายการซื้อขาย',
                                    '12',
                                    Icons.storefront,
                                    const Color(0xFFDAA520), // Golden Rod
                                    onTap: () => context.go('/trading-list'),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: _buildStatCard(
                                    'รายการขนส่ง',
                                    '8',
                                    Icons.local_shipping,
                                    const Color(0xFF4682B4), // Steel Blue
                                    onTap: () => context.go('/transport-list'),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: _buildStatCardEmoji(
                                    'ผลผลิตรวม',
                                    formattedProduction,
                                    '📦',
                                    const Color(0xFF9C27B0), // Purple
                                    onTap: () => context.go('/production-management'),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: _buildStatCardEmoji(
                                    'รายรับรวม',
                                    formattedIncome,
                                    '💰',
                                    const Color(0xFFDAA520), // Golden
                                    onTap: () => context.go('/financial'),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      );
                        },
                      ),
                    ],
                  ),
              SizedBox(height: ResponsiveHelper.getCardSpacing(context)),
              // เมนูหลัก - แสดงแบบ Responsive
              Text(
                ResponsiveHelper.isMobile(context) ? '🔥 เมนูด่วน' : 'เมนูหลัก',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              SizedBox(height: ResponsiveHelper.getCardSpacing(context)),
              ResponsiveGrid(
                mobileColumns: 3,
                tabletColumns: 4,
                desktopColumns: 6,
                spacing: ResponsiveHelper.getCardSpacing(context),
                children: _getMenuCards(context),
              ),
              
              // ✅ ปุ่ม "ดูเมนูทั้งหมด" สำหรับ Mobile (จัดกลาง)
              if (ResponsiveHelper.isMobile(context)) ...[
                SizedBox(height: ResponsiveHelper.getCardSpacing(context)),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _showAllMenus = !_showAllMenus;
                      });
                    },
                    icon: Icon(_showAllMenus ? Icons.expand_less : Icons.menu_open),
                    label: Text(_showAllMenus ? 'ซ่อนเมนู' : 'ดูเมนูทั้งหมด'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF228B22),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  // Method to get menu cards based on screen size WITH RBAC
  List<Widget> _getMenuCards(BuildContext context) {
    final bool isMobile = ResponsiveHelper.isMobile(context);
    final dashPerms = ref.watch(dashboardPermissionsProvider);
    
    // Build all possible cards with permission checks
    final List<Widget> allPossibleCards = [];
    
    // Survey (officers only)
    if (dashPerms.canManageSurveys || dashPerms.canViewSurveys) {
      allPossibleCards.add(_buildActionCard(
        '📋',
        'สำรวจปศุสัตว์',
        'แบบฟอร์มสำรวจดิจิทัล',
        () => context.go('/survey'),
        backgroundColor: const Color(0xFF8B4513),
      ));
    }
    
    // Survey Statistics
    if (dashPerms.canViewSurveys) {
      allPossibleCards.add(_buildActionCard(
        '📊',
        'สถิติการสำรวจ',
        'รายงานและสถิติ',
        () => context.go('/survey-list'),
        backgroundColor: const Color(0xFF228B22),
      ));
    }
    
    // Livestock
    if (dashPerms.canManageLivestock || dashPerms.canViewLivestock) {
      allPossibleCards.add(_buildActionCard(
        '🐮',
        'จัดการปศุสัตว์',
        'บันทึกข้อมูลสัตว์',
        () => context.go('/livestock-management'),
        backgroundColor: const Color(0xFFDAA520),
      ));
    }
    
    // Market Screen (New E-commerce Style)
    if (dashPerms.canManageTrading || dashPerms.canViewTrading) {
      allPossibleCards.add(_buildActionCard(
        '🐄',
        'ตลาดนัดปศุสัตว์',
        'ซื้อ-ขายแบบตลาดนัด',
        () => context.go('/market'),
        backgroundColor: const Color(0xFF228B22),
      ));
    }
    
    // Social Commerce Analytics
    if (dashPerms.canManageTrading || dashPerms.canViewTrading) {
      allPossibleCards.add(_buildActionCard(
        '📊💰',
        'Social Analytics',
        'วิเคราะห์การขายออนไลน์',
        () => context.go('/social-analytics'),
        backgroundColor: const Color(0xFF9C27B0), // Purple
      ));
    }
    
    // Trading List (Original) - Moved after Social Analytics
    if (dashPerms.canManageTrading || dashPerms.canViewTrading) {
      allPossibleCards.add(_buildActionCard(
        '🏪',
        'ตลาดออนไลน์',
        'รายการซื้อ-ขายปศุสัตว์',
        () => context.go('/trading-list'),
        backgroundColor: const Color(0xFF8B4513),
      ));
    }
    
    // Production Management (moved between Social Analytics and Finance)
    if (dashPerms.canManageLivestock || dashPerms.canViewLivestock) {
      allPossibleCards.add(_buildActionCard(
        '📦',
        'จัดการการผลิต',
        'บันทึกผลผลิตและคุณภาพ',
        () => context.go('/production-management'),
        backgroundColor: const Color(0xFF8B4513),
      ));
    }
    
    // Webboard (Q&A Forum) - Available for all authenticated users (all 9 roles)
    // Only show if user is logged in
    final authState = ref.watch(productionAuthProvider);
    if (authState.isAuthenticated) {
      allPossibleCards.add(_buildActionCard(
        '💬',
        'กระทู้ ถาม - ตอบ',
        'เว็บบอร์ดแลกเปลี่ยนความรู้',
        () => context.go('/webboard'),
        backgroundColor: const Color(0xFF9C27B0), // Purple
      ));
    }
    
    // Finance (moved after Production Management)
    if (dashPerms.canManageFinance) {
      allPossibleCards.add(_buildActionCard(
        '💰',
        'การเงิน',
        'บันทึกรายรับ-รายจ่าย',
        () => context.go('/financial'),
        backgroundColor: const Color(0xFF4682B4),
      ));
    }
    
    // Quick access for mobile = first 6 cards
    final quickAccessCards = allPossibleCards.take(6).toList();
    
    // Desktop/Tablet: Add more cards if has permissions
    if (!isMobile) {
      // Farm List
      if (dashPerms.canManageFarms || dashPerms.canViewFarms) {
        allPossibleCards.add(_buildActionCard(
          '📋',
          'ทะเบียนฟาร์ม',
          'จัดการข้อมูลฟาร์ม',
          () => context.go('/farm-list'),
          backgroundColor: const Color(0xFFDAA520),
        ));
      }
      
      // Transport
      if (dashPerms.canManageTransport || dashPerms.canBookTransport) {
        allPossibleCards.add(_buildActionCard(
          '🚛',
          'ขนส่ง',
          'จองรถขนส่งสัตว์',
          () => context.go('/transport-list'),
          backgroundColor: const Color(0xFF4682B4),
        ));
      }
      
      // Farmer Groups
      if (dashPerms.canManageGroups || dashPerms.canViewGroups) {
        allPossibleCards.add(_buildActionCard(
          '🌾👨‍🌾',
          'กลุ่มเกษตรกร',
          'จัดการกลุ่มชุมชน',
          () => context.go('/farmer-group'),
          backgroundColor: const Color(0xFF8B4513),
        ));
      }
      
      // Reports
      if (dashPerms.canViewReports) {
        allPossibleCards.add(_buildActionCard(
          '📈',
          'รายงานโปรเจกต์',
          'ติดตามความคืบหน้า',
          () => context.go('/project-report'),
          backgroundColor: const Color(0xFF228B22),
        ));
      }
      
      // Research
      if (dashPerms.canManageResearch) {
        allPossibleCards.add(_buildActionCard(
          '🔬',
          'วิจัยและพัฒนา',
          'โครงการวิจัยและนวัตกรรม',
          () => context.go('/research-development'),
          backgroundColor: const Color(0xFF4682B4),
        ));
      }
      
      // ❌ REMOVED: Coming Soon features ที่ไม่ควรแสดงเมื่อไม่มี permissions
      // แก้ปัญหา: Social Login users เห็นแค่ 4 cards เมื่อยังไม่มี permissions โหลด
      // Cards เหล่านี้จะกลับมาเมื่อพัฒนา features เสร็จและมี permission control
      
      
      // Admin Cards (Super Admin only) - ใช้ centralized config
      // ย้ายมาท้ายสุด (หลัง "จัดการอาหารสัตว์")
      if (dashPerms.canAccessAdminDashboard) {
        final adminCards = AdminNavigationConfig.getDashboardCards();
        for (final item in adminCards) {
          allPossibleCards.add(_buildActionCard(
            item.emoji,
            item.label,
            item.description,
            () => context.go(item.route),
            backgroundColor: item.color,
          ));
        }
      }
      
      // Contact Admin Card (Public - ทุกคนเข้าถึงได้)
      // ย้ายมาท้ายสุด (หลัง RBAC Dashboard)
      allPossibleCards.add(_buildActionCard(
        '📞',
        'ติดต่อผู้ดูแลระบบ',
        'ข้อมูลการติดต่อและช่องทางสนับสนุน',
        () => context.go('/contact-admin'),
        backgroundColor: const Color(0xFF1976D2), // Blue
      ));
    }
    
    // ✅ Return based on screen size และ _showAllMenus state
    return (isMobile && !_showAllMenus) ? quickAccessCards : allPossibleCards;
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: color),
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
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCardEmoji(String title, String value, String emoji, Color color, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
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
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final now = DateTime.now();
    final dateString = '${now.day}/${now.month}/${now.year}';
    final authState = ref.watch(productionAuthProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Greeting
        Text(
          authState.user != null 
            ? 'สวัสดี, ${authState.user!['displayName'] ?? authState.user!['display_name'] ?? 'เกษตรกร'}!'
            : 'สวัสดี, เกษตรกร!',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          dateString,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Search Bar (ยกมาจาก Card)
        _buildSearchBar(),
      ],
    );
  }
  
  Widget _buildSearchBar() {
    return Column(
      children: [
        // Search Input
        Container(
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF228B22).withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF228B22).withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                Icon(
                  Icons.search,
                  size: 28,
                  color: const Color(0xFF228B22).withOpacity(0.7),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _isSearching = value.isNotEmpty;
                        _searchQuery = value;
                      });
                      _performSearch(value);
                    },
                    decoration: InputDecoration(
                      hintText: 'ค้นหา... (ชื่อสัตว์, เกษตรกร, ธุรกรรม)',
                      hintStyle: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w400,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                if (_searchQuery.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        _isSearching = false;
                        _searchQuery = '';
                      });
                    },
                  )
                else
                  const SizedBox(width: 16),
              ],
            ),
          ),
        
        const SizedBox(height: 12),
        
        // Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildQuickFilterChip('ทั้งหมด', Icons.apps),
              const SizedBox(width: 8),
              _buildQuickFilterChip('ปศุสัตว์', Icons.pets),
              const SizedBox(width: 8),
              _buildQuickFilterChip('เกษตรกร', Icons.person),
              const SizedBox(width: 8),
              _buildQuickFilterChip('ธุรกรรม', Icons.payment),
              const SizedBox(width: 8),
              _buildQuickFilterChip('ฟาร์ม', Icons.home_work),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildQuickFilterChip(String label, IconData icon) {
    final isSelected = _selectedCategory == label;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedCategory = label;
          if (_searchQuery.isEmpty) {
            _isSearching = true;
            _searchQuery = ' '; // Trigger search with space
          }
        });
        // Re-search with new category
        if (_searchQuery.isNotEmpty) {
          _performSearch(_searchQuery);
        }
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected 
              ? const Color(0xFF228B22)
              : const Color(0xFF228B22).withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF228B22).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : const Color(0xFF228B22),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF228B22),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(String emoji, String title, String subtitle, VoidCallback onTap, {Color? backgroundColor}) {
    // 4-color palette rotation
    final colors = [
      const Color(0xFF8B4513), // Brown
      const Color(0xFF228B22), // Forest Green  
      const Color(0xFFDAA520), // Golden Rod
      const Color(0xFF4682B4), // Steel Blue
    ];
    
    final colorIndex = title.hashCode.abs() % colors.length;
    final cardColor = backgroundColor ?? colors[colorIndex];
    final isMobile = ResponsiveHelper.isMobile(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isVerySmall = screenWidth < 400; // iPhone SE และเล็กกว่า
    
    return Card(
      elevation: isMobile ? 1 : 4,
      shadowColor: cardColor.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
      ),
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                cardColor.withOpacity(0.12),
                cardColor.withOpacity(0.06),
              ],
            ),
            borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
            border: Border.all(
              color: cardColor.withOpacity(0.25),
              width: 1,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isVerySmall ? 4 : (isMobile ? 6 : 12),
              vertical: isVerySmall ? 8 : (isMobile ? 10 : 14),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // ✅ Emoji (เล็กลงสำหรับ iPhone SE)
                Text(
                  emoji,
                  style: TextStyle(
                    fontSize: isVerySmall ? 20 : (isMobile ? 22 : 28),
                  ),
                ),
                SizedBox(height: isVerySmall ? 4 : (isMobile ? 5 : 8)),
                // ✅ Title (เล็กลงและจำกัดบรรทัด)
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isVerySmall ? 10 : (isMobile ? 11 : 14),
                    fontWeight: FontWeight.w700,
                    color: cardColor.withOpacity(0.9),
                    height: 1.1,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (!isMobile) ...[
                  const SizedBox(height: 4),
                  // ✅ Subtitle (เฉพาะ desktop)
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    final queryText = _searchQuery.trim().isEmpty ? '' : '"$_searchQuery"';
    final categoryText = _selectedCategory != 'ทั้งหมด' ? ' ใน $_selectedCategory' : '';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          queryText.isEmpty 
              ? 'ผลการค้นหา$categoryText'
              : 'ผลการค้นหา: $queryText$categoryText',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        // Category badge
        if (_selectedCategory != 'ทั้งหมด')
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF228B22),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'หมวดหมู่: $_selectedCategory',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        const SizedBox(height: 16),
        
        // Loading
        if (_isLoadingSearch)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          )
        // Results
        else if (_searchResults != null && _searchResults!.total > 0)
          ..._searchResults!.all.map((result) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getResultColor(result.type),
                    child: Icon(
                      _getResultIcon(result.type),
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    result.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(result.subtitle),
                      const SizedBox(height: 2),
                      Text(
                        result.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _handleResultTap(result),
                ),
              );
            }).toList()
        // No results
        else if (_searchResults != null && _searchResults!.total == 0)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.search_off,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'ไม่พบผลการค้นหา',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'ลองค้นหาด้วยคำค้นหาอื่น หรือเปลี่ยนหมวดหมู่',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Color _getResultColor(String type) {
    switch (type) {
      case 'livestock':
        return const Color(0xFF8B4513); // Brown
      case 'survey':
        return const Color(0xFF228B22); // Green
      case 'transaction':
        return const Color(0xFFDAA520); // Gold
      case 'user':
        return const Color(0xFF4682B4); // Steel Blue
      case 'audit':
        return const Color(0xFFFF8C00); // Dark Orange
      case 'auth':
        return const Color(0xFF9370DB); // Medium Purple
      default:
        return Colors.grey;
    }
  }
  
  IconData _getResultIcon(String type) {
    switch (type) {
      case 'livestock':
        return Icons.pets;
      case 'survey':
        return Icons.person;
      case 'transaction':
        return Icons.payment;
      case 'user':
        return Icons.account_circle;
      case 'audit':
        return Icons.history;
      case 'auth':
        return Icons.login;
      default:
        return Icons.search;
    }
  }
  
  void _handleResultTap(SearchResult result) {
    switch (result.type) {
      case 'livestock':
        // Navigate to livestock management
        context.go('/livestock-management');
        break;
      case 'survey':
        // Navigate to survey list
        context.go('/survey-list');
        break;
      case 'transaction':
        // Navigate to trading list
        context.go('/trading-list');
        break;
    }
  }

  // ❌ REMOVED: _showComingSoon method (ไม่มีใครใช้แล้วหลังลบ Coming Soon cards)
}
