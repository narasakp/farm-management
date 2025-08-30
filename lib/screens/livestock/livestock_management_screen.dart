import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/livestock_provider.dart';
import '../../models/livestock.dart';
import '../../utils/responsive_helper.dart';

class LivestockManagementScreen extends StatefulWidget {
  const LivestockManagementScreen({super.key});

  @override
  State<LivestockManagementScreen> createState() => _LivestockManagementScreenState();
}

class _LivestockManagementScreenState extends State<LivestockManagementScreen> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _selectedType = 'ทั้งหมด';
  String _selectedStatus = 'ทั้งหมด';
  late TabController _tabController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LivestockProvider>(context, listen: false).loadLivestock('farm1');
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('จัดการปศุสัตว์'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
          isScrollable: true,
          tabs: const [
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

  // ทะเบียนสัตว์ - Tab แรก
  Widget _buildLivestockRegistry() {
    return Consumer<LivestockProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Debug: แสดงจำนวนข้อมูลที่โหลดได้
        print('Livestock count: ${provider.livestock.length}');
        
        final filteredLivestock = _getFilteredLivestock(provider.livestock);
        print('Filtered livestock count: ${filteredLivestock.length}');

        if (provider.livestock.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.pets, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('ไม่พบข้อมูลปศุสัตว์', style: TextStyle(fontSize: 18, color: Colors.grey)),
                SizedBox(height: 8),
                Text('กดปุ่ม + เพื่อเพิ่มข้อมูลสัตว์', style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        return Column(
          children: [
            _buildSearchAndFilter(),
            _buildSummaryCards(provider),
            Expanded(
              child: _buildLivestockList(filteredLivestock),
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

  // ผลผลิต - Tab ที่ห้า
  Widget _buildProductionRecords() {
    return Column(
      children: [
        _buildProductionSummary(),
        Expanded(
          child: _buildProductionList(),
        ),
      ],
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
            child: _buildSummaryCard(
              'ปศุสัตว์ทั้งหมด',
              provider.livestock.length.toString(),
              Icons.pets,
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

  List<Livestock> _getFilteredLivestock(List<Livestock> livestock) {
    var filtered = livestock;

    // Filter by search query
    if (_searchController.text.isNotEmpty) {
      filtered = filtered.where((animal) =>
          animal.tagNumber.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          (animal.breed?.toLowerCase().contains(_searchController.text.toLowerCase()) ?? false)).toList();
    }

    // Filter by type
    if (_selectedType != 'ทั้งหมด') {
      filtered = filtered.where((animal) => _getAnimalTypeName(animal.type.name) == _selectedType).toList();
    }

    // Filter by status
    if (_selectedStatus != 'ทั้งหมด') {
      String statusToMatch = _selectedStatus;
      switch (_selectedStatus) {
        case 'แข็งแรง':
          statusToMatch = 'healthy';
          break;
        case 'ป่วย':
          statusToMatch = 'sick';
          break;
        case 'รักษา':
          statusToMatch = 'sick';
          break;
        case 'กักกัน':
          statusToMatch = 'sick';
          break;
      }
      filtered = filtered.where((animal) => animal.healthStatus == statusToMatch).toList();
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
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      items: const [
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
    final tabs = ['ทะเบียนสัตว์', 'บันทึกสุขภาพ', 'บันทึกการผสม', 'บันทึกอาหาร', 'บันทึกผลผลิต'];
    
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
}
