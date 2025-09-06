import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/breeding_provider.dart';
import '../../models/breeding_management.dart';
import 'package:intl/intl.dart';

class BreedingManagementScreen extends StatefulWidget {
  const BreedingManagementScreen({super.key});

  @override
  State<BreedingManagementScreen> createState() => _BreedingManagementScreenState();
}

class _BreedingManagementScreenState extends State<BreedingManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

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
        title: const Text('จัดการการผสมพันธุ์'),
        backgroundColor: const Color(0xFF8B4513).shade700,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'ภาพรวม'),
            Tab(icon: Icon(Icons.pregnant_woman), text: 'ตั้งท้อง'),
            Tab(icon: Icon(Icons.baby_changing_station), text: 'คลอด'),
            Tab(icon: Icon(Icons.history), text: 'ประวัติ'),
          ],
        ),
      ),
      body: Consumer<BreedingProvider>(
        builder: (context, breedingProvider, child) {
          if (breedingProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (breedingProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: const Color(0xFFCD5C5C).shade300),
                  const SizedBox(height: 16),
                  Text(breedingProvider.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: breedingProvider.clearError,
                    child: const Text('ลองใหม่'),
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(breedingProvider),
              _buildPregnancyTab(breedingProvider),
              _buildDeliveryTab(breedingProvider),
              _buildHistoryTab(breedingProvider),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBreedingDialog(context),
        backgroundColor: const Color(0xFF8B4513).shade700,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildOverviewTab(BreedingProvider provider) {
    final summary = provider.getBreedingSummary();
    
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
                'การผสมทั้งหมด',
                summary.totalBreedings.toString(),
                Icons.pets,
                const Color(0xFF228B22),
              ),
              _buildSummaryCard(
                'ตั้งท้อง',
                summary.activePregnancies.toString(),
                Icons.pregnant_woman,
                const Color(0xFF8B4513),
              ),
              _buildSummaryCard(
                'คลอดสำเร็จ',
                summary.successfulDeliveries.toString(),
                Icons.baby_changing_station,
                const Color(0xFF8B4513),
              ),
              _buildSummaryCard(
                'เกินกำหนด',
                summary.overdueDeliveries.toString(),
                Icons.warning,
                const Color(0xFFCD5C5C),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Upcoming Deliveries
          if (summary.upcomingDeliveries.isNotEmpty) ...[
            const Text(
              'คาดว่าจะคลอดเร็วๆ นี้',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...summary.upcomingDeliveries.map((record) => _buildUpcomingDeliveryCard(record)),
            const SizedBox(height: 24),
          ],
          
          // Overdue Deliveries
          if (summary.overdueDeliveries > 0) ...[
            const Text(
              'เกินกำหนดคลอด',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFFCD5C5C)),
            ),
            const SizedBox(height: 12),
            ...provider.getOverdueDeliveries().map((record) => _buildOverdueDeliveryCard(record)),
            const SizedBox(height: 24),
          ],
          
          // Recent Breeding Records
          const Text(
            'บันทึกการผสมล่าสุด',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...summary.recentBreedings.take(5).map((record) => _buildBreedingCard(record)),
        ],
      ),
    );
  }

  Widget _buildPregnancyTab(BreedingProvider provider) {
    final pregnantAnimals = provider.getPregnantAnimals();
    
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'ค้นหาสัตว์ตั้งท้อง...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: const Color(0xFFDAA520).shade100,
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),
        
        // Pregnant Animals List
        Expanded(
          child: pregnantAnimals.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.pregnant_woman, size: 64, color: const Color(0xFFDAA520)),
                      SizedBox(height: 16),
                      Text('ไม่มีสัตว์ที่ตั้งท้อง'),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: pregnantAnimals.length,
                  itemBuilder: (context, index) {
                    final record = pregnantAnimals[index];
                    return _buildPregnancyCard(record);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildDeliveryTab(BreedingProvider provider) {
    final deliveredRecords = provider.getBreedingsByStatus(BreedingStatus.delivered);
    
    return deliveredRecords.isEmpty
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.baby_changing_station, size: 64, color: const Color(0xFFDAA520)),
                SizedBox(height: 16),
                Text('ยังไม่มีการคลอด'),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: deliveredRecords.length,
            itemBuilder: (context, index) {
              final record = deliveredRecords[index];
              return _buildDeliveryCard(record, provider);
            },
          );
  }

  Widget _buildHistoryTab(BreedingProvider provider) {
    final filteredRecords = _searchQuery.isEmpty
        ? provider.breedingRecords
        : provider.searchBreedingRecords(_searchQuery);
    
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'ค้นหาประวัติการผสม...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: const Color(0xFFDAA520).shade100,
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),
        
        // History List
        Expanded(
          child: filteredRecords.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 64, color: const Color(0xFFDAA520)),
                      SizedBox(height: 16),
                      Text('ไม่มีประวัติการผสม'),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredRecords.length,
                  itemBuilder: (context, index) {
                    final record = filteredRecords[index];
                    return _buildBreedingCard(record);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
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
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreedingCard(BreedingRecord record) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: record.status.color,
          child: Icon(
            _getStatusIcon(record.status),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text('${record.motherName} × ${record.fatherName}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('วันที่ผสม: ${DateFormat('dd/MM/yyyy').format(record.matingDate)}'),
            Text('สถานะ: ${record.status.displayName}'),
            if (record.expectedDeliveryDate != null)
              Text('คาดว่าจะคลอด: ${DateFormat('dd/MM/yyyy').format(record.expectedDeliveryDate!)}'),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.visibility),
                  SizedBox(width: 8),
                  Text('ดูรายละเอียด'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('แก้ไข'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: const Color(0xFFCD5C5C)),
                  SizedBox(width: 8),
                  Text('ลบ', style: TextStyle(color: const Color(0xFFCD5C5C))),
                ],
              ),
            ),
          ],
          onSelected: (value) => _handleBreedingAction(value.toString(), record),
        ),
        onTap: () => _showBreedingDetails(record),
      ),
    );
  }

  Widget _buildPregnancyCard(BreedingRecord record) {
    final stage = record.currentPregnancyStage;
    final daysPregnant = record.daysPregnant;
    final daysUntilDelivery = record.daysUntilDelivery;
    
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
                  backgroundColor: stage.color,
                  child: const Icon(Icons.pregnant_woman, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.motherName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text('ตั้งท้องมาแล้ว $daysPregnant วัน'),
                      Text(stage.displayName),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      record.isOverdue ? 'เกินกำหนด' : 'อีก $daysUntilDelivery วัน',
                      style: TextStyle(
                        color: record.isOverdue ? const Color(0xFFCD5C5C) : const Color(0xFF8B4513),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (record.expectedDeliveryDate != null)
                      Text(
                        DateFormat('dd/MM/yyyy').format(record.expectedDeliveryDate!),
                        style: const TextStyle(fontSize: 12, color: const Color(0xFFDAA520)),
                      ),
                  ],
                ),
              ],
            ),
            if (record.notes != null) ...[
              const SizedBox(height: 8),
              Text(
                record.notes!,
                style: const TextStyle(fontSize: 12, color: const Color(0xFFDAA520)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingDeliveryCard(BreedingRecord record) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: const Color(0xFF228B22).shade50,
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: const Color(0xFF228B22),
          child: Icon(Icons.schedule, color: Colors.white),
        ),
        title: Text(record.motherName),
        subtitle: Text('คาดว่าจะคลอด: ${DateFormat('dd/MM/yyyy').format(record.expectedDeliveryDate!)}'),
        trailing: Text(
          'อีก ${record.daysUntilDelivery} วัน',
          style: const TextStyle(fontWeight: FontWeight.bold, color: const Color(0xFF228B22)),
        ),
      ),
    );
  }

  Widget _buildOverdueDeliveryCard(BreedingRecord record) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: const Color(0xFFCD5C5C).shade50,
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: const Color(0xFFCD5C5C),
          child: Icon(Icons.warning, color: Colors.white),
        ),
        title: Text(record.motherName),
        subtitle: Text('กำหนดคลอด: ${DateFormat('dd/MM/yyyy').format(record.expectedDeliveryDate!)}'),
        trailing: Text(
          'เกิน ${record.daysUntilDelivery.abs()} วัน',
          style: const TextStyle(fontWeight: FontWeight.bold, color: const Color(0xFFCD5C5C)),
        ),
      ),
    );
  }

  Widget _buildDeliveryCard(BreedingRecord record, BreedingProvider provider) {
    final offspring = provider.getOffspringByBreeding(record.id);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: const Color(0xFF8B4513),
                  child: Icon(Icons.baby_changing_station, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.motherName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      if (record.actualDeliveryDate != null)
                        Text('คลอดเมื่อ: ${DateFormat('dd/MM/yyyy').format(record.actualDeliveryDate!)}'),
                      Text('จำนวนลูก: ${record.numberOfOffspring ?? 0} ตัว'),
                    ],
                  ),
                ),
              ],
            ),
            if (offspring.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text('ลูกสัตว์:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              ...offspring.map((child) => Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 4),
                child: Row(
                  children: [
                    Icon(
                      child.gender == 'ผู้' ? Icons.male : Icons.female,
                      size: 16,
                      color: child.gender == 'ผู้' ? const Color(0xFF228B22) : Colors.pink,
                    ),
                    const SizedBox(width: 4),
                    Text('${child.name} (${child.gender})'),
                    if (child.birthWeight != null) ...[
                      const SizedBox(width: 8),
                      Text('${child.birthWeight} กก.', style: const TextStyle(fontSize: 12, color: const Color(0xFFDAA520))),
                    ],
                  ],
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(BreedingStatus status) {
    switch (status) {
      case BreedingStatus.planned:
        return Icons.schedule;
      case BreedingStatus.mated:
        return Icons.favorite;
      case BreedingStatus.pregnant:
        return Icons.pregnant_woman;
      case BreedingStatus.delivered:
        return Icons.baby_changing_station;
      case BreedingStatus.failed:
        return Icons.close;
      case BreedingStatus.aborted:
        return Icons.warning;
    }
  }

  void _handleBreedingAction(String action, BreedingRecord record) {
    switch (action) {
      case 'view':
        _showBreedingDetails(record);
        break;
      case 'edit':
        _showEditBreedingDialog(record);
        break;
      case 'delete':
        _showDeleteConfirmation(record);
        break;
    }
  }

  void _showBreedingDetails(BreedingRecord record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('รายละเอียดการผสม'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('แม่พันธุ์', record.motherName),
              _buildDetailRow('พ่อพันธุ์', record.fatherName),
              _buildDetailRow('วันที่ผสม', DateFormat('dd/MM/yyyy').format(record.matingDate)),
              _buildDetailRow('สถานะ', record.status.displayName),
              if (record.expectedDeliveryDate != null)
                _buildDetailRow('คาดว่าจะคลอด', DateFormat('dd/MM/yyyy').format(record.expectedDeliveryDate!)),
              if (record.actualDeliveryDate != null)
                _buildDetailRow('วันที่คลอด', DateFormat('dd/MM/yyyy').format(record.actualDeliveryDate!)),
              if (record.numberOfOffspring != null)
                _buildDetailRow('จำนวนลูก', '${record.numberOfOffspring} ตัว'),
              if (record.veterinarian != null)
                _buildDetailRow('สัตวแพทย์', record.veterinarian!),
              if (record.cost != null)
                _buildDetailRow('ค่าใช้จ่าย', '${record.cost!.toStringAsFixed(0)} บาท'),
              if (record.notes != null)
                _buildDetailRow('หมายเหตุ', record.notes!),
            ],
          ),
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
            width: 100,
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

  void _showAddBreedingDialog(BuildContext context) {
    // Implementation for adding new breeding record
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('เพิ่มการผสมใหม่'),
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

  void _showEditBreedingDialog(BreedingRecord record) {
    // Implementation for editing breeding record
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('แก้ไขการผสม'),
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

  void _showDeleteConfirmation(BreedingRecord record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: Text('คุณต้องการลบบันทึกการผสมของ ${record.motherName} หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<BreedingProvider>().deleteBreedingRecord(record.id);
            },
            child: const Text('ลบ', style: TextStyle(color: const Color(0xFFCD5C5C))),
          ),
        ],
      ),
    );
  }
}
