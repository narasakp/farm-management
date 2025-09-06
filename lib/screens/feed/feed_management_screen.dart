import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/feed_provider.dart';
import '../../models/feed_management.dart';
import 'package:intl/intl.dart';

class FeedManagementScreen extends StatefulWidget {
  const FeedManagementScreen({super.key});

  @override
  State<FeedManagementScreen> createState() => _FeedManagementScreenState();
}

class _FeedManagementScreenState extends State<FeedManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  FeedType? _selectedType;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('จัดการอาหารสัตว์'),
        backgroundColor: const Color(0xFF8B4513),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'ภาพรวม'),
            Tab(icon: Icon(Icons.inventory), text: 'คลังอาหาร'),
            Tab(icon: Icon(Icons.restaurant), text: 'การให้อาหาร'),
            Tab(icon: Icon(Icons.schedule), text: 'ตารางเวลา'),
          ],
        ),
      ),
      body: Consumer<FeedProvider>(
        builder: (context, feedProvider, child) {
          if (feedProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (feedProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: const Color(0xFFCD5C5C).withOpacity(0.6)),
                  const SizedBox(height: 16),
                  Text(feedProvider.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: feedProvider.clearError,
                    child: const Text('ลองใหม่'),
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(feedProvider),
              _buildInventoryTab(feedProvider),
              _buildFeedingTab(feedProvider),
              _buildScheduleTab(feedProvider),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddFeedItemDialog(context),
        backgroundColor: const Color(0xFF8B4513),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildOverviewTab(FeedProvider provider) {
    final summary = provider.getFeedSummary();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Cards
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.5,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildSummaryCard(
                'รายการอาหาร',
                summary.totalFeedItems.toString(),
                Icons.inventory,
                const Color(0xFF228B22),
              ),
              _buildSummaryCard(
                'สต็อกต่ำ',
                summary.lowStockItems.toString(),
                Icons.warning,
                const Color(0xFFDAA520),
              ),
              _buildSummaryCard(
                'ใกล้หมดอายุ',
                summary.expiringSoonItems.toString(),
                Icons.schedule,
                const Color(0xFF8B4513),
              ),
              _buildSummaryCard(
                'มูลค่าคลัง',
                '${NumberFormat('#,##0').format(summary.totalInventoryValue)}',
                Icons.attach_money,
                const Color(0xFF8B4513),
                subtitle: 'บาท',
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Critical Items Alert
          if (summary.criticalItems.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFCD5C5C).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFCD5C5C).withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning, color: const Color(0xFFCD5C5C)),
                      const SizedBox(width: 8),
                      Text(
                        'รายการที่ต้องดูแล (${summary.criticalItems.length})',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFCD5C5C),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...summary.criticalItems.take(3).map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Icon(
                          item.isLowStock ? Icons.inventory_2 : Icons.schedule,
                          size: 16,
                          color: const Color(0xFFCD5C5C),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${item.name} - ${item.isLowStock ? 'สต็อกต่ำ' : 'ใกล้หมดอายุ'}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  )),
                  if (summary.criticalItems.length > 3)
                    Text(
                      'และอีก ${summary.criticalItems.length - 3} รายการ',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
          
          // Feed by Type
          const Text(
            'อาหารแยกตามประเภท',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...summary.itemsByType.entries
              .where((entry) => entry.value > 0)
              .map((entry) => _buildFeedTypeCard(
                  entry.key, 
                  entry.value, 
                  summary.valueByType[entry.key] ?? 0
              )),
          
          const SizedBox(height: 24),
          
          // Recent Feedings
          const Text(
            'การให้อาหารล่าสุด',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...summary.recentFeedings.take(5).map((record) => _buildFeedingCard(record)),
          
          const SizedBox(height: 24),
          
          // Upcoming Feedings
          if (summary.upcomingFeedings.isNotEmpty) ...[
            const Text(
              'ตารางให้อาหารวันนี้',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...summary.upcomingFeedings.map((schedule) => _buildUpcomingFeedingCard(schedule)),
          ],
        ],
      ),
    );
  }

  Widget _buildInventoryTab(FeedProvider provider) {
    final filteredItems = _searchQuery.isEmpty
        ? provider.feedItems
        : provider.searchFeedItems(_searchQuery);
    
    return Column(
      children: [
        // Search and Filter
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'ค้นหาอาหารสัตว์...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.withOpacity(0.1),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    FilterChip(
                      label: const Text('ทั้งหมด'),
                      selected: _selectedType == null,
                      onSelected: (selected) {
                        setState(() {
                          _selectedType = null;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    ...FeedType.values.map((type) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(type.displayName),
                        selected: _selectedType == type,
                        onSelected: (selected) {
                          setState(() {
                            _selectedType = selected ? type : null;
                          });
                        },
                      ),
                    )),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Inventory List
        Expanded(
          child: filteredItems.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('ไม่มีรายการอาหาร'),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
                    if (_selectedType != null && item.type != _selectedType) {
                      return const SizedBox.shrink();
                    }
                    return _buildFeedItemCard(item);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFeedingTab(FeedProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.feedingRecords.length,
      itemBuilder: (context, index) {
        final record = provider.feedingRecords[index];
        return _buildFeedingCard(record);
      },
    );
  }

  Widget _buildScheduleTab(FeedProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.feedSchedules.length,
      itemBuilder: (context, index) {
        final schedule = provider.feedSchedules[index];
        return _buildScheduleCard(schedule);
      },
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color, {String? subtitle}) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null)
              Text(
                subtitle,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedTypeCard(FeedType type, int count, double value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: type.color,
          child: Icon(type.icon, color: Colors.white),
        ),
        title: Text(type.displayName),
        subtitle: Text('$count รายการ'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${NumberFormat('#,##0').format(value)} บาท',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              '${(value / count).toStringAsFixed(0)} บาท/รายการ',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedItemCard(FeedItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: item.type.color,
                  child: Icon(item.type.icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      if (item.brand != null)
                        Text('ยี่ห้อ: ${item.brand}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      Text('${item.currentStock} ${item.unit.shortName}'),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${NumberFormat('#,##0.00').format(item.stockValue)} บาท',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: const Color(0xFF8B4513)),
                    ),
                    Text(
                      '${item.costPerUnit.toStringAsFixed(2)} บาท/${item.unit.shortName}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Stock Level Indicator
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: item.stockPercentage / 100,
                    backgroundColor: Colors.grey.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      item.isLowStock ? const Color(0xFFCD5C5C) : 
                      item.isOverStock ? const Color(0xFFDAA520) : const Color(0xFF8B4513),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${item.stockPercentage.toStringAsFixed(0)}%',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Status Indicators
            Wrap(
              spacing: 8,
              children: [
                if (item.isLowStock)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFCD5C5C).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'สต็อกต่ำ',
                      style: TextStyle(fontSize: 10, color: const Color(0xFFCD5C5C), fontWeight: FontWeight.bold),
                    ),
                  ),
                if (item.isExpiringSoon)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDAA520).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'ใกล้หมดอายุ',
                      style: TextStyle(fontSize: 10, color: const Color(0xFFDAA520), fontWeight: FontWeight.bold),
                    ),
                  ),
                if (item.isExpired)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFCD5C5C).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'หมดอายุ',
                      style: TextStyle(fontSize: 10, color: const Color(0xFFCD5C5C), fontWeight: FontWeight.bold),
                    ),
                  ),
                if (item.expiryDate != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF228B22).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'หมดอายุ ${DateFormat('dd/MM/yyyy').format(item.expiryDate!)}',
                      style: const TextStyle(fontSize: 10, color: const Color(0xFF228B22)),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedingCard(FeedingRecord record) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: const Color(0xFF8B4513),
          child: Icon(Icons.restaurant, color: Colors.white, size: 20),
        ),
        title: Text('${record.livestockName} - ${record.feedItemName}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${record.quantity} ${record.unit.shortName} - ${DateFormat('dd/MM/yyyy HH:mm').format(record.feedingTime)}'),
            if (record.fedBy != null)
              Text('โดย: ${record.fedBy}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        trailing: record.cost != null
            ? Text(
                '${NumberFormat('#,##0.00').format(record.cost)} บาท',
                style: const TextStyle(fontWeight: FontWeight.bold, color: const Color(0xFF8B4513)),
              )
            : null,
        onTap: () => _showFeedingDetails(record),
      ),
    );
  }

  Widget _buildScheduleCard(FeedSchedule schedule) {
    final feedingTimesText = schedule.feedingTimes.map((hour) => '${hour.toString().padLeft(2, '0')}:00').join(', ');
    final daysText = schedule.daysOfWeek.length == 7 ? 'ทุกวัน' : 
        schedule.daysOfWeek.map((day) => ['จ', 'อ', 'พ', 'พฤ', 'ศ', 'ส', 'อา'][day - 1]).join(', ');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: schedule.isActive ? const Color(0xFF8B4513) : Colors.grey,
                  child: Icon(
                    schedule.isActive ? Icons.schedule : Icons.schedule_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${schedule.livestockName} - ${schedule.feedItemName}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('${schedule.quantity} ${schedule.unit.shortName}'),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: schedule.isActive ? const Color(0xFF8B4513) : Colors.grey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    schedule.isActive ? 'ใช้งาน' : 'ไม่ใช้งาน',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text('เวลา: $feedingTimesText', style: const TextStyle(fontSize: 12)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text('วัน: $daysText', style: const TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingFeedingCard(FeedSchedule schedule) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: const Color(0xFF228B22).withOpacity(0.1),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: const Color(0xFF228B22),
          child: Icon(Icons.notifications, color: Colors.white),
        ),
        title: Text('${schedule.livestockName} - ${schedule.feedItemName}'),
        subtitle: Text('${schedule.quantity} ${schedule.unit.shortName}'),
        trailing: const Text(
          'ถึงเวลาให้อาหาร',
          style: TextStyle(fontWeight: FontWeight.bold, color: const Color(0xFF228B22)),
        ),
      ),
    );
  }

  void _showFeedingDetails(FeedingRecord record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('รายละเอียดการให้อาหาร'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDetailRow('สัตว์', record.livestockName),
            _buildDetailRow('อาหาร', record.feedItemName),
            _buildDetailRow('ปริมาณ', '${record.quantity} ${record.unit.shortName}'),
            _buildDetailRow('เวลา', DateFormat('dd/MM/yyyy HH:mm').format(record.feedingTime)),
            if (record.fedBy != null)
              _buildDetailRow('ผู้ให้อาหาร', record.fedBy!),
            if (record.cost != null)
              _buildDetailRow('ค่าใช้จ่าย', '${NumberFormat('#,##0.00').format(record.cost)} บาท'),
            if (record.notes != null)
              _buildDetailRow('หมายเหตุ', record.notes!),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ปิด'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showAddFeedItemDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('เพิ่มรายการอาหาร'),
        content: const Text('ฟีเจอร์นี้จะพัฒนาในเวอร์ชันถัดไป'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ปิด'),
          ),
        ],
      ),
    );
  }
}
