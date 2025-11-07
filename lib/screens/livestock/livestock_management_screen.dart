import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/livestock_provider.dart';
import '../../providers/survey_provider.dart';
import '../../models/livestock.dart';
import '../../utils/responsive_helper.dart';
import '../../widgets/app_bars/standard_app_bar.dart';
import '../../widgets/production_records_tab.dart';
import '../../utils/tab_navigation_mixin.dart';
import 'dart:math' as math;

class LivestockManagementScreen extends StatefulWidget {
  const LivestockManagementScreen({super.key});

  @override
  State<LivestockManagementScreen> createState() => _LivestockManagementScreenState();
}

class _LivestockManagementScreenState extends State<LivestockManagementScreen> with TickerProviderStateMixin, TabNavigationMixin {
  final TextEditingController _searchController = TextEditingController();
  String _selectedType = 'ทั้งหมด';
  String _selectedStatus = 'ทั้งหมด';
  late TabController _tabController;
  int _selectedIndex = 0;
  
  // Pagination for animal cards
  int _currentPage = 1;
  static const int _itemsPerPage = 12;
  
  // Selected livestock for production records
  Livestock? _selectedLivestock;

  @override
  void initState() {
    super.initState();
    
    // Check for tab parameter in URL (e.g., ?tab=4)
    int initialTab = 0;
    try {
      final uri = Uri.base;
      if (uri.queryParameters.containsKey('tab')) {
        final tabParam = int.tryParse(uri.queryParameters['tab'] ?? '0');
        if (tabParam != null && tabParam >= 0 && tabParam < 6) {
          initialTab = tabParam;
          print('🔗 Opening tab $initialTab from URL parameter');
        }
      }
    } catch (e) {
      print('⚠️ Error parsing tab parameter: $e');
    }
    
    _tabController = TabController(length: 6, vsync: this, initialIndex: initialTab);
    
    // เริ่มต้น Smart Back Navigation
    initTabNavigation(_tabController, initialTab: initialTab, fallbackRoute: '/dashboard');
    
    // ✅ Lazy loading - delay 300ms เพื่อให้หน้าโหลดเร็วก่อน
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        Provider.of<LivestockProvider>(context, listen: false).loadLivestock('farm1');
        Provider.of<SurveyProvider>(context, listen: false).loadSurveys();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    disposeTabNavigation(); // ปิด Smart Back Navigation
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StandardAppBar(
        type: AppBarType.main,
        title: 'จัดการปศุสัตว์',
        onBackPressed: handleSmartBackPress, // ⭐ ใช้ Smart Back Navigation
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF8B4513),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF8B4513),
          isScrollable: true,
          tabs: const [
            Tab(text: 'ภาพรวม', icon: Icon(Icons.dashboard, size: 20)),
            Tab(text: 'ทะเบียนสัตว์', icon: Icon(Icons.pets, size: 20)),
            Tab(text: 'สุขภาพ', icon: Icon(Icons.favorite, size: 20)),
            Tab(text: 'การผสมพันธุ์', icon: Icon(Icons.family_restroom, size: 20)),
            Tab(text: 'อาหาร', icon: Icon(Icons.restaurant, size: 20)),
            Tab(text: 'ผลผลิต', icon: Icon(Icons.analytics, size: 20)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildLivestockRegistry(),
          _buildHealthRecords(),
          _buildBreedingRecords(),
          _buildFeedingRecords(),
          _buildProductionRecords(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: ResponsiveHelper.isMobile(context) ? _buildBottomNav() : null,
    );
  }

  // ภาพรวม - Tab แรก (NEW)
  Widget _buildOverviewTab() {
    return Consumer<SurveyProvider>(
      builder: (context, surveyProvider, child) {
        print('🔍 DEBUG Overview Tab:');
        print('  - isLoading: ${surveyProvider.isLoading}');
        print('  - error: ${surveyProvider.error}');
        
        final stats = surveyProvider.getSurveyStatistics();
        print('  - stats: $stats');
        
        final totalAnimals = stats['totalAnimals'] ?? 0;
        final rawLivestockByType = stats['livestockByType'] ?? {};
        print('  - totalAnimals: $totalAnimals');
        print('  - rawLivestockByType: $rawLivestockByType');
        
        // แปลง livestock types เป็น Map<String, int> และใช้ชื่อไทย
        final livestockByType = _convertToLivestockMap(rawLivestockByType);
        print('  - livestockByType (Thai names): $livestockByType');

        // Show loading
        if (surveyProvider.isLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('กำลังโหลดข้อมูล...'),
              ],
            ),
          );
        }

        // Show error
        if (surveyProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('เกิดข้อผิดพลาด: ${surveyProvider.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => surveyProvider.loadSurveys(),
                  child: const Text('ลองใหม่'),
                ),
              ],
            ),
          );
        }

        // Show empty state
        if (totalAnimals == 0) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.pets, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('ยังไม่มีข้อมูลปศุสัตว์'),
                const SizedBox(height: 8),
                const Text('กรุณาเพิ่มข้อมูลจากแบบฟอร์มสำรวจ'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.go('/survey'),
                  child: const Text('ไปสำรวจข้อมูล'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await surveyProvider.loadSurveys();
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTotalSummaryCard(totalAnimals, livestockByType),
                const SizedBox(height: 24),
                _buildDonutChartSection(livestockByType, totalAnimals),
                const SizedBox(height: 24),
                Text(
                  'รายละเอียดแต่ละชนิด',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF8B4513),
                  ),
                ),
                const SizedBox(height: 16),
                _buildAnimalTypeGrid(livestockByType),
              ],
            ),
          ),
        );
      },
    );
  }

  // Summary Card - ตัวเลขใหญ่
  Widget _buildTotalSummaryCard(int total, Map<String, int> livestockByType) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF8B4513).withOpacity(0.1),
            const Color(0xFFFFF8E1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF8B4513).withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B4513).withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.pets,
            size: 48,
            color: const Color(0xFF8B4513).withOpacity(0.8),
          ),
          const SizedBox(height: 12),
          Text(
            total.toString(),
            style: const TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.bold,
              color: Color(0xFF8B4513),
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'ปศุสัตว์ทั้งหมด',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: _buildQuickStats(livestockByType),
          ),
        ],
      ),
    );
  }

  // Quick Stats Row - Top 6 (Sorted มาก -> น้อย)
  List<Widget> _buildQuickStats(Map<String, int> livestockByType) {
    // Sort จากมาก -> น้อย
    final sortedEntries = livestockByType.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    // เลือก Top 6
    final topEntries = sortedEntries.take(6).toList();
    
    final List<Widget> stats = [];
    
    for (int i = 0; i < topEntries.length; i++) {
      final entry = topEntries[i];
      final color = _getLivestockColor(i);
      
      stats.add(
        InkWell(
          onTap: () {
            // Switch to Registry tab with filter
            setState(() {
              _selectedType = entry.key; // ตั้ง filter ตามชนิดที่คลิก
            });
            _tabController.animateTo(1); // ไปที่ tab ทะเบียนสัตว์
          },
          borderRadius: BorderRadius.circular(8),
          child: Column(
            children: [
              Text(
                _getLivestockEmoji(entry.key),
                style: const TextStyle(fontSize: 32), // emoji ขนาด 32
              ),
              const SizedBox(height: 6),
              Text(
                entry.value.toString(),
                style: TextStyle(
                  fontSize: 22, // ใหญ่ขึ้น 18→22
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                entry.key,
                style: TextStyle(
                  fontSize: 14, // ใหญ่ขึ้น 11→14
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
    }
    
    return stats;
  }

  // Donut Chart Section
  Widget _buildDonutChartSection(Map<String, int> livestockByType, int total) {
    if (total == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'สัดส่วนตามชนิดสัตว์',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF8B4513),
            ),
          ),
          const SizedBox(height: 20),
          _buildSimpleDonutChart(livestockByType, total),
          const SizedBox(height: 20),
          _buildChartLegend(livestockByType, total),
        ],
      ),
    );
  }

  // Simple Donut Chart (no external package) with Hover
  Widget _buildSimpleDonutChart(Map<String, int> livestockByType, int total) {
    // Prepare data: Top 7 + Others
    final donutData = _prepareDonutData(livestockByType);
    
    return Center(
      child: _DonutChartWithHover(
        livestockByType: donutData,
        total: total,
        colorGetter: _getLivestockColor,
        onSegmentTap: (typeName) {
          // เมื่อคลิกที่ segment ของ Pie Chart
          if (typeName != 'อื่นๆ') {
            setState(() {
              _selectedType = typeName; // ตั้งค่า filter
            });
            _tabController.animateTo(1); // ไปที่ Tab ทะเบียนสัตว์
          }
        },
      ),
    );
  }
  
  // Prepare Donut Data: Top 7 + "อื่นๆ"
  Map<String, int> _prepareDonutData(Map<String, int> allData) {
    const int maxSegments = 8; // แสดงสูงสุด 8 segments (7 + อื่นๆ)
    
    // Sort จากมาก -> น้อย
    final sortedEntries = allData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    // ถ้าน้อยกว่าหรือเท่ากับ 8 ชนิด แสดงทั้งหมด
    if (sortedEntries.length <= maxSegments) {
      return Map.fromEntries(sortedEntries);
    }
    
    // เลือก Top 7
    final topEntries = sortedEntries.take(7).toList();
    
    // รวมที่เหลือเป็น "อื่นๆ"
    final othersCount = sortedEntries.skip(7).fold<int>(
      0, 
      (sum, entry) => sum + entry.value,
    );
    
    final result = Map<String, int>.fromEntries(topEntries);
    if (othersCount > 0) {
      result['อื่นๆ'] = othersCount;
    }
    
    return result;
  }

  // Chart Legend - Dynamic (แสดง Top 7 + อื่นๆ)
  Widget _buildChartLegend(Map<String, int> livestockByType, int total) {
    // Prepare data เหมือน donut chart
    final legendData = _prepareDonutData(livestockByType);
    
    int colorIndex = 0;
    return Wrap(
      spacing: 16,
      runSpacing: 12,
      children: legendData.entries.where((e) => e.value > 0).map((entry) {
        final percentage = ((entry.value / total) * 100).toStringAsFixed(1);
        final color = _getLivestockColor(colorIndex);
        colorIndex++;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${entry.key}: ${entry.value} ($percentage%)',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        );
      }).toList(),
    );
  }

  // Animal Type Grid Cards - แสดงทุกชนิด (Sorted + Pagination)
  Widget _buildAnimalTypeGrid(Map<String, int> livestockByType) {
    // Sort จากมาก -> น้อย
    final sortedEntries = livestockByType.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    // Calculate pagination
    final totalItems = sortedEntries.length;
    final totalPages = (totalItems / _itemsPerPage).ceil();
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, totalItems);
    
    // Get items for current page
    final displayItems = sortedEntries.sublist(startIndex, endIndex);
    
    return Column(
      children: [
        // Grid Cards
        GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: ResponsiveHelper.isMobile(context) ? 2 : 6,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: ResponsiveHelper.isMobile(context) ? 0.75 : 0.85,
          ),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: displayItems.length,
          itemBuilder: (context, index) {
            final entry = displayItems[index];
            final globalIndex = startIndex + index; // For color consistency
            final color = _getLivestockColor(globalIndex);
            final emoji = _getLivestockEmoji(entry.key);
            
            return _buildAnimalTypeCard(
              entry.key,
              entry.value,
              emoji,
              color,
            );
          },
        ),
        
        // Pagination Controls (if needed)
        if (totalPages > 1) ...[
          const SizedBox(height: 24),
          _buildPaginationControls(totalPages),
        ],
      ],
    );
  }
  
  // Pagination Controls
  Widget _buildPaginationControls(int totalPages) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: _currentPage > 1
              ? () {
                  setState(() {
                    _currentPage--;
                  });
                }
              : null,
        ),
        const SizedBox(width: 8),
        Text(
          'หน้า $_currentPage / $totalPages',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: _currentPage < totalPages
              ? () {
                  setState(() {
                    _currentPage++;
                  });
                }
              : null,
        ),
      ],
    );
  }

  // Animal Type Card - เหมาะกับผู้สูงอายุ 60+ (ใช้ Emoji)
  Widget _buildAnimalTypeCard(String name, int count, String emoji, Color color) {
    return InkWell(
      onTap: () {
        // Switch to Registry tab with filter
        setState(() {
          _selectedType = name; // ตั้ง filter ตามชนิดที่คลิก
        });
        _tabController.animateTo(1);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.15),
              color.withOpacity(0.08),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.4), width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 48), // emoji ขนาด 48
            ), // รูปสัตว์จริง
            const SizedBox(height: 12),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 32, // ใหญ่ขึ้น 24→32
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              name,
              style: TextStyle(
                fontSize: 16, // ใหญ่ขึ้น 13→16
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // Helper: แปลง livestock types เป็น Map<String, int> พร้อมชื่อไทย
  Map<String, int> _convertToLivestockMap(dynamic rawData) {
    final Map<String, int> result = {};

    if (rawData == null) return result;

    // Convert to Map<String, dynamic>
    final Map<String, dynamic> data = Map<String, dynamic>.from(rawData as Map);

    data.forEach((key, value) {
      final count = (value is int) ? value : 0;
      
      if (count > 0) {
        // แปลง key เป็นชื่อไทยจาก LivestockType enum
        final thaiName = _getLivestockThaiName(key);
        result[thaiName] = count;
      }
    });

    print('🔍 Converted livestock: $result');
    return result;
  }

  // แปลง livestock_type เป็นชื่อไทย
  String _getLivestockThaiName(String englishKey) {
    try {
      // พยายามหา LivestockType จาก enum
      final livestockType = LivestockType.values.firstWhere(
        (type) => type.name == englishKey,
        orElse: () => LivestockType.other,
      );
      return livestockType.displayName;
    } catch (e) {
      print('⚠️ Unknown livestock type: $englishKey');
      return englishKey; // ถ้าไม่เจอให้ใช้ชื่อ key เดิม
    }
  }

  // ดึง emoji สำหรับสัตว์แต่ละชนิด (รูปสัตว์จริง)
  String _getLivestockEmoji(String thaiName) {
    // โค (Cow) - 🐄
    if (thaiName.contains('โคเนื้อ')) return '🐂'; // โคเนื้อ
    if (thaiName.contains('โคนม')) return '🐄'; // โคนม
    
    // กระบือ (Buffalo) - 🐃
    if (thaiName.contains('กระบือ')) return '🐃'; // กระบือ
    
    // สุกร (Pig) - 🐷🐖
    if (thaiName.contains('สุกร')) return '🐷'; // สุกร
    
    // ไก่ (Chicken) - 🐔🍗🥚
    if (thaiName.contains('ไก่เนื้อ')) return '🍗'; // ไก่เนื้อ
    if (thaiName.contains('ไก่ไข่')) return '🥚'; // ไก่ไข่
    if (thaiName.contains('ไก่พ่อ-แม่') || thaiName.contains('ไก่ปู่-ย่า')) return '🐣'; // พันธุ์
    if (thaiName.contains('ไก่')) return '🐔'; // ไก่ทั่วไป
    
    // เป็ด (Duck) - 🦆🥚
    if (thaiName.contains('เป็ดเทศ')) return '🦆'; // เป็ดเทศ
    if (thaiName.contains('เป็ดไข่')) return '🥚'; // เป็ดไข่
    if (thaiName.contains('เป็ด')) return '🦆'; // เป็ดทั่วไป
    
    // นกกระทา (Quail) - 🐦
    if (thaiName.contains('นกกระทา') || thaiName.contains('กระทา')) return '🐦'; // นกกระทา
    
    // แพะ (Goat) - 🐐
    if (thaiName.contains('แพะ')) return '🐐'; // แพะ
    
    // แกะ (Sheep) - 🐑
    if (thaiName.contains('แกะ')) return '🐑'; // แกะ
    
    // สัตว์เลี้ยง (Pets)
    if (thaiName.contains('สุนัข')) return '🐕'; // สุนัข
    if (thaiName.contains('แมว')) return '🐈'; // แมว
    if (thaiName.contains('นกสวยงาม')) return '🦜'; // นกสวยงาม
    if (thaiName.contains('ปลาสวยงาม')) return '🐠'; // ปลาสวยงาม
    
    // สัตว์น้ำ (Aquatic)
    if (thaiName.contains('ปลาน้ำจืด')) return '🐟'; // ปลาน้ำจืด
    if (thaiName.contains('ปลาน้ำเค็ม')) return '🐠'; // ปลาน้ำเค็ม
    if (thaiName.contains('กุ้ง')) return '🦐'; // กุ้ง
    if (thaiName.contains('ปู')) return '🦀'; // ปู
    
    // แมลง (Insects)
    if (thaiName.contains('จิ้งหรีด')) return '🦗'; // จิ้งหรีด
    if (thaiName.contains('หนอนไหม')) return '🐛'; // หนอนไหม
    if (thaiName.contains('ผึ้ง')) return '🐝'; // ผึ้ง
    
    // อื่นๆ
    if (thaiName.contains('อื่น')) return '🐾'; // อื่นๆ
    
    return '🐾'; // default
  }

  // ดึงสีตามลำดับ
  Color _getLivestockColor(int index) {
    final colors = [
      const Color(0xFF8B4513), // Brown
      const Color(0xFF228B22), // Green
      const Color(0xFFDAA520), // Yellow
      const Color(0xFF4682B4), // Blue
      const Color(0xFFFF8C00), // Orange
      const Color(0xFF9C27B0), // Purple
      const Color(0xFFE91E63), // Pink
      const Color(0xFF00BCD4), // Cyan
      const Color(0xFF8BC34A), // Light Green
      const Color(0xFFFF5722), // Deep Orange
    ];
    return colors[index % colors.length];
  }

  // ทะเบียนสัตว์ - Tab ที่สอง (ดึงจาก survey_livestock)
  Widget _buildLivestockRegistry() {
    return Consumer<SurveyProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // ดึงข้อมูลจาก survey_livestock (แบบ grouped)
        final allLivestock = provider.getGroupedLivestockFromSurveys();
        print('📊 Total grouped livestock: ${allLivestock.length}');
        
        final filteredLivestock = _getFilteredSurveyLivestock(allLivestock);
        print('✅ Filtered livestock count: ${filteredLivestock.length}');

        if (allLivestock.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🐾', style: TextStyle(fontSize: 64)),
                const SizedBox(height: 16),
                const Text('ไม่พบข้อมูลปศุสัตว์', style: TextStyle(fontSize: 18, color: Colors.grey)),
                const SizedBox(height: 8),
                const Text('กรุณาบันทึกข้อมูลจากแบบฟอร์มสำรวจ', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => context.go('/survey'),
                  icon: const Text('📋', style: TextStyle(fontSize: 20)),
                  label: const Text('ไปสำรวจข้อมูล'),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            _buildSearchAndFilterForSurvey(),
            _buildSummaryCardsFromSurvey(filteredLivestock),
            Expanded(
              child: _buildSurveyLivestockList(filteredLivestock),
            ),
          ],
        );
      },
    );
  }

  // บันทึกสุขภาพ - Tab ที่สอง
  Widget _buildHealthRecords() {
    return Consumer<LivestockProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            _buildHealthSummary(),
            Expanded(
              child: _buildHealthRecordsList(),
            ),
          ],
        );
      },
    );
  }

  // การผสมพันธุ์ - Tab ที่สาม
  Widget _buildBreedingRecords() {
    return Column(
      children: [
        _buildBreedingSummary(),
        Expanded(
          child: _buildBreedingList(),
        ),
      ],
    );
  }

  // การให้อาหาร - Tab ที่สี่
  Widget _buildFeedingRecords() {
    return Column(
      children: [
        _buildFeedingSummary(),
        Expanded(
          child: _buildFeedingList(),
        ),
      ],
    );
  }

  // ผลผลิต - Tab ที่ห้า (NEW - Connected to API)
  Widget _buildProductionRecords() {
    return Consumer<LivestockProvider>(
      builder: (context, livestockProvider, child) {
        // If no livestock selected, show selection UI
        if (_selectedLivestock == null) {
          return _buildLivestockSelector(livestockProvider);
        }
        
        // Show production records for selected livestock
        return Column(
          children: [
            _buildSelectedLivestockInfo(),
            Expanded(
              child: ProductionRecordsTab(livestock: _selectedLivestock),
            ),
          ],
        );
      },
    );
  }
  
  /// Livestock selector for production records
  Widget _buildLivestockSelector(LivestockProvider provider) {
    final livestock = provider.livestock;
    
    if (livestock.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pets, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'ยังไม่มีสัตว์ในระบบ',
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            const Text(
              'กรุณาเพิ่มสัตว์ก่อนบันทึกผลผลิต',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey[50],
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.blue),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'เลือกสัตว์เพื่อดูและบันทึกผลผลิต',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: livestock.length,
            itemBuilder: (context, index) {
              final animal = livestock[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green[100],
                    child: Text(
                      animal.earTag ?? animal.id.substring(0, 3),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                  title: Text(
                    '${animal.type.displayName} #${animal.earTag ?? animal.id}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'พันธุ์: ${animal.breed ?? "ไม่ระบุ"} • ${_getAgeText(animal.birthDate)}',
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    setState(() {
                      _selectedLivestock = animal;
                    });
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  
  /// Calculate age text from birthDate
  String _getAgeText(DateTime? birthDate) {
    if (birthDate == null) return 'อายุ: ไม่ระบุ';
    
    final now = DateTime.now();
    final age = now.difference(birthDate);
    final years = age.inDays ~/ 365;
    final months = (age.inDays % 365) ~/ 30;
    
    if (years > 0) {
      return 'อายุ: $years ปี${months > 0 ? " $months เดือน" : ""}';
    } else if (months > 0) {
      return 'อายุ: $months เดือน';
    } else {
      final days = age.inDays;
      return 'อายุ: $days วัน';
    }
  }

  /// Show selected livestock info with back button
  Widget _buildSelectedLivestockInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              setState(() {
                _selectedLivestock = null;
              });
            },
            tooltip: 'กลับไปเลือกสัตว์',
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Colors.green,
            child: Text(
              _selectedLivestock!.earTag ?? _selectedLivestock!.id.substring(0, 3),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_selectedLivestock!.type.displayName} #${_selectedLivestock!.earTag ?? _selectedLivestock!.id}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'พันธุ์: ${_selectedLivestock!.breed}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[50],
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'ค้นหาด้วยหมายเลขสัตว์หรือพันธุ์...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (value) {
              setState(() {});
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: InputDecoration(
                    labelText: 'ประเภทสัตว์',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: ['ทั้งหมด', 'โค', 'สุกร', 'ไก่', 'แพะ', 'แกะ', 'เป็ด', 'ปลา']
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value!;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: InputDecoration(
                    labelText: 'สถานะสุขภาพ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: ['ทั้งหมด', 'แข็งแรง', 'ป่วย', 'รักษา', 'กักกัน']
                      .map((status) => DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value!;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(LivestockProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCardEmoji(
              'ปศุสัตว์ทั้งหมด',
              provider.livestock.length.toString(),
              '🐂', // Changed from Icons.pets to cow emoji
              Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'สุขภาพดี',
              provider.livestock.where((l) => l.healthStatus == 'healthy').length.toString(),
              Icons.favorite,
              Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'ต้องดูแล',
              provider.livestock.where((l) => l.healthStatus == 'sick').length.toString(),
              Icons.warning,
              Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLivestockList(List<Livestock> livestock) {
    if (livestock.isEmpty) {
      return const Center(
        child: Text('ไม่พบข้อมูลปศุสัตว์'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: livestock.length,
      itemBuilder: (context, index) {
        final animal = livestock[index];
        return _buildLivestockCard(animal);
      },
    );
  }

  Widget _buildLivestockCard(Livestock animal) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildAnimalIcon(animal.type.name),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'รหัส: ${animal.tagNumber}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_getAnimalTypeName(animal.type.name)} ${animal.breed ?? 'ไม่ระบุ'}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                _buildHealthStatusChip(animal.healthStatus),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildInfoChip('อายุ: ${animal.birthDate != null ? _calculateAge(animal.birthDate!) : 'ไม่ระบุ'} เดือน', Colors.blue),
                const SizedBox(width: 8),
                _buildInfoChip('น้ำหนัก: ${animal.weight} กก.', Colors.green),
                const SizedBox(width: 8),
                _buildInfoChip('เพศ: ${animal.gender.displayName}', Colors.purple),
              ],
            ),
            if (animal.notes != null) ...[
              const SizedBox(height: 8),
              Text(
                'หมายเหตุ: ${animal.notes}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnimalIcon(String type) {
    IconData icon;
    Color color;
    
    switch (type) {
      case 'cattle':
        icon = Icons.pets;
        color = Colors.brown;
        break;
      case 'pig':
        icon = Icons.pets;
        color = Colors.pink;
        break;
      case 'chicken':
        icon = Icons.egg;
        color = Colors.orange;
        break;
      case 'goat':
        icon = Icons.pets;
        color = Colors.grey;
        break;
      case 'duck':
        icon = Icons.pets;
        color = Colors.blue;
        break;
      case 'fish':
        icon = Icons.water;
        color = Colors.cyan;
        break;
      default:
        icon = Icons.pets;
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  Widget _buildHealthStatusChip(String status) {
    Color color;
    String text;
    
    switch (status) {
      case 'healthy':
        color = Colors.green;
        text = 'แข็งแรง';
        break;
      case 'sick':
        color = Colors.red;
        text = 'ป่วย';
        break;
      case 'pregnant':
        color = Colors.orange;
        text = 'ท้อง';
        break;
      case 'sold':
        color = Colors.grey;
        text = 'ขายแล้ว';
        break;
      default:
        color = Colors.grey;
        text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _getAnimalTypeName(String type) {
    switch (type) {
      case 'dairyCow':
      case 'beefCattleLocal':
      case 'beefCattleImported':
        return 'โค';
      case 'pigFattening':
      case 'pigBreeder':
        return 'สุกร';
      case 'chickenLayer':
      case 'chickenBroiler':
        return 'ไก่';
      case 'goatMeat':
      case 'goatMilk':
        return 'แพะ';
      case 'sheepMeat':
      case 'sheepWool':
        return 'แกะ';
      case 'duckMeat':
      case 'duckEgg':
        return 'เป็ด';
      case 'fishFreshwater':
      case 'fishSaltwater':
        return 'ปลา';
      default:
        return type;
    }
  }

  int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    final difference = now.difference(birthDate);
    return (difference.inDays / 30).round();
  }

  // Search & Filter สำหรับ Survey Livestock
  Widget _buildSearchAndFilterForSurvey() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[50],
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'ค้นหาชื่อเกษตรกร หรือชนิดสัตว์...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        onChanged: (value) {
          setState(() {});
        },
      ),
    );
  }

  // Summary Cards จาก Survey (grouped data) - Updated v2
  Widget _buildSummaryCardsFromSurvey(List<Map<String, dynamic>> livestock) {
    final totalCount = livestock.fold<int>(0, (sum, item) => sum + (item['totalCount'] as int));
    final uniqueFarmers = livestock.map((e) => e['farmerId']).toSet().length;

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[50],
      child: Row(
        children: [
          Expanded(
            child: _buildStatCardEmoji('จำนวนสัตว์', totalCount.toString(), '🐂', Colors.blue), // Force rebuild 18:41
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCardEmoji('จำนวนเกษตรกร', uniqueFarmers.toString(), '👨‍🌾', Colors.green),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCardEmoji(String label, String value, String emoji, Color color) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 200;
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 2 : 8,
            vertical: isMobile ? 2 : 8,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  emoji,
                  style: TextStyle(fontSize: isMobile ? 14 : 24),
                  maxLines: 1,
                ),
              ),
              const SizedBox(height: 4),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: isMobile ? 13 : 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: isMobile ? 7 : 11,
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // List สำหรับ Survey Livestock (แบบ grouped)
  Widget _buildSurveyLivestockList(List<Map<String, dynamic>> livestock) {
    return RefreshIndicator(
      onRefresh: () async {
        await Provider.of<SurveyProvider>(context, listen: false).loadSurveys();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: livestock.length,
        itemBuilder: (context, index) {
          final animal = livestock[index];
          final details = animal['details'] as List<Map<String, dynamic>>;
          final color = _getLivestockColor(index % 10);
          
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: color.withOpacity(0.3), width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: color.withOpacity(0.2),
                        radius: 24,
                        child: Text(
                          _getLivestockEmoji(animal['typeName']),
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              animal['typeName'],
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '👤 ${animal['farmerName']}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '📍 ${animal['farmerAddress']}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Total badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: color.withOpacity(0.3)),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '${animal['totalCount']}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                            Text(
                              'ตัว',
                              style: TextStyle(
                                fontSize: 12,
                                color: color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  // Divider
                  if (details.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Divider(color: color.withOpacity(0.2)),
                    const SizedBox(height: 8),
                  ],
                  
                  // Details
                  ...details.map((detail) {
                    final ageGroup = detail['ageGroup'] as String?;
                    final count = detail['count'] as int;
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              ageGroup ?? 'ไม่ระบุกลุ่ม',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$count ตัว',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Filter สำหรับ survey_livestock
  List<Map<String, dynamic>> _getFilteredSurveyLivestock(List<Map<String, dynamic>> livestock) {
    var filtered = livestock;

    // Filter by search query (ค้นหาจากชื่อเกษตรกร)
    if (_searchController.text.isNotEmpty) {
      filtered = filtered.where((animal) =>
          animal['farmerName'].toLowerCase().contains(_searchController.text.toLowerCase()) ||
          animal['typeName'].toLowerCase().contains(_searchController.text.toLowerCase())).toList();
    }

    // Filter by type - รองรับชื่อไทยจาก Overview
    if (_selectedType != 'ทั้งหมด') {
      filtered = filtered.where((animal) {
        final typeName = animal['typeName'] as String;
        return typeName == _selectedType;
      }).toList();
    }

    return filtered;
  }

  // สรุปข้อมูลสุขภาพ
  Widget _buildHealthSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[50],
      child: Row(
        children: [
          Expanded(
            child: _buildHealthStatCard('สัตว์แข็งแรง', '45', Colors.green),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildHealthStatCard('ต้องรักษา', '3', Colors.orange),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildHealthStatCard('ฉีดวัคซีนแล้ว', '42', Colors.blue),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // รายการบันทึกสุขภาพ
  Widget _buildHealthRecordsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 8,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.red.withOpacity(0.1),
              child: const Icon(Icons.favorite, color: Colors.red),
            ),
            title: Text('โค #L00${index + 1}'),
            subtitle: Text('ตรวจสุขภาพประจำเดือน - ${_getRandomDate()}'),
            trailing: Chip(
              label: Text(_getHealthStatus(index)),
              backgroundColor: _getHealthStatusColor(index).withOpacity(0.1),
              labelStyle: TextStyle(color: _getHealthStatusColor(index)),
            ),
            onTap: () => _showHealthDetailDialog(index),
          ),
        );
      },
    );
  }

  // สรุปข้อมูลการผสมพันธุ์
  Widget _buildBreedingSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[50],
      child: Row(
        children: [
          Expanded(
            child: _buildBreedingStatCard('ตั้งท้อง', '8', Colors.pink),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildBreedingStatCard('คลอดแล้ว', '12', Colors.green),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildBreedingStatCard('รอผสม', '5', Colors.orange),
          ),
        ],
      ),
    );
  }

  Widget _buildBreedingStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // รายการบันทึกการผสมพันธุ์
  Widget _buildBreedingList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.pink.withOpacity(0.1),
              child: const Icon(Icons.family_restroom, color: Colors.pink),
            ),
            title: Text('แม่พันธุ์ #L00${index + 1}'),
            subtitle: Text('ผสมพันธุ์เมื่อ ${_getRandomDate()}\nคาดคลอด: ${_getRandomFutureDate()}'),
            trailing: Chip(
              label: Text(_getBreedingStatus(index)),
              backgroundColor: _getBreedingStatusColor(index).withOpacity(0.1),
              labelStyle: TextStyle(color: _getBreedingStatusColor(index)),
            ),
            onTap: () => _showBreedingDetailDialog(index),
          ),
        );
      },
    );
  }

  // สรุปข้อมูลการให้อาหาร
  Widget _buildFeedingSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[50],
      child: Row(
        children: [
          Expanded(
            child: _buildFeedingStatCard('ต้นทุนวันนี้', '2,450', Colors.orange, '฿'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildFeedingStatCard('เดือนนี้', '73,500', Colors.blue, '฿'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildFeedingStatCard('อาหารคงเหลือ', '850', Colors.green, 'กก.'),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedingStatCard(String title, String value, Color color, String unit) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          RichText(
            text: TextSpan(
              text: value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              children: [
                TextSpan(
                  text: ' $unit',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // รายการบันทึกการให้อาหาร
  Widget _buildFeedingList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 10,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.orange.withOpacity(0.1),
              child: const Icon(Icons.restaurant, color: Colors.orange),
            ),
            title: Text('${_getFeedType(index)} - ${_getRandomAmount()} กก.'),
            subtitle: Text('${_getRandomDate()} • ต้นทุน ${_getRandomCost()} บาท'),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showFeedingEditDialog(index),
            ),
          ),
        );
      },
    );
  }

  // สรุปข้อมูลผลผลิต
  Widget _buildProductionSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[50],
      child: Row(
        children: [
          Expanded(
            child: _buildProductionStatCard('นมวันนี้', '245', Colors.blue, 'ลิตร'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildProductionStatCard('ไข่วันนี้', '180', Colors.orange, 'ฟอง'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildProductionStatCard('รายได้เดือน', '125,000', Colors.green, '฿'),
          ),
        ],
      ),
    );
  }

  Widget _buildProductionStatCard(String title, String value, Color color, String unit) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          RichText(
            text: TextSpan(
              text: value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              children: [
                TextSpan(
                  text: ' $unit',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // รายการบันทึกผลผลิต
  Widget _buildProductionList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 12,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green.withOpacity(0.1),
              child: Icon(_getProductionIcon(index), color: Colors.green),
            ),
            title: Text('${_getProductionType(index)} - ${_getProductionAmount(index)}'),
            subtitle: Text('${_getRandomDate()} • รายได้ ${_getProductionIncome(index)} บาท'),
            trailing: IconButton(
              icon: const Icon(Icons.analytics),
              onPressed: () => _showProductionDetailDialog(index),
            ),
          ),
        );
      },
    );
  }

  // Bottom Navigation สำหรับมือถือ
  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
          _tabController.animateTo(index);
        });
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF8B4513),
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'ภาพรวม',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.pets),
          label: 'ทะเบียน',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: 'สุขภาพ',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.family_restroom),
          label: 'ผสมพันธุ์',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.restaurant),
          label: 'อาหาร',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.analytics),
          label: 'ผลผลิต',
        ),
      ],
    );
  }

  // ฟังก์ชันสำหรับแสดง Dialog เพิ่มข้อมูล
  void _showAddDialog() {
    final tabs = ['ภาพรวม', 'ทะเบียนสัตว์', 'บันทึกสุขภาพ', 'บันทึกการผสม', 'บันทึกอาหาร', 'บันทึกผลผลิต'];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('เพิ่ม${tabs[_tabController.index]}'),
        content: Text('เพิ่มข้อมูล${tabs[_tabController.index]}ใหม่'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // เพิ่มฟังก์ชันบันทึกข้อมูลตาม Tab ที่เลือก
            },
            child: const Text('บันทึก'),
          ),
        ],
      ),
    );
  }

  // ฟังก์ชันสำหรับแสดงรายละเอียดสุขภาพ
  void _showHealthDetailDialog(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('รายละเอียดสุขภาพ โค #L00${index + 1}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('สถานะ: ${_getHealthStatus(index)}'),
            const SizedBox(height: 8),
            Text('วันที่ตรวจ: ${_getRandomDate()}'),
            const SizedBox(height: 8),
            Text('อาการ: ${_getHealthSymptoms(index)}'),
            const SizedBox(height: 8),
            Text('การรักษา: ${_getTreatment(index)}'),
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
              // เพิ่มฟังก์ชันแก้ไขข้อมูลสุขภาพ
            },
            child: const Text('แก้ไข'),
          ),
        ],
      ),
    );
  }

  // ฟังก์ชันสำหรับแสดงรายละเอียดการผสมพันธุ์
  void _showBreedingDetailDialog(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('รายละเอียดการผสมพันธุ์ #L00${index + 1}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('สถานะ: ${_getBreedingStatus(index)}'),
            const SizedBox(height: 8),
            Text('วันที่ผสม: ${_getRandomDate()}'),
            const SizedBox(height: 8),
            Text('พ่อพันธุ์: ${_getFatherBreed(index)}'),
            const SizedBox(height: 8),
            Text('คาดคลอด: ${_getRandomFutureDate()}'),
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
              // เพิ่มฟังก์ชันแก้ไขข้อมูลการผสมพันธุ์
            },
            child: const Text('แก้ไข'),
          ),
        ],
      ),
    );
  }

  // ฟังก์ชันสำหรับแก้ไขข้อมูลอาหาร
  void _showFeedingEditDialog(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('แก้ไขข้อมูลอาหาร'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'ประเภทอาหาร'),
              controller: TextEditingController(text: _getFeedType(index)),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(labelText: 'ปริมาณ (กก.)'),
              controller: TextEditingController(text: _getRandomAmount()),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(labelText: 'ต้นทุน (บาท)'),
              controller: TextEditingController(text: _getRandomCost()),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // เพิ่มฟังก์ชันบันทึกข้อมูลอาหาร
            },
            child: const Text('บันทึก'),
          ),
        ],
      ),
    );
  }

  // ฟังก์ชันสำหรับแสดงรายละเอียดผลผลิต
  void _showProductionDetailDialog(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('รายละเอียดผลผลิต'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ประเภท: ${_getProductionType(index)}'),
            const SizedBox(height: 8),
            Text('ปริมาณ: ${_getProductionAmount(index)}'),
            const SizedBox(height: 8),
            Text('วันที่: ${_getRandomDate()}'),
            const SizedBox(height: 8),
            Text('รายได้: ${_getProductionIncome(index)} บาท'),
            const SizedBox(height: 8),
            Text('คุณภาพ: ${_getProductionQuality(index)}'),
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
              // เพิ่มฟังก์ชันแก้ไขข้อมูลผลผลิต
            },
            child: const Text('แก้ไข'),
          ),
        ],
      ),
    );
  }

  // Helper functions สำหรับข้อมูลตัวอย่าง
  String _getRandomDate() {
    final dates = ['15/11/2024', '14/11/2024', '13/11/2024', '12/11/2024', '11/11/2024'];
    return dates[DateTime.now().millisecond % dates.length];
  }

  String _getRandomFutureDate() {
    final dates = ['15/02/2025', '20/02/2025', '25/02/2025', '01/03/2025', '05/03/2025'];
    return dates[DateTime.now().millisecond % dates.length];
  }

  String _getHealthStatus(int index) {
    final statuses = ['แข็งแรง', 'ป่วยเล็กน้อย', 'รักษา', 'แข็งแรง', 'แข็งแรง'];
    return statuses[index % statuses.length];
  }

  Color _getHealthStatusColor(int index) {
    final colors = [Colors.green, Colors.orange, Colors.red, Colors.green, Colors.green];
    return colors[index % colors.length];
  }

  String _getHealthSymptoms(int index) {
    final symptoms = ['ปกติดี', 'เบื่อกิน', 'มีไข้', 'ปกติดี', 'ปกติดี'];
    return symptoms[index % symptoms.length];
  }

  String _getTreatment(int index) {
    final treatments = ['-', 'ให้วิตามิน', 'ยาลดไข้', '-', '-'];
    return treatments[index % treatments.length];
  }

  String _getBreedingStatus(int index) {
    final statuses = ['ตั้งท้อง', 'คลอดแล้ว', 'รอผสม', 'ตั้งท้อง', 'คลอดแล้ว'];
    return statuses[index % statuses.length];
  }

  Color _getBreedingStatusColor(int index) {
    final colors = [Colors.pink, Colors.green, Colors.orange, Colors.pink, Colors.green];
    return colors[index % colors.length];
  }

  String _getFatherBreed(int index) {
    final breeds = ['โฮลสไตน์ #M001', 'บราห์มัน #M002', 'โฮลสไตน์ #M003', 'บราห์มัน #M001', 'โฮลสไตน์ #M002'];
    return breeds[index % breeds.length];
  }

  String _getFeedType(int index) {
    final feeds = ['หญ้าแห้ง', 'ข้าวโพดบด', 'รำข้าว', 'หญ้าสด', 'อาหารสำเร็จรูป'];
    return feeds[index % feeds.length];
  }

  String _getRandomAmount() {
    final amounts = ['25', '30', '15', '40', '20'];
    return amounts[DateTime.now().millisecond % amounts.length];
  }

  String _getRandomCost() {
    final costs = ['450', '650', '300', '800', '500'];
    return costs[DateTime.now().millisecond % costs.length];
  }

  String _getProductionType(int index) {
    final types = ['นมสด', 'ไข่ไก่', 'นมสด', 'ไข่เป็ด', 'นมสด'];
    return types[index % types.length];
  }

  String _getProductionAmount(int index) {
    final amounts = ['25 ลิตร', '30 ฟอง', '22 ลิตร', '15 ฟอง', '28 ลิตร'];
    return amounts[index % amounts.length];
  }

  String _getProductionIncome(int index) {
    final incomes = ['750', '150', '660', '90', '840'];
    return incomes[index % incomes.length];
  }

  String _getProductionQuality(int index) {
    final qualities = ['เกรด A', 'เกรด B', 'เกรด A', 'เกรด A', 'เกรด A'];
    return qualities[index % qualities.length];
  }

  IconData _getProductionIcon(int index) {
    final icons = [Icons.local_drink, Icons.egg, Icons.local_drink, Icons.egg_alt, Icons.local_drink];
    return icons[index % icons.length];
  }

  // Old IconData function removed - using _getLivestockEmoji() instead
}

