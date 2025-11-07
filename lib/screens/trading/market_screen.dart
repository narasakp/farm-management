import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart' as provider_pkg;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/snackbar_helper.dart';
import '../../utils/price_formatter.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:html' as html;
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import '../../utils/notification_helper.dart';
import '../../services/storage_service.dart';
import '../../providers/trading_provider.dart';
import '../../providers/livestock_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/production_auth_provider.dart';
import '../../models/trading.dart';
import '../../models/livestock.dart';
import '../../widgets/app_bars/standard_app_bar.dart';
import '../../widgets/shopee_image_gallery.dart';
import '../../widgets/cors_image.dart';
import '../queue/markets_list_tab.dart';
import '../queue/my_bookings_tab.dart';

class MarketScreen extends ConsumerStatefulWidget {
  const MarketScreen({super.key});

  @override
  ConsumerState<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends ConsumerState<MarketScreen> {
  String _selectedCategory = 'ทั้งหมด';
  String _sortBy = 'ยอดนิยม';
  String _searchQuery = '';  // ✅ เพิ่ม search query
  final TextEditingController _searchController = TextEditingController();  // ✅ เพิ่ม search controller
  
  // Pagination - Shopee/Lazada style
  int _currentPage = 1;
  final int _itemsPerPage = 60;  // 6 columns x 10 rows
  
  // GlobalKey to prevent TabBarView rebuild issues
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  // Dialog state - prevent click-through to background
  bool _isCreatingListing = false;

  final List<String> _categories = [
    'ทั้งหมด',
    'โค',
    'กระบือ', 
    'สุกร',
    'ไก่',
    'เป็ด',
    'แพะ',
    'แกะ'
  ];

  final List<String> _sortOptions = [
    'ล่าสุด',
    'ราคาต่ำ-สูง',
    'ราคาสูง-ต่ำ',
    'ยอดนิยม'
  ];

  @override
  void initState() {
    super.initState();
    
    // ✅ Load data with proper async execution
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        final tradingProvider = context.read<TradingProvider>();
        final livestockProvider = context.read<LivestockProvider>();
        
        // 1. Set farmId first (synchronous)
        tradingProvider.setCurrentFarmId('current_user_farm');
        
        // 2. Then load data (wait for completion)
        await Future.wait([
          tradingProvider.loadMarketListings(),
          livestockProvider.loadLivestock('farm1'),
        ]);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();  // ✅ dispose controller
    super.dispose();
  }
  
  // Simple back handler (no complex tab history needed)
  void _handleBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/dashboard');
    }
  }
  
  /// Generate category tags from livestock type for filtering
  List<String> _generateCategoryTags(String livestockType) {
    // Map livestock types to category tags
    if (livestockType.contains('โคเนื้อ') || livestockType.contains('โคนม')) {
      return ['โค', 'cow', 'cattle', 'beef', 'dairy'];
    } else if (livestockType.contains('กระบือ')) {
      return ['กระบือ', 'buffalo'];
    } else if (livestockType.contains('สุกร')) {
      return ['สุกร', 'pig', 'pork'];
    } else if (livestockType.contains('ไก่')) {
      return ['ไก่', 'chicken'];
    } else if (livestockType.contains('เป็ด')) {
      return ['เป็ด', 'duck'];
    } else if (livestockType.contains('แพะ')) {
      return ['แพะ', 'goat'];
    } else if (livestockType.contains('แกะ')) {
      return ['แกะ', 'sheep'];
    }
    return [livestockType.toLowerCase()];
  }

  @override
  Widget build(BuildContext context) {
    print('📐 Build called - Category: $_selectedCategory, Sort: $_sortBy');
    
    // Check auth status using Provider (listen: true to rebuild on auth changes)
    final authProvider = provider_pkg.Provider.of<AuthProvider>(context, listen: true);
    final isAuthenticated = authProvider.isLoggedIn;
    print('🔐 MarketScreen build - isAuthenticated: $isAuthenticated');
    
    return DefaultTabController(
      length: 3, // 3 tabs: ซื้อ-ขาย, จองคิว, ประกาศของฉัน
      child: Builder(
        builder: (context) {
          // ⚠️ Re-read auth state ใน Builder เพื่อ force rebuild
          final authProvider = provider_pkg.Provider.of<AuthProvider>(context, listen: true);
          final isAuth = authProvider.isLoggedIn;
          print('🔄 Builder rebuild - isAuth: $isAuth');
          
          return Scaffold(
            key: _scaffoldKey,
            appBar: StandardAppBar(
              key: ValueKey('appbar_$isAuth'), // ⚠️ Force rebuild on auth change
              type: isAuth ? AppBarType.main : AppBarType.root,
              title: 'ตลาดปศุสัตว์',
              onBackPressed: _handleBack,
              showSearch: false,
              hideMenuForGuest: true,
              customActions: [
                // Home button (ทุกหน้าจอ)
                if (isAuth)
                  IconButton(
                    icon: const Icon(Icons.home, color: Colors.white),
                    onPressed: () => context.go('/dashboard'),
                    tooltip: 'หน้าแรก',
                  ),
                // Auth button (responsive)
                _buildAuthButton(context, isAuth),
              ],
          bottom: TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: const Color.fromRGBO(255, 255, 255, 0.7),
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16, // เพิ่มขนาดสำหรับผู้สูงอายุ
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 16,
            ),
            tabs: [
              Tab(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final showText = constraints.maxWidth > 100;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.store, size: 20),
                        if (showText) ...[
                          const SizedBox(width: 6),
                          const Text('ซื้อ-ขาย', style: TextStyle(fontSize: 13)),
                        ],
                      ],
                    );
                  },
                ),
              ),
              Tab(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final showText = constraints.maxWidth > 100;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.schedule, size: 20),
                        if (showText) ...[
                          const SizedBox(width: 6),
                          const Text('จองคิว', style: TextStyle(fontSize: 13)),
                        ],
                      ],
                    );
                  },
                ),
              ),
              Tab(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final showText = constraints.maxWidth > 100;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.list_alt, size: 20),
                        if (showText) ...[
                          const SizedBox(width: 6),
                          const Text('ประกาศ', style: TextStyle(fontSize: 13)),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildMarketplaceTab(),
            isAuth ? MarketsListTab() : _buildLoginPrompt('จองคิว'),
            isAuth ? _buildMyListingsTab() : _buildLoginPrompt('ประกาศของฉัน'),
          ],
        ),
        floatingActionButton: isAuth
            ? FloatingActionButton(
                onPressed: _showCreateListingDialog,
                child: const Icon(Icons.add),
                tooltip: 'ประกาศขาย',
              )
            : null, // Hide button for guests
          );
        },
      ),
    );
  }

  /// Build auth button - Login button for guests or User menu for logged in users
  Widget _buildAuthButton(BuildContext context, bool isAuthenticated) {
    // ⚠️ MUST USE listen: true เพื่อให้ rebuild เมื่อ logout
    final authProvider = provider_pkg.Provider.of<AuthProvider>(context, listen: true);
    
    if (isAuthenticated) {
      // Show user dropdown menu
      final username = authProvider.currentUser?.username ?? 'ผู้ใช้';
      
      return LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = MediaQuery.of(context).size.width <= 600;
          
          // Mobile: แสดงแค่ Avatar (ไม่มี dropdown)
          if (isMobile) {
            return IconButton(
              icon: _buildAvatar(authProvider),
              onPressed: () => context.go('/profile'),
              tooltip: 'โปรไฟล์',
            );
          }
          
          // Desktop: แสดง Avatar + Username + Dropdown
          return PopupMenuButton<String>(
            key: const ValueKey('user_menu'),
            icon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildAvatar(authProvider),
                const SizedBox(width: 8),
                Text(
                  username,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_drop_down, color: Colors.white, size: 20),
              ],
            ),
            offset: const Offset(0, 50),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'dashboard',
                child: const Row(
                  children: [
                    Icon(Icons.dashboard, size: 20),
                    SizedBox(width: 12),
                    Text('แดชบอร์ด'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'profile',
                child: const Row(
                  children: [
                    Icon(Icons.person, size: 20),
                    SizedBox(width: 12),
                    Text('โปรไฟล์'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20, color: Colors.red[700]),
                    const SizedBox(width: 12),
                    Text('ออกจากระบบ', style: TextStyle(color: Colors.red[700])),
                  ],
                ),
              ),
            ],
            onSelected: (value) async {
              switch (value) {
                case 'dashboard':
                  context.go('/dashboard');
                  break;
                case 'profile':
                  context.go('/profile');
                  break;
                case 'logout':
                  _showLogoutConfirmation(context, authProvider);
                  break;
              }
            },
          );
        },
      );
    } else {
      // Show login button for guests
      return ElevatedButton.icon(
        key: const ValueKey('login_button'), // ⚠️ Force rebuild
        onPressed: () => context.go('/login'),
        icon: const Icon(Icons.login, size: 18),
        label: const Text('เข้าสู่ระบบ'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.green[700],
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }
  }

  /// Build avatar widget - Always show initial letter
  Widget _buildAvatar(AuthProvider authProvider) {
    final user = authProvider.currentUser;
    final username = user?.username ?? 'U';
    
    // เสมอแสดงตัวอักษรแรก ไม่แสดงรูป OAuth
    return CircleAvatar(
      radius: 16,
      backgroundColor: Colors.white,
      child: Text(
        username.substring(0, 1).toUpperCase(),
        style: const TextStyle(
          color: Colors.green,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Show logout confirmation dialog
  Future<void> _showLogoutConfirmation(BuildContext context, AuthProvider authProvider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'ออกจากระบบ',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'คุณต้องการออกจากระบบหรือไม่?',
            style: TextStyle(fontSize: 18),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text(
                'ยกเลิก',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'ออกจากระบบ',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      // Logout from both Provider and Riverpod
      await authProvider.logout();
      await ref.read(productionAuthProvider.notifier).logout();
      
      if (context.mounted) {
        // Navigate to login screen after logout
        context.go('/login');
        // Show success message will be handled by login screen
      }
    }
  }

  /// Build login prompt for guest users
  Widget _buildLoginPrompt(String feature) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'กรุณาเข้าสู่ระบบเพื่อใช้งาน',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'คุณต้องเข้าสู่ระบบเพื่อเข้าถึง "$feature"',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.go('/login'),
            icon: const Icon(Icons.login),
            label: const Text('เข้าสู่ระบบ'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              textStyle: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketplaceTab() {
    final authProvider = provider_pkg.Provider.of<AuthProvider>(context, listen: false);
    final isAuthenticated = authProvider.isLoggedIn;
    
    return Column(
      children: [
        // ✅ Search Input Bar (เพิ่มใหม่)
        _buildSearchInput(),
        
        Container(
          color: Colors.grey[100], // ✅ Background color เพื่อป้องกัน see-through
          child: _buildCategoryFilter(isAuthenticated),
        ),
        const SizedBox(height: 16), // ✅ Separate category filter จาก content
        Expanded(
          child: provider_pkg.Consumer2<TradingProvider, LivestockProvider>(
            builder: (context, tradingProvider, livestockProvider, child) {
              if (tradingProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              // ✅ เพิ่ม search query ใน getFilteredListings
              final allListings = tradingProvider.getFilteredListings(
                _selectedCategory, 
                _sortBy,
                livestockProvider.livestock, // Pass livestock data for type matching
                searchQuery: _searchQuery,  // ✅ ส่ง search query
              );
              
              if (allListings.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.store_outlined, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'ไม่มีประกาศขายในขณะนี้',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'ลองพิมพ์ชื่อสัตว์ หรือพันธุ์ที่สนใจ',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      // Seed Data Button (for testing)
                      ElevatedButton.icon(
                        onPressed: () async {
                          await tradingProvider.seedSampleData();
                          if (context.mounted) {
                            NotificationHelper.success(context, 'เพิ่มข้อมูลตัวอย่างสำเร็จ ${allListings.length} รายการ');
                          }
                        },
                        icon: const Icon(Icons.add_box),
                        label: const Text('เพิ่มข้อมูลตัวอย่าง'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF228B22),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Pagination calculation
              final totalItems = allListings.length;
              final totalPages = (totalItems / _itemsPerPage).ceil();
              final startIndex = (_currentPage - 1) * _itemsPerPage;
              final endIndex = (startIndex + _itemsPerPage).clamp(0, totalItems);
              final pageListings = allListings.sublist(startIndex, endIndex);

              return ClipRect( // ✅ Clip events ที่อาจ leak
                child: Column(
                  children: [
                    // GridView - Responsive
                    Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        int crossAxisCount = 2; // Mobile default
                        if (constraints.maxWidth >= 1200) {
                          crossAxisCount = 6; // Desktop large
                        } else if (constraints.maxWidth >= 900) {
                          crossAxisCount = 4; // Desktop medium
                        } else if (constraints.maxWidth >= 600) {
                          crossAxisCount = 3; // Tablet
                        }
                        
                        return GridView.builder(
                          padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            childAspectRatio: 1.0,
                            crossAxisSpacing: 6,
                            mainAxisSpacing: 6,
                          ),
                          itemCount: pageListings.length,
                          itemBuilder: (context, index) {
                            return _buildListingCard(pageListings[index]);
                          },
                        );
                      },
                    ),
                  ),
                  
                  // Pagination UI - Shopee/Lazada style
                  if (totalPages > 1)
                    _buildPaginationBar(totalPages, totalItems),
                ],
              ),
              ); // ✅ Close ClipRect
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQueueBookingTab() {
    return provider_pkg.Consumer<TradingProvider>(
      builder: (context, provider, child) {
        final markets = provider.availableMarkets;
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: markets.length,
          itemBuilder: (context, index) {
            return _buildMarketCard(markets[index]);
          },
        );
      },
    );
  }

  Widget _buildMyListingsTab() {
    return provider_pkg.Consumer<TradingProvider>(
      builder: (context, provider, child) {
        final myListings = provider.myListings;
        
        if (myListings.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.list_alt_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('คุณยังไม่มีประกาศขาย'),
                SizedBox(height: 8),
                Text('กดปุ่ม + เพื่อสร้างประกาศใหม่'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: myListings.length,
          itemBuilder: (context, index) {
            return _buildMyListingCard(myListings[index]);
          },
        );
      },
    );
  }

  /// Search Input Bar - เพิ่มใหม่ (เหนือ Category Filter)
  Widget _buildSearchInput() {
    return Container(
      color: const Color(0xFF228B22),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: 'ค้นหาสินค้า... (ชื่อสัตว์, พันธุ์, ราคา)',
            hintStyle: TextStyle(
              fontSize: 14,
              color: Colors.grey[400],
              fontWeight: FontWeight.normal,
            ),
            prefixIcon: const Icon(Icons.search, size: 24, color: Color(0xFF228B22)),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        _searchQuery = '';
                        _currentPage = 1;
                      });
                    },
                    tooltip: 'ล้าง',
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
              _currentPage = 1;
              // เมื่อพิมพ์ Search → รีเซ็ต Filter เป็น "ทั้งหมด"
              if (value.isNotEmpty) {
                _selectedCategory = 'ทั้งหมด';
              }
            });
          },
        ),
      ),
    );
  }

  Widget _buildCategoryFilter(bool isAuthenticated) {
    return Column(
      children: [
        // แถว 1: Category Chips (ลบ Search Icon ออก) - Center aligned
        Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Category Chips
                  ..._categories.map((category) {
                    final isSelected = category == _selectedCategory;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: RepaintBoundary( // ✅ Isolate rendering to prevent canvas overlay
                        child: FilterChip(
                          label: Text(
                            category,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                          ),
                          selected: isSelected,
                          backgroundColor: Colors.white,
                          selectedColor: const Color(0xFF228B22),
                          checkmarkColor: Colors.white,
                          elevation: 2,
                          shadowColor: Colors.black26,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          labelPadding: const EdgeInsets.symmetric(horizontal: 2),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = category;
                              _currentPage = 1;
                            });
                          },
                        ),
                      ),
                    );
                  }).toList(),
                  // ❌ ลบ Search Icon ออก (เปลี่ยนเป็น Search Input ด้านบนแล้ว)
                ],
              ),
            ),
          ),
        ),
        
        // แถว 2: Sort Bar (แนวนอน มี border ชัดเจน)
        Material(
          elevation: 4, // ✅ เพิ่ม elevation เพื่อ z-index สูงกว่า listing cards
          color: Colors.white,
          child: Container(
            margin: const EdgeInsets.only(bottom: 8), // ✅ Separate จาก listing cards
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
              children: [
              // ยอดนิยม
              _buildSortButton(
                label: 'ยอดนิยม',
                isSelected: _sortBy == 'ยอดนิยม',
                onTap: () {
                  setState(() {
                    _sortBy = 'ยอดนิยม';
                    _currentPage = 1;
                  });
                },
              ),
              const SizedBox(width: 8),
              // ล่าสุด
              _buildSortButton(
                label: 'ล่าสุด',
                isSelected: _sortBy == 'ล่าสุด',
                onTap: () {
                  setState(() {
                    _sortBy = 'ล่าสุด';
                    _currentPage = 1;
                  });
                },
              ),
              const SizedBox(width: 8),
              // ราคา (with dropdown) - DropdownButton + MouseRegion blocker
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Material(
                  elevation: 2, // ✅ ลดจาก 8 → 2 เพื่อให้ดูกลมกลืนกับปุ่มอื่น (แต่ยังเหนือ cards)
                  color: Colors.transparent,
                  child: Container(
                    height: 40,  // ✅ กำหนดความสูงคงที่เท่ากับปุ่มอื่น
                    decoration: BoxDecoration(
                      color: _sortBy.startsWith('ราคา') ? const Color(0xFFEE4D2D) : Colors.white,
                      border: Border.all(
                        color: _sortBy.startsWith('ราคา') ? const Color(0xFFEE4D2D) : Colors.grey.shade300,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // ✅ เพิ่มเป็น 16,8 เหมือนปุ่มอื่น
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _sortBy.startsWith('ราคา') ? _sortBy : null,
                        hint: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'ราคา',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: _sortBy.startsWith('ราคา') ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_drop_down,
                              size: 20,
                              color: _sortBy.startsWith('ราคา') ? Colors.white : Colors.black54,
                            ),
                          ],
                        ),
                        icon: const SizedBox.shrink(),
                        isDense: true,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _sortBy = value;
                              _currentPage = 1;
                            });
                          }
                        },
                        items: [
                          DropdownMenuItem(
                            value: 'ราคาต่ำ-สูง',
                            child: Text('ราคา: ต่ำ → สูง'),
                          ),
                          DropdownMenuItem(
                            value: 'ราคาสูง-ต่ำ',
                            child: Text('ราคา: สูง → ต่ำ'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
              ),
            ),
          ),
        ), // ✅ Close Material
      ],
    );
  }

  /// Build sort button (Shopee style)
  Widget _buildSortButton({
    required String label,
    required bool isSelected,
    bool hasDropdown = false,
    VoidCallback? onTap,
  }) {
    final buttonContent = Container(
      height: 40,  // ✅ กำหนดความสูงคงที่
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFEE4D2D) : Colors.white,
        border: Border.all(
          color: isSelected ? const Color(0xFFEE4D2D) : Colors.grey.shade300,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ),
          if (hasDropdown) ...[
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              size: 20,
              color: isSelected ? Colors.white : Colors.black54,
            ),
          ],
        ],
      ),
    );
    
    // ถ้า onTap เป็น null (เช่น ใช้กับ PopupMenuButton)
    // return โดยตรงเพื่อให้ PopupMenuButton จัดการ tap events
    if (onTap == null) {
      return buttonContent;
    }
    
    // ถ้ามี onTap ใช้ InkWell ปกติ
    return InkWell(
      onTap: onTap,
      child: buttonContent,
    );
  }

  Widget _buildListingCard(MarketListing listing) {
    // Mock data for demo
    final rating = 4.5 + (listing.viewCount % 5) * 0.1;
    final sold = listing.viewCount * 2;
    final quickBuyUrl = '${html.window.location.origin}/#/quick-buy/${listing.id}';
    
    // 🔍 DEBUG: Check Firebase images
    print('🔍 Listing ID: ${listing.id}');
    print('🔍 Images array: ${listing.images}');
    print('🔍 Images length: ${listing.images.length}');
    if (listing.images.isNotEmpty) {
      print('🔍 First image: ${listing.images[0]}');
    }
    
    // MUST use Firebase image (real data), NOT mock data!
    final imageUrl = listing.images.isNotEmpty && listing.images[0].isNotEmpty
        ? listing.images[0]  // ✅ Real Firebase image
        : null; // ❌ No mock data!
    
    print('🔍 Final imageUrl: $imageUrl');
    
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image - Flexible (fills available space) - Click to Quick Buy
          Expanded(
            child: InkWell(
              onTap: () => context.go('/quick-buy/${listing.id}'),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              child: Stack(
                children: [
                  // Image fills entire space
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      child: _buildListingImage(imageUrl, listing.livestockId, listing.id),
                    ),
                  ),
                  
                  // Share Button (Top Right)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Material(
                      color: Colors.blue.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => _handleQuickShare(quickBuyUrl, 'ปศุสัตว์ #${listing.livestockId}'),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            Icons.share,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // Sold Badge (Center Bottom)
                  if (listing.status == 'sold')
                    Positioned(
                      bottom: 8,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Text(
                            'ขายแล้ว',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          // Content - Shopee/Lazada style (Natural height)
          InkWell(
            onTap: () => _showListingDetails(listing),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title - 2 lines
                  Text(
                    'ปศุสัตว์ #${listing.livestockId}',
                    style: const TextStyle(
                      fontSize: 11,
                      height: 1.15,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 1),
                  
                  // Price
                  Text(
                    listing.askingPrice >= 1000000 
                        ? '฿${(listing.askingPrice / 1000).toStringAsFixed(0)}K'
                        : PriceFormatter.format(listing.askingPrice),
                    style: const TextStyle(
                      color: Color(0xFFFF6B35),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 1),
                  
                  // Rating + Sold
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, size: 10, color: Colors.orange[700]),
                      const SizedBox(width: 2),
                      Text(
                        rating.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[700],
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        width: 1,
                        height: 10,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'ขาย $sold',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
                  
                  // Location
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_on, size: 9, color: Colors.grey[500]),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          'ฟาร์ม ${listing.farmId}',
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.grey[600],
                            height: 1.0,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketCard(Map<String, dynamic> market) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.store,
                  color: Colors.blue.shade700,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        market['name'],
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        market['location'],
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _showBookingDialog(market),
                  child: const Text('จองคิว'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'วันทำการ: ${market['openDays']}',
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  market['openTime'],
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const Spacer(),
                Text(
                  'คิวรอ: ${market['queueCount']} คน',
                  style: TextStyle(
                    color: Colors.orange.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyListingCard(MarketListing listing) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: listing.status == 'active' 
                ? const Color(0xFF228B22).withValues(alpha: 0.3)
                : Colors.grey.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Image (actual listing image)
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: listing.images.isNotEmpty
                          ? _buildListingImage(
                              listing.images[0],
                              listing.livestockId,
                              listing.id,
                            )
                          : Container(
                              color: Colors.grey.shade200,
                              child: Icon(
                                Icons.agriculture,
                                size: 40,
                                color: Colors.grey.shade400,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ปศุสัตว์ #${listing.livestockId}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF228B22).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                PriceFormatter.format(listing.askingPrice),
                                style: const TextStyle(
                                  color: Color(0xFF228B22),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            if (listing.isNegotiable) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'ต่อรองได้',
                                  style: TextStyle(
                                    color: Colors.orange[700],
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Status Chip
                  _buildStatusChip(listing.status),
                ],
              ),
              const SizedBox(height: 12),
              
              // Description
              if (listing.description != null && listing.description!.isNotEmpty) ...[
                Text(
                  listing.description!,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
              ],
              
              // Image count badge
              if (listing.images.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(Icons.photo_library, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${listing.images.length} รูป',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              
              const Divider(),
              const SizedBox(height: 8),
              
              // Actions Row
              Row(
                children: [
                  // Views
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.visibility, size: 14, color: Colors.blue[700]),
                        const SizedBox(width: 4),
                        Text(
                          '${listing.viewCount} views',
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  
                  // Share Button
                  OutlinedButton.icon(
                    icon: const Icon(Icons.share, size: 18),
                    label: const Text('Share'),
                    onPressed: () => _showQuickBuyDialog(listing),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF9C27B0),
                      side: const BorderSide(color: Color(0xFF9C27B0)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                  const SizedBox(width: 8),
                  
                  // Edit Button
                  OutlinedButton.icon(
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('แก้ไข'),
                    onPressed: () => _editListing(listing),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      side: const BorderSide(color: Colors.blue),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                  const SizedBox(width: 8),
                  
                  // Delete Button
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20),
                    tooltip: 'ลบ',
                    onPressed: () => _deleteListing(listing),
                    color: Colors.red,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String text;
    
    switch (status) {
      case 'active':
        color = Colors.green;
        text = 'กำลังขาย';
        break;
      case 'sold':
        color = Colors.blue;
        text = 'ขายแล้ว';
        break;
      case 'expired':
        color = Colors.orange;
        text = 'หมดอายุ';
        break;
      case 'withdrawn':
        color = Colors.grey;
        text = 'ถอนประกาศ';
        break;
      default:
        color = Colors.grey;
        text = status;
    }
    
    return Chip(
      label: Text(text, style: const TextStyle(fontSize: 12)),
      backgroundColor: color.withValues(alpha: 0.1),
      side: BorderSide(color: color),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'โค':
        return Icons.agriculture;
      case 'สุกร':
        return Icons.pets;
      case 'ไก่':
        return Icons.egg;
      case 'แพะ':
        return Icons.grass;
      case 'เป็ด':
        return Icons.water;
      case 'กระบือ':
        return Icons.agriculture;
      case 'แกะ':
        return Icons.grass;
      default:
        return Icons.agriculture;
    }
  }

  Widget _buildListingImage(String? imageUrl, String livestockId, String listingId) {
    // ✅ Fix: Handle short livestockId (e.g., "9" instead of "COW001")
    final category = livestockId.length >= 3 
        ? livestockId.substring(0, 3).toLowerCase()
        : 'gen'; // default category for short IDs
    
    // ถ้าไม่มี imageUrl
    if (imageUrl == null || imageUrl.isEmpty) {
      return _buildPlaceholderImage(category);
    }
    
    // ถ้าเป็น Firebase Storage URL (https://firebasestorage...)
    if (imageUrl.startsWith('https://firebasestorage.googleapis.com') ||
        imageUrl.startsWith('https://') ||
        imageUrl.startsWith('http://')) {
      print('🌐 Loading from URL: $imageUrl');
      return CorsImage(
        imageUrl: imageUrl,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        onTap: () {
          // ป้องกัน navigation เมื่อ dialog เปิดอยู่
          if (_isCreatingListing) {
            print('⚠️ Blocked: Dialog is open');
            return;
          }
          print('🖱️ Image clicked: $listingId');
          context.go('/quick-buy/$listingId');
        },
        errorWidget: _buildPlaceholderImage(category),
        placeholder: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.grey.shade100,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }
    
    // ถ้าเป็น Asset path (images/livestock/...)
    final extension = imageUrl.toLowerCase().split('.').last;
    print('📁 Loading from asset: $imageUrl (.$extension)');
    
    // ตรวจสอบว่าเป็น SVG หรือไม่
    // รองรับ: SVG, JPG, PNG, WEBP, GIF
    if (extension == 'svg') {
      return SvgPicture.asset(
        imageUrl,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        placeholderBuilder: (context) => Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    // ไฟล์ประเภทอื่น: JPG, PNG, WEBP, GIF
    // Flutter รองรับทุกประเภทอัตโนมัติ
    return Image.asset(
      imageUrl,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        print('❌ Asset image error: $error');
        return _buildPlaceholderImage(category);
      },
    );
  }
  
  Widget _buildPlaceholderImage(String category) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF8B4513).withValues(alpha: 0.7),
            const Color(0xFF228B22).withValues(alpha: 0.7),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          _getCategoryIcon(category),
          size: 40,
          color: Colors.white.withValues(alpha: 0.9),
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} วันที่แล้ว';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ชั่วโมงที่แล้ว';
    } else {
      return '${difference.inMinutes} นาทีที่แล้ว';
    }
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ค้นหา'),
        content: const TextField(
          decoration: InputDecoration(
            hintText: 'ค้นหาปศุสัตว์...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ค้นหา'),
          ),
        ],
      ),
    );
  }

  String _getTypeName(LivestockType type) {
    switch (type) {
      // โค
      case LivestockType.dairyCow:
        return 'โคนม';
      case LivestockType.beefCattleLocal:
        return 'โคเนื้อพื้นเมือง';
      case LivestockType.beefCattlePurebred:
        return 'โคเนื้อพันธุ์แท้';
      case LivestockType.beefCattleCrossbred:
        return 'โคเนื้อลูกผสม';
      
      // กระบือ
      case LivestockType.buffaloLocal:
        return 'กระบือพื้นเมือง';
      case LivestockType.buffaloDairy:
        return 'กระบือนม';
      
      // สุกร
      case LivestockType.pigLocal:
        return 'สุกรพื้นเมือง';
      case LivestockType.pigBreeder:
        return 'สุกรพันธุ์';
      case LivestockType.pigFattening:
        return 'สุกรขุน';
      case LivestockType.pigBreederYoung:
        return 'ลูกสุกรพันธุ์';
      
      // ไก่
      case LivestockType.chickenLocal:
        return 'ไก่พื้นเมือง';
      case LivestockType.chickenCrossbred:
        return 'ไก่ลูกผสม';
      case LivestockType.chickenBroiler:
        return 'ไก่เนื้อ';
      case LivestockType.chickenLayer:
        return 'ไก่ไข่';
      case LivestockType.chickenBreederMeatPS:
        return 'ไก่พ่อแม่พันธุ์เนื้อ';
      case LivestockType.chickenBreederLayerPS:
        return 'ไก่พ่อแม่พันธุ์ไข่';
      case LivestockType.chickenBreederMeatGP:
        return 'ไก่ปู่ย่าพันธุ์เนื้อ';
      case LivestockType.chickenBreederLayerGP:
        return 'ไก่ปู่ย่าพันธุ์ไข่';
      
      // เป็ด
      case LivestockType.duckMuscovy:
        return 'เป็ดเทศ';
      case LivestockType.duckMeat:
        return 'เป็ดเนื้อ';
      case LivestockType.duckEgg:
        return 'เป็ดไข่';
      case LivestockType.duckMeatField:
        return 'เป็ดเนื้อไล่ทุ่ง';
      case LivestockType.duckEggField:
        return 'เป็ดไข่ไล่ทุ่ง';
      
      // แพะ
      case LivestockType.goatMeat:
        return 'แพะเนื้อ';
      case LivestockType.goatDairy:
        return 'แพะนม';
      
      // แกะ
      case LivestockType.sheep:
        return 'แกะ';
      
      // นกกระทา
      case LivestockType.quailMeat:
        return 'นกกระทาเนื้อ';
      case LivestockType.quailEgg:
        return 'นกกระทาไข่';
      
      // อื่นๆ
      default:
        return type.displayName;
    }
  }

  /// Show combined Search & Filter dialog
  /// NOTE: Not used anymore - using horizontal tab filter instead
  /// Keep this for future reference if needed
  void _showSearchFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('ค้นหาและกรอง'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Filter
                const Text('หมวดหมู่:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _categories.map((category) {
                    final isSelected = category == _selectedCategory;
                    return FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = category;
                          _currentPage = 1;
                        });
                        setDialogState(() {}); // Update dialog UI
                      },
                    );
                  }).toList(),
                ),
                
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                
                // Sort Options
                const Text('เรียงตาม:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ..._sortOptions.map((option) {
                  final isSelected = option == _sortBy;
                  return RadioListTile<String>(
                    title: Text(option),
                    value: option,
                    groupValue: _sortBy,
                    selected: isSelected,
                    onChanged: (value) {
                      setState(() {
                        _sortBy = value!;
                        _currentPage = 1;
                      });
                      setDialogState(() {}); // Update dialog UI
                    },
                  );
                }).toList(),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ยกเลิก'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ใช้งาน'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateListingDialog() {
    final formKey = GlobalKey<FormState>();
    final priceController = TextEditingController();
    final minPriceController = TextEditingController();
    final descriptionController = TextEditingController();
    
    // Get livestock from provider
    final livestockProvider = context.read<LivestockProvider>();
    final allLivestock = livestockProvider.livestock;
    
    // Sort by category (earTag prefix) to group same types together
    final availableLivestock = List<Livestock>.from(allLivestock)
      ..sort((a, b) {
        // Handle null earTags
        final aTag = a.earTag ?? '';
        final bTag = b.earTag ?? '';
        
        // Extract prefix (e.g., "COW", "PIG", "CHK")
        final aPrefix = aTag.replaceAll(RegExp(r'\d+'), '');
        final bPrefix = bTag.replaceAll(RegExp(r'\d+'), '');
        
        // First sort by prefix (category)
        final prefixCompare = aPrefix.compareTo(bPrefix);
        if (prefixCompare != 0) return prefixCompare;
        
        // Then sort by number within same category
        return aTag.compareTo(bTag);
      });
    
    String? selectedLivestock = availableLivestock.isNotEmpty ? availableLivestock.first.id : null;
    bool isNegotiable = true;
    List<String> uploadedImages = [];
    List<Uint8List> imageBytes = [];
    List<String> imageNames = [];

    // Set flag to prevent background clicks
    setState(() => _isCreatingListing = true);

    showDialog(
      context: context,
      barrierDismissible: false, // ป้องกันกดพื้นหลังปิด dialog
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('สร้างประกาศขาย'),
            content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                const SizedBox(height: 16), // ← Spacing to prevent label overlap
                // Dynamic dropdown from Firestore/Provider
                DropdownButtonFormField<String>(
                  value: selectedLivestock,
                  decoration: const InputDecoration(
                    labelText: 'เลือกปศุสัตว์',
                    border: OutlineInputBorder(),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    hintText: 'เลือกจากรายการ',
                  ),
                  items: availableLivestock.isEmpty
                      ? [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('ไม่มีข้อมูลปศุสัตว์'),
                          ),
                        ]
                      : availableLivestock.map((livestock) {
                          return DropdownMenuItem(
                            value: livestock.id,
                            child: Text('${livestock.earTag} (${_getTypeName(livestock.type)})'),
                          );
                        }).toList(),
                  onChanged: availableLivestock.isEmpty
                      ? null
                      : (value) => selectedLivestock = value,
                  validator: (value) {
                    if (value == null) return 'กรุณาเลือกปศุสัตว์';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: priceController,
                  decoration: const InputDecoration(
                    labelText: 'ราคาขาย (บาท)',
                    border: OutlineInputBorder(),
                    prefixText: '฿ ',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'กรุณาใส่ราคา';
                    if (double.tryParse(value!) == null) return 'กรุณาใส่ตัวเลข';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: minPriceController,
                  decoration: const InputDecoration(
                    labelText: 'ราคาต่ำสุด (บาท)',
                    border: OutlineInputBorder(),
                    prefixText: '฿ ',
                    hintText: 'ถ้าต่อรองได้',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'รายละเอียด',
                    border: OutlineInputBorder(),
                    hintText: 'อธิบายเพิ่มเติมเกี่ยวกับปศุสัตว์',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                // Image Upload Section - Clean & Simple
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Icon(
                          Icons.image,
                          color: const Color(0xFF228B22),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'รูปภาพสินค้า',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // Info Card - Enhanced & Clear
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.blue.shade200,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 18,
                                color: Colors.blue.shade700,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'ข้อมูลสำคัญ',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade900,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          
                          // 🔥 NEW: Promoted Image (รูปแรก) - ใช้สีส้ม (10% Highlight)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFE0B2), // Soft Orange
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFFFB74D), // Light Orange
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  size: 20,
                                  color: Color(0xFFFF9800), // Primary Orange
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'รูปแรก = รูปโปรโมต',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFE65100), // Dark Orange
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'จะแสดงเป็นรูปหน้าปกในตลาด',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.brown.shade700, // Brown Secondary
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          // Divider
                          Divider(color: Colors.blue.shade200, height: 1),
                          const SizedBox(height: 12),
                          
                          // File Types
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.image,
                                size: 16,
                                color: Colors.grey.shade700,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'ไฟล์ที่รองรับ:',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade800,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'JPG, JPEG, JFIF, PNG, WEBP, GIF, SVG',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          
                          // File Size
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.sd_card,
                                size: 16,
                                color: Colors.grey.shade700,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'ขนาดไฟล์: ',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey.shade800,
                                          ),
                                        ),
                                        Text(
                                          'ไม่เกิน 3 MB ต่อ 1 รูป',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.orange.shade700,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'แนะนำ: 1024×1024 px ขึ้นไป',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade600,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          
                          // Max Images
                          Row(
                            children: [
                              Icon(
                                Icons.collections,
                                size: 16,
                                color: Colors.grey.shade700,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'จำนวน: ',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              Text(
                                'อัปโหลดได้สูงสุด 9 รูป',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                        
                        const SizedBox(height: 16),
                        
                        // 🆕 Image Preview ABOVE Upload Button
                        if (imageBytes.isNotEmpty) ...[
                          Text(
                            'รูปที่เลือก (${imageBytes.length}):',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: imageBytes.asMap().entries.map((entry) {
                              final index = entry.key;
                              final bytes = entry.value;
                              return Stack(
                                children: [
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.blue.shade300),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.memory(bytes, fit: BoxFit.cover),
                                    ),
                                  ),
                                  Positioned(
                                    top: 2,
                                    right: 2,
                                    child: GestureDetector(
                                      onTap: () {
                                        if (mounted) {
                                          setState(() {
                                            imageBytes.removeAt(index);
                                            imageNames.removeAt(index);
                                            uploadedImages = imageNames;
                                          });
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.close,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 12),
                        ],
                        
                        // Upload Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              // Use HTML input for web (bypass file_picker issues)
                              if (kIsWeb) {
                                // Create HTML input element
                                final input = html.FileUploadInputElement()
                                  ..accept = 'image/jpeg,image/jpg,image/jfif,image/png,image/webp,image/gif,image/svg+xml'
                                  ..multiple = true;
                                
                                // Use completer to properly handle the async event
                                final completer = Completer<void>();
                                
                                input.onChange.listen((e) async {
                                  if (!completer.isCompleted) {
                                    completer.complete();
                                  }
                                });
                                
                                input.click();
                                
                                // Wait for file selection with timeout
                                try {
                                  await completer.future.timeout(
                                    const Duration(minutes: 5),
                                    onTimeout: () {
                                      if (mounted) {
                                        NotificationHelper.info(
                                          context,
                                          'ยกเลิกการเลือกไฟล์ (หมดเวลา)',
                                        );
                                      }
                                    },
                                  );
                                } catch (e) {
                                  return;
                                }
                                
                                final files = input.files;
                                if (files == null || files.isEmpty) {
                                  if (mounted) {
                                    NotificationHelper.info(
                                      context,
                                      'ยกเลิกการเลือกไฟล์',
                                    );
                                  }
                                  return;
                                }
                                
                                int validFiles = 0;
                                int oversizedFiles = 0;
                                int invalidType = 0;
                                int tooManyFiles = 0;
                                
                                for (var file in files) {
                                  // Check max 9 images
                                  if (imageBytes.length >= 9) {
                                    tooManyFiles++;
                                    continue;
                                  }
                                  
                                  // Check file type
                                  final fileName = file.name.toLowerCase();
                                  final extension = fileName.split('.').last;
                                  
                                  if (!['jpg', 'jpeg', 'jfif', 'png', 'webp', 'gif', 'svg'].contains(extension)) {
                                    invalidType++;
                                    continue;
                                  }
                                  
                                  // Check file size (3 MB max per image)
                                  if (file.size > 3 * 1024 * 1024) {
                                    oversizedFiles++;
                                    continue;
                                  }
                                  
                                  // Read file bytes
                                  final reader = html.FileReader();
                                  reader.readAsArrayBuffer(file);
                                  await reader.onLoad.first;
                                  
                                  final bytes = reader.result as List<int>;
                                  imageBytes.add(Uint8List.fromList(bytes));
                                  imageNames.add(file.name);
                                  validFiles++;
                                }
                                
                                // Update uploaded images list
                                uploadedImages = imageNames;
                                
                                // Show result notification (with mounted check)
                                if (mounted) {
                                  if (validFiles > 0) {
                                    NotificationHelper.success(
                                      context,
                                      'เลือกไฟล์สำเร็จ $validFiles ไฟล์',
                                    );
                                  }
                                  
                                  if (oversizedFiles > 0) {
                                    NotificationHelper.warning(
                                      context,
                                      '$oversizedFiles ไฟล์มีขนาดใหญ่เกิน 3 MB (ข้าม)',
                                    );
                                  }
                                  
                                  if (invalidType > 0) {
                                    NotificationHelper.warning(
                                      context,
                                      '$invalidType ไฟล์ไม่รองรับ (ต้องเป็น JPG, JPEG, JFIF, PNG, WEBP, GIF, SVG)',
                                    );
                                  }
                                  
                                  if (tooManyFiles > 0) {
                                    NotificationHelper.warning(
                                      context,
                                      '$tooManyFiles ไฟล์เกิน (เลือกได้สูงสุด 9 รูป)',
                                    );
                                  }
                                  
                                  // Force rebuild to show selected files
                                  setState(() {});
                                }
                              } else {
                                // Mobile/Desktop: use file_picker
                                try {
                                  final result = await FilePicker.platform.pickFiles(
                                    type: FileType.image,
                                    allowMultiple: true,
                                  );
                                  
                                  if (result != null && result.files.isNotEmpty) {
                                    int validFiles = 0;
                                    int oversizedFiles = 0;
                                    
                                    for (var file in result.files) {
                                      if (file.bytes != null) {
                                        // Check file size (3 MB max)
                                        if (file.size > 3 * 1024 * 1024) {
                                          oversizedFiles++;
                                          continue;
                                        }
                                        
                                        imageBytes.add(file.bytes!);
                                        imageNames.add(file.name);
                                        validFiles++;
                                      }
                                    }
                                    
                                    uploadedImages = imageNames;
                                    
                                    if (mounted) {
                                      if (validFiles > 0) {
                                        NotificationHelper.success(
                                          context,
                                          'เลือกไฟล์สำเร็จ $validFiles ไฟล์',
                                        );
                                      }
                                      
                                      if (oversizedFiles > 0) {
                                        NotificationHelper.warning(
                                          context,
                                          '$oversizedFiles ไฟล์มีขนาดใหญ่เกิน 3 MB (ข้าม)',
                                        );
                                      }
                                      
                                      setState(() {});
                                    }
                                  }
                                } catch (e) {
                                  NotificationHelper.error(
                                    context,
                                    'เกิดข้อผิดพลาด: $e',
                                  );
                                }
                              }
                            },
                            icon: const Icon(Icons.cloud_upload_outlined, size: 20),
                            label: const Text(
                              'อัปโหลดรูปภาพ',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF228B22),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 2,
                            ),
                          ),
                        ),
                        
                        // Selected Images Counter
                        if (uploadedImages.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.green.shade300,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.green.shade700,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'เลือกแล้ว ${uploadedImages.length} รูป',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.green.shade700,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (uploadedImages.isNotEmpty)
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.star,
                                            size: 12,
                                            color: Color(0xFFFF9800), // Primary Orange
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'รูปแรก = โปรโมต',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.brown.shade700, // Brown Secondary
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text('ต่อรองราคาได้'),
                  value: isNegotiable,
                  onChanged: (value) => isNegotiable = value ?? false,
                ),
              ],
            ),
          ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                // Show loading dialog
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Text(
                            imageBytes.isNotEmpty 
                                ? 'กำลังอัปโหลดรูปภาพ ${imageBytes.length} ไฟล์...'
                                : 'กำลังสร้างประกาศ...',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
                
                try {
                  // Validate selectedLivestock
                  if (selectedLivestock == null) {
                    NotificationHelper.error(
                      context,
                      'กรุณาเลือกปศุสัตว์',
                    );
                    return;
                  }
                  
                  // Generate listing ID
                  final listingId = DateTime.now().millisecondsSinceEpoch.toString();
                  
                  // Upload images if any
                  List<String> imageUrls = [];
                  if (imageBytes.isNotEmpty) {
                    try {
                      final storageService = StorageService();
                      // Add timeout of 60 seconds
                      imageUrls = await storageService.uploadProductImages(
                        imageBytes,
                        imageNames,
                        listingId,
                      ).timeout(
                        const Duration(seconds: 60),
                        onTimeout: () {
                          throw Exception('อัปโหลดใช้เวลานานเกินไป กรุณาลองใหม่');
                        },
                      );
                      
                      if (imageUrls.isEmpty) {
                        throw Exception('อัปโหลดรูปภาพไม่สำเร็จ');
                      }
                      
                      print('🎉 อัปโหลดสำเร็จ: ${imageUrls.length} รูป');
                    } catch (uploadError) {
                      print('❌ Upload error: $uploadError');
                      // Close loading dialog
                      if (mounted) Navigator.pop(context);
                      
                      NotificationHelper.error(
                        context,
                        'อัปโหลดรูปภาพไม่สำเร็จ: ${uploadError.toString().contains('Permission') ? 'ไม่มีสิทธิ์เข้าถึง Storage' : uploadError.toString().replaceAll('Exception:', '')}',
                      );
                      return;
                    }
                  }
                  
                  // Get livestock details for auto-tagging
                  final livestockProvider = context.read<LivestockProvider>();
                  Livestock? livestock;
                  try {
                    livestock = livestockProvider.livestock
                        .firstWhere((l) => l.id == selectedLivestock);
                  } catch (e) {
                    // Fallback to first livestock if not found
                    livestock = livestockProvider.livestock.isNotEmpty 
                        ? livestockProvider.livestock.first 
                        : null;
                  }
                  
                  if (livestock == null) {
                    throw Exception('ไม่พบข้อมูลปศุสัตว์');
                  }
                  
                  // Auto-generate shareTitle and tags based on livestock type
                  String shareTitle = '${livestock.type.displayName} ${livestock.displayName}';
                  List<String> shareTags = _generateCategoryTags(livestock.type.displayName);
                  
                  // Create listing with image URLs
                  final listing = MarketListing(
                    id: listingId,
                    farmId: 'current_user_farm',
                    livestockId: selectedLivestock!,
                    askingPrice: double.parse(priceController.text),
                    minPrice: minPriceController.text.isNotEmpty 
                        ? double.parse(minPriceController.text) 
                        : null,
                    description: descriptionController.text.isNotEmpty 
                        ? descriptionController.text 
                        : null,
                    images: imageUrls,
                    isNegotiable: isNegotiable,
                    listedDate: DateTime.now(),
                    status: 'active',
                    viewCount: 0,
                    createdAt: DateTime.now(),
                    // Auto-generated social commerce fields
                    shareTitle: shareTitle,
                    shareTags: shareTags,
                    shareDescription: descriptionController.text.isNotEmpty 
                        ? descriptionController.text 
                        : '${livestock.type.displayName} คุณภาพดี',
                  );
                  
                  // Save to Firestore
                  await context.read<TradingProvider>().createListing(listing);
                  
                  // Close loading dialog
                  if (mounted) Navigator.pop(context);
                  
                  // Close form dialog
                  Navigator.pop(context);
                  
                  // Show success notification
                  NotificationHelper.success(
                    context,
                    'สร้างประกาศสำเร็จ!${imageUrls.isNotEmpty ? " (${imageUrls.length} รูป)" : ""}',
                  );
                  
                } catch (e) {
                  // Close loading dialog
                  if (mounted) Navigator.pop(context);
                  
                  // Show error notification
                  NotificationHelper.error(
                    context,
                    'เกิดข้อผิดพลาด: $e',
                  );
                }
              }
            },
            child: const Text('สร้างประกาศ'),
          ),
        ],
          );
        },
      ),
    ).then((_) {
      // Reset flag when dialog closes
      if (mounted) {
        setState(() => _isCreatingListing = false);
      }
    });
  }

  void _showListingDetails(MarketListing listing) {
    final quickBuyUrl = '${html.window.location.origin}/#/quick-buy/${listing.id}';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('ปศุสัตว์ #${listing.livestockId}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ราคา: ${PriceFormatter.format(listing.askingPrice)} บาท'),
            if (listing.minPrice != null) ...[
              const SizedBox(height: 8),
              Text('ราคาต่ำสุด: ${PriceFormatter.format(listing.minPrice!)} บาท'),
            ],
            const SizedBox(height: 8),
            Text('สถานะ: ${listing.status}'),
            const SizedBox(height: 8),
            Text('ฟาร์ม: ${listing.farmId}'),
            if (listing.description != null && listing.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('รายละเอียด: ${listing.description}'),
            ],
            const SizedBox(height: 8),
            Text('ยอดเข้าชม: ${listing.viewCount} ครั้ง'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.link, size: 16, color: Colors.purple[700]),
                      const SizedBox(width: 8),
                      Text(
                        'Quick Buy Link',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.purple[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    quickBuyUrl,
                    style: const TextStyle(fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ปิด'),
          ),
          OutlinedButton.icon(
            icon: const Icon(Icons.share, size: 18),
            label: const Text('Share'),
            onPressed: () {
              Navigator.pop(context);
              _handleQuickShare(quickBuyUrl, 'ปศุสัตว์ #${listing.livestockId}');
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF9C27B0),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showContactDialog();
            },
            child: const Text('ติดต่อ'),
          ),
        ],
      ),
    );
  }

  void _showContactDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ติดต่อผู้ขาย'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('ข้อมูลติดต่อผู้ขาย:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.person, size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                const Text('นายสมชาย ใจดี'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.phone, size: 20, color: Colors.green),
                const SizedBox(width: 8),
                const Text('044-123-456'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 20, color: Colors.red),
                const SizedBox(width: 8),
                const Text('บ้านเลขที่ 123 ต.เนินสง่า อ.เนินสง่า จ.ชัยภูมิ'),
              ],
            ),
            const SizedBox(height: 16),
            const Text('หมายเหตุ: กรุณาติดต่อในเวลา 08:00-18:00 น.', 
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ปิด'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('เปิดแอปโทรศัพท์')),
              );
            },
            icon: const Icon(Icons.phone),
            label: const Text('โทร'),
          ),
        ],
      ),
    );
  }

  void _showBookingDialog(Map<String, dynamic> market) {
    final formKey = GlobalKey<FormState>();
    final livestockCountController = TextEditingController();
    final notesController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    String selectedTimeSlot = '06:00-08:00';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('จองคิว ${market['name']}'),
          content: SizedBox(
            width: 400,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: Text('วันที่: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 30)),
                      );
                      if (date != null) {
                        setState(() => selectedDate = date);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedTimeSlot,
                    decoration: const InputDecoration(
                      labelText: 'ช่วงเวลา',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: '06:00-08:00', child: Text('06:00-08:00')),
                      DropdownMenuItem(value: '08:00-10:00', child: Text('08:00-10:00')),
                      DropdownMenuItem(value: '10:00-12:00', child: Text('10:00-12:00')),
                    ],
                    onChanged: (value) => selectedTimeSlot = value!,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: livestockCountController,
                    decoration: const InputDecoration(
                      labelText: 'จำนวนปศุสัตว์',
                      border: OutlineInputBorder(),
                      suffixText: 'ตัว',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'กรุณาใส่จำนวน';
                      if (int.tryParse(value!) == null) return 'กรุณาใส่ตัวเลข';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: notesController,
                    decoration: const InputDecoration(
                      labelText: 'หมายเหตุ',
                      border: OutlineInputBorder(),
                      hintText: 'ข้อมูลเพิ่มเติม (ถ้ามี)',
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ยกเลิก'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final booking = MarketBooking(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    farmId: 'current_user_farm',
                    marketId: market['id'],
                    bookingDate: selectedDate,
                    livestockType: 'โค',
                    quantity: int.parse(livestockCountController.text),
                    notes: notesController.text.isNotEmpty ? notesController.text : null,
                    status: 'confirmed',
                    createdAt: DateTime.now(),
                  );
                  
                  context.read<TradingProvider>().bookMarketQueue(booking);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('จองคิวเรียบร้อยแล้ว')),
                  );
                }
              },
              child: const Text('จองคิว'),
            ),
          ],
        ),
      ),
    );
  }

  void _showQuickBuyDialog(MarketListing listing) {
    final quickBuyUrl = '${html.window.location.origin}/#/quick-buy/${listing.id}';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.link, color: const Color(0xFF9C27B0)),
            const SizedBox(width: 8),
            const Text('🔗 Quick Buy Link'),
          ],
        ),
        content: SizedBox(
          width: 350,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // QR Code
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: QrImageView(
                  data: quickBuyUrl,
                  version: QrVersions.auto,
                  size: 200,
                ),
              ),
              const SizedBox(height: 16),
              
              // URL Display
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  quickBuyUrl,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              const SizedBox(height: 16),
              
              // Instructions
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, size: 16, color: Colors.purple[700]),
                        const SizedBox(width: 8),
                        Text(
                          'วิธีใช้งาน',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.purple[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• แชร์ลิงก์นี้ใน Social Media (Facebook, LINE, TikTok)',
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                    Text(
                      '• ลูกค้าสามารถซื้อได้ทันทีโดยไม่ต้อง Login',
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                    Text(
                      '• ระบบ Guest Checkout - ใช้เวลาซื้อน้อยกว่า 5 นาที',
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          OutlinedButton.icon(
            icon: const Icon(Icons.copy),
            label: const Text('📋 Copy Link'),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: quickBuyUrl));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ คัดลอกลิงก์แล้ว!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ปิด'),
          ),
        ],
      ),
    );
  }

  void _editListing(MarketListing listing) {
    final formKey = GlobalKey<FormState>();
    final priceController = TextEditingController(text: listing.askingPrice.toString());
    final minPriceController = TextEditingController(text: listing.minPrice?.toString() ?? '');
    final descriptionController = TextEditingController(text: listing.description ?? '');
    
    // Get livestock from provider
    final livestockProvider = context.read<LivestockProvider>();
    final allLivestock = livestockProvider.livestock;
    
    // Sort by category (earTag prefix) to group same types together
    final availableLivestock = List<Livestock>.from(allLivestock)
      ..sort((a, b) {
        final aTag = a.earTag ?? '';
        final bTag = b.earTag ?? '';
        final aPrefix = aTag.replaceAll(RegExp(r'\d+'), '');
        final bPrefix = bTag.replaceAll(RegExp(r'\d+'), '');
        final prefixCompare = aPrefix.compareTo(bPrefix);
        if (prefixCompare != 0) return prefixCompare;
        return aTag.compareTo(bTag);
      });
    
    String selectedLivestock = listing.livestockId;
    
    // Image management - start with existing images
    List<String> existingImageUrls = List<String>.from(listing.images);
    List<Uint8List> newImageBytes = [];
    List<String> newImageNames = [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          bool isNegotiable = listing.isNegotiable;
          
          return AlertDialog(
            title: const Text('\u0e41\u0e01\u0e49\u0e44\u0e02\u0e1b\u0e23\u0e30\u0e01\u0e32\u0e28\u0e02\u0e32\u0e22'),
            content: SizedBox(
              width: 450,
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 16), // ← Spacing to prevent label overlap
                      // Livestock Selector
                      DropdownButtonFormField<String>(
                        value: selectedLivestock,
                        decoration: const InputDecoration(
                          labelText: '\u0e40\u0e25\u0e37\u0e2d\u0e01\u0e1b\u0e28\u0e38\u0e2a\u0e31\u0e15\u0e27\u0e4c',
                          border: OutlineInputBorder(),
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          hintText: '\u0e40\u0e25\u0e37\u0e2d\u0e01\u0e08\u0e32\u0e01\u0e23\u0e32\u0e22\u0e01\u0e32\u0e23',
                        ),
                        items: availableLivestock.isEmpty
                            ? [
                                const DropdownMenuItem(
                                  value: null,
                                  child: Text('\u0e44\u0e21\u0e48\u0e21\u0e35\u0e02\u0e49\u0e2d\u0e21\u0e39\u0e25\u0e1b\u0e28\u0e38\u0e2a\u0e31\u0e15\u0e27\u0e4c'),
                                ),
                              ]
                            : availableLivestock.map((livestock) {
                                return DropdownMenuItem(
                                  value: livestock.id,
                                  child: Text('${livestock.earTag} (${_getTypeName(livestock.type)})'),
                                );
                              }).toList(),
                        onChanged: availableLivestock.isEmpty
                            ? null
                            : (value) {
                                if (value != null) {
                                  setState(() {
                                    selectedLivestock = value;
                                  });
                                }
                              },
                        validator: (value) {
                          if (value == null || value.isEmpty) return '\u0e01\u0e23\u0e38\u0e13\u0e32\u0e40\u0e25\u0e37\u0e2d\u0e01\u0e1b\u0e28\u0e38\u0e2a\u0e31\u0e15\u0e27\u0e4c';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Price
                      TextFormField(
                        controller: priceController,
                        decoration: const InputDecoration(
                          labelText: 'ราคาขาย (บาท)',
                          border: OutlineInputBorder(),
                          prefixText: '฿ ',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'กรุณาใส่ราคา';
                          if (double.tryParse(value!) == null) return 'กรุณาใส่ตัวเลข';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Min Price
                      TextFormField(
                        controller: minPriceController,
                        decoration: const InputDecoration(
                          labelText: 'ราคาต่ำสุด (บาท)',
                          border: OutlineInputBorder(),
                          prefixText: '฿ ',
                          hintText: 'ถ้าต่อรองได้',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      
                      // Description
                      TextFormField(
                        controller: descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'รายละเอียด',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      
                      // Negotiable
                      CheckboxListTile(
                        title: const Text('ต่อรองราคาได้'),
                        value: isNegotiable,
                        onChanged: (value) {
                          setState(() {
                            isNegotiable = value ?? false;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Image Section
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.image,
                                color: const Color(0xFF228B22),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'รูปภาพสินค้า',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          
                          // Existing images
                          if (existingImageUrls.isNotEmpty) ...[
                            Text(
                              'รูปที่มีอยู่ (${existingImageUrls.length}):',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: existingImageUrls.asMap().entries.map((entry) {
                                final index = entry.key;
                                final url = entry.value;
                                return Stack(
                                  children: [
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey.shade300),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          url,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stack) =>
                                              Icon(Icons.broken_image, color: Colors.grey),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 2,
                                      right: 2,
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            existingImageUrls.removeAt(index);
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(2),
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.close,
                                            size: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 12),
                          ],
                          
                          // New images preview
                          if (newImageBytes.isNotEmpty) ...[
                            Text(
                              'รูปใหม่ (${newImageBytes.length}):',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue[700],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: newImageBytes.asMap().entries.map((entry) {
                                final index = entry.key;
                                final bytes = entry.value;
                                return Stack(
                                  children: [
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.blue.shade300),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.memory(bytes, fit: BoxFit.cover),
                                      ),
                                    ),
                                    Positioned(
                                      top: 2,
                                      right: 2,
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            newImageBytes.removeAt(index);
                                            newImageNames.removeAt(index);
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(2),
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.close,
                                            size: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 12),
                          ],
                          
                          // Upload button
                          if ((existingImageUrls.length + newImageBytes.length) < 9)
                            OutlinedButton.icon(
                              onPressed: () async {
                                final result = await FilePicker.platform.pickFiles(
                                  type: FileType.image,
                                  allowMultiple: true,
                                  withData: true,
                                );
                                
                                if (result != null) {
                                  setState(() {
                                    for (var file in result.files) {
                                      if ((existingImageUrls.length + newImageBytes.length) < 9) {
                                        newImageBytes.add(file.bytes!);
                                        newImageNames.add(file.name);
                                      }
                                    }
                                  });
                                }
                              },
                              icon: Icon(Icons.add_photo_alternate),
                              label: Text('เพิ่มรูป (${existingImageUrls.length + newImageBytes.length}/9)'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF228B22),
                                side: BorderSide(color: const Color(0xFF228B22)),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('ยกเลิก'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    try {
                      // Upload new images to Firebase Storage
                      final storageService = StorageService();
                      final timestamp = DateTime.now().millisecondsSinceEpoch;
                      List<String> newImageUrls = [];
                      
                      for (int i = 0; i < newImageBytes.length; i++) {
                        final url = await storageService.uploadListingImage(
                          newImageBytes[i],
                          '${timestamp}_$i',
                          newImageNames[i],
                        );
                        newImageUrls.add(url);
                      }
                      
                      // Combine existing + new images
                      final finalImages = [...existingImageUrls, ...newImageUrls];
                      
                      // Update Firestore
                      await context.read<TradingProvider>().updateListing(
                        listing.id,
                        {
                          'livestockId': selectedLivestock,
                          'askingPrice': double.parse(priceController.text),
                          'minPrice': minPriceController.text.isNotEmpty 
                              ? double.parse(minPriceController.text) 
                              : null,
                          'description': descriptionController.text.isNotEmpty 
                              ? descriptionController.text 
                              : null,
                          'isNegotiable': isNegotiable,
                          'images': finalImages,
                        },
                      );
                      
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('แก้ไขประกาศเรียบร้อยแล้ว')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
                      );
                    }
                  }
                },
                child: const Text('บันทึก'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _deleteListing(MarketListing listing) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ลบประกาศ', style: TextStyle(fontSize: 24)),
        content: const Text(
          'คุณต้องการลบประกาศนี้หรือไม่?',
          style: TextStyle(fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ยกเลิก', style: TextStyle(fontSize: 20)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('ลบ', style: TextStyle(fontSize: 20)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        // Show loading
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );

        // Delete listing and wait
        await context.read<TradingProvider>().deleteListing(listing.id);

        if (mounted) {
          // Close loading
          Navigator.pop(context);
          
          // Show success
          showSuccessSnackBar(context, 'ลบประกาศเรียบร้อยแล้ว');
        }
      } catch (e) {
        if (mounted) {
          // Close loading
          Navigator.pop(context);
          
          // Show error
          showErrorSnackBar(context, 'เกิดข้อผิดพลาด: $e');
        }
      }
    }
  }

  // Quick Share - Auto-copy + Platform sharing
  void _handleQuickShare(String url, String title) {
    // Auto-copy to clipboard
    Clipboard.setData(ClipboardData(text: url));
    
    // Show SnackBar with sharing options
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                '✅ คัดลอกลิงก์แล้ว! เลือกแชร์ไปที่...',
                style: TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green[700],
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: '❌',
          textColor: Colors.white,
          onPressed: () {},
        ),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(8),
      ),
    );
    
    // Show sharing dialog
    Future.delayed(const Duration(milliseconds: 300), () {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(Icons.share, color: Colors.blue[700]),
                    const SizedBox(width: 8),
                    const Text(
                      'แชร์สินค้าไปยัง',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Share buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Facebook
                    _buildSharePlatformButton(
                      icon: Icons.facebook,
                      label: 'Facebook',
                      color: const Color(0xFF1877F2),
                      onTap: () {
                        final shareUrl = 'https://www.facebook.com/sharer/sharer.php?u=${Uri.encodeComponent(url)}';
                        html.window.open(shareUrl, '_blank');
                        Navigator.pop(context);
                      },
                    ),
                    
                    // LINE
                    _buildSharePlatformButton(
                      icon: Icons.chat,
                      label: 'LINE',
                      color: const Color(0xFF00B900),
                      onTap: () {
                        final shareUrl = 'https://social-plugins.line.me/lineit/share?url=${Uri.encodeComponent(url)}';
                        html.window.open(shareUrl, '_blank');
                        Navigator.pop(context);
                      },
                    ),
                    
                    // Copy again
                    _buildSharePlatformButton(
                      icon: Icons.content_copy,
                      label: 'Copy',
                      color: Colors.grey[700]!,
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: url));
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✅ คัดลอกลิงก์อีกครั้ง'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // URL display
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectableText(
                    url,
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Close button
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('ปิด'),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildPaginationBar(int totalPages, int totalItems) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Total items
          Text(
            'ทั้งหมด $totalItems รายการ',
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          const SizedBox(width: 24),
          
          // Previous button
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _currentPage > 1
                ? () => setState(() {
                      _currentPage--;
                    })
                : null,
            tooltip: 'หน้าก่อนหน้า',
          ),
          
          // Page numbers
          ..._buildPageNumbers(totalPages),
          
          // Next button
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _currentPage < totalPages
                ? () => setState(() {
                      _currentPage++;
                    })
                : null,
            tooltip: 'หน้าถัดไป',
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPageNumbers(int totalPages) {
    List<Widget> pages = [];
    
    // แสดงหน้า: 1 2 3 ... 10 (Shopee style)
    if (totalPages <= 7) {
      // แสดงทุกหน้า
      for (int i = 1; i <= totalPages; i++) {
        pages.add(_buildPageButton(i));
      }
    } else {
      // แสดงแบบ smart
      pages.add(_buildPageButton(1));
      
      if (_currentPage > 3) {
        pages.add(const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text('...', style: TextStyle(fontSize: 16)),
        ));
      }
      
      int start = (_currentPage - 1).clamp(2, totalPages - 2);
      int end = (_currentPage + 1).clamp(3, totalPages - 1);
      
      for (int i = start; i <= end; i++) {
        pages.add(_buildPageButton(i));
      }
      
      if (_currentPage < totalPages - 2) {
        pages.add(const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text('...', style: TextStyle(fontSize: 16)),
        ));
      }
      
      pages.add(_buildPageButton(totalPages));
    }
    
    return pages;
  }

  Widget _buildPageButton(int page) {
    final isActive = page == _currentPage;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: InkWell(
        onTap: () => setState(() {
          _currentPage = page;
        }),
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF228B22) : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isActive ? const Color(0xFF228B22) : Colors.grey.shade300,
            ),
          ),
          child: Text(
            '$page',
            style: TextStyle(
              fontSize: 14,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSharePlatformButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 70,
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