// Donut Chart Widget with Hover
class _DonutChartWithHover extends StatefulWidget {
  final Map<String, int> livestockByType;
  final int total;
  final Color Function(int) colorGetter;
  final Function(String)? onSegmentTap;

  const _DonutChartWithHover({
    required this.livestockByType,
    required this.total,
    required this.colorGetter,
    this.onSegmentTap,
  });

  @override
  State<_DonutChartWithHover> createState() => _DonutChartWithHoverState();
}

class _DonutChartWithHoverState extends State<_DonutChartWithHover> {
  String? _hoveredSegment;
  int? _hoveredCount;
  Offset? _mousePosition;

  void _handleHover(PointerEvent details) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final localPosition = box.globalToLocal(details.position);
    
    final center = Offset(box.size.width / 2, box.size.height / 2);
    final dx = localPosition.dx - center.dx;
    final dy = localPosition.dy - center.dy;
    final distance = math.sqrt(dx * dx + dy * dy);
    
    final radius = math.min(box.size.width, box.size.height) / 2;
    final innerRadius = radius * 0.6;
    
    // Check if mouse is in donut area
    if (distance >= innerRadius && distance <= radius) {
      // Calculate angle
      var angle = math.atan2(dy, dx);
      angle = (angle + math.pi / 2) % (2 * math.pi);
      if (angle < 0) angle += 2 * math.pi;
      
      // Find which segment
      double currentAngle = 0;
      int index = 0;
      
      for (var entry in widget.livestockByType.entries) {
        if (entry.value > 0) {
          final sweepAngle = (entry.value / widget.total) * 2 * math.pi;
          
          if (angle >= currentAngle && angle < currentAngle + sweepAngle) {
            setState(() {
              _hoveredSegment = entry.key;
              _hoveredCount = entry.value;
              _mousePosition = details.position;
            });
            return;
          }
          
          currentAngle += sweepAngle;
          index++;
        }
      }
    }
    
    // Not hovering on any segment
    setState(() {
      _hoveredSegment = null;
      _hoveredCount = null;
      _mousePosition = null;
    });
  }

  void _handleExit(PointerEvent details) {
    setState(() {
      _hoveredSegment = null;
      _hoveredCount = null;
      _mousePosition = null;
    });
  }

  void _handleTap(TapUpDetails details) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final localPosition = box.globalToLocal(details.globalPosition);
    
    final center = Offset(box.size.width / 2, box.size.height / 2);
    final dx = localPosition.dx - center.dx;
    final dy = localPosition.dy - center.dy;
    final distance = math.sqrt(dx * dx + dy * dy);
    
    final radius = math.min(box.size.width, box.size.height) / 2;
    final innerRadius = radius * 0.6;
    
    // Check if tap is in donut area
    if (distance >= innerRadius && distance <= radius) {
      // Calculate angle
      var angle = math.atan2(dy, dx);
      angle = (angle + math.pi / 2) % (2 * math.pi);
      if (angle < 0) angle += 2 * math.pi;
      
      // Find which segment was tapped
      double currentAngle = 0;
      
      for (var entry in widget.livestockByType.entries) {
        if (entry.value > 0) {
          final sweepAngle = (entry.value / widget.total) * 2 * math.pi;
          
          if (angle >= currentAngle && angle < currentAngle + sweepAngle) {
            // Segment found - call callback
            widget.onSegmentTap?.call(entry.key);
            return;
          }
          
          currentAngle += sweepAngle;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: _hoveredSegment != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onHover: _handleHover,
      onExit: _handleExit,
      child: GestureDetector(
        onTapUp: _handleTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            SizedBox(
              width: 200,
              height: 200,
              child: CustomPaint(
                painter: _DonutChartPainter(
                  widget.livestockByType,
                  widget.total,
                  widget.colorGetter,
                  _hoveredSegment,
                ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.total.toString(),
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8B4513),
                      ),
                    ),
                    Text(
                      'ตัว',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Tooltip
          if (_hoveredSegment != null)
            Positioned(
              left: 220,
              top: 70,
              child: IgnorePointer(
                child: Material(
                  color: Colors.transparent,
                  elevation: 8,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF8B4513).withOpacity(0.3), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _hoveredSegment!,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF8B4513),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.pets, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              'จำนวน: $_hoveredCount ตัว',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8B4513).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${((_hoveredCount! / widget.total) * 100).toStringAsFixed(1)}%',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF8B4513),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
    );
  }
}

// Custom Painter for Donut Chart - Dynamic Colors
class _DonutChartPainter extends CustomPainter {
  final Map<String, int> livestockByType;
  final int total;
  final Color Function(int) colorGetter;
  final String? hoveredSegment;

  _DonutChartPainter(
    this.livestockByType,
    this.total,
    this.colorGetter,
    this.hoveredSegment,
  );

  @override
  void paint(Canvas canvas, Size size) {
    if (total == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final innerRadius = radius * 0.6;

    double startAngle = -math.pi / 2; // Start from top
    int colorIndex = 0;

    livestockByType.forEach((type, count) {
      if (count > 0) {
        final sweepAngle = (count / total) * 2 * math.pi;
        final baseColor = colorGetter(colorIndex);
        
        // Highlight if hovered
        final isHovered = type == hoveredSegment;
        final color = isHovered 
            ? Color.lerp(baseColor, Colors.white, 0.2)! 
            : baseColor;
        
        // Draw outer arc - ไม่เปลี่ยน strokeWidth
        final paint = Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = radius - innerRadius;

        final rect = Rect.fromCircle(
          center: center, 
          radius: (radius + innerRadius) / 2
        );
        canvas.drawArc(rect, startAngle, sweepAngle, false, paint);

        startAngle += sweepAngle;
        colorIndex++;
      }
    });

    // Draw white circle in center for donut effect
    final centerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, innerRadius, centerPaint);
  }

  @override
  bool shouldRepaint(_DonutChartPainter oldDelegate) {
    return oldDelegate.livestockByType != livestockByType || 
           oldDelegate.total != total ||
           oldDelegate.hoveredSegment != hoveredSegment;
  }
}
