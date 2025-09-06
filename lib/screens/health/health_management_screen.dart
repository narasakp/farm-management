import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../models/health_management.dart';
import '../../providers/health_provider.dart';
import '../../utils/app_theme.dart';

class HealthManagementScreen extends StatefulWidget {
  const HealthManagementScreen({super.key});

  @override
  State<HealthManagementScreen> createState() => _HealthManagementScreenState();
}

class _HealthManagementScreenState extends State<HealthManagementScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('จัดการสุขภาพปศุสัตว์'),
        backgroundColor: Color(0xFF228B22),
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Color(0xFF8B4513).withOpacity(0.1),
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
            Tab(icon: Icon(Icons.dashboard), text: 'ภาพรวม'),
            Tab(icon: Icon(Icons.vaccines), text: 'วัคซีน'),
            Tab(icon: Icon(Icons.medical_services), text: 'การรักษา'),
            Tab(icon: Icon(Icons.history), text: 'ประวัติ'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildVaccinationTab(),
          _buildTreatmentTab(),
          _buildHistoryTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddHealthRecordDialog(),
        backgroundColor: Color(0xFF228B22),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return Consumer<HealthProvider>(
      builder: (context, healthProvider, child) {
        final summary = healthProvider.getHealthSummary();
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryCards(summary),
              const SizedBox(height: 24),
              _buildUpcomingVaccinations(healthProvider),
              const SizedBox(height: 24),
              _buildRecentRecords(summary.recentRecords),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCards(HealthSummary summary) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildSummaryCard(
          'บันทึกทั้งหมด',
          '${summary.totalRecords}',
          Icons.medical_information,
          Color(0xFF228B22),
        ),
        _buildSummaryCard(
          'การฉีดวัคซีน',
          '${summary.vaccinationCount}',
          Icons.vaccines,
          Color(0xFF228B22),
        ),
        _buildSummaryCard(
          'การรักษา',
          '${summary.treatmentCount}',
          Icons.medical_services,
          Color(0xFFDAA520),
        ),
        _buildSummaryCard(
          'ค่าใช้จ่าย',
          '฿${summary.totalCost.toStringAsFixed(0)}',
          Icons.attach_money,
          Color(0xFFCD5C5C),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingVaccinations(HealthProvider healthProvider) {
    final upcoming = healthProvider.getUpcomingVaccinations();
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.schedule, color: Color(0xFFDAA520)),
                const SizedBox(width: 8),
                const Text(
                  'วัคซีนที่ใกล้ครบกำหนด',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (upcoming.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('ไม่มีวัคซีนที่ใกล้ครบกำหนด'),
                ),
              )
            else
              ...upcoming.take(3).map((record) => _buildUpcomingVaccinationItem(record)),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingVaccinationItem(HealthRecord record) {
    final daysLeft = record.nextDueDate!.difference(DateTime.now()).inDays;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xFFDAA520).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.vaccines, color: Color(0xFFDAA520), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.livestockName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  record.title,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: daysLeft <= 7 ? Color(0xFFCD5C5C) : Color(0xFFDAA520),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$daysLeft วัน',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentRecords(List<HealthRecord> records) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history, color: Color(0xFF8B4513)),
                const SizedBox(width: 8),
                const Text(
                  'บันทึกล่าสุด',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (records.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('ยังไม่มีบันทึกสุขภาพ'),
                ),
              )
            else
              ...records.map((record) => _buildHealthRecordItem(record)),
          ],
        ),
      ),
    );
  }

  Widget _buildVaccinationTab() {
    return Consumer<HealthProvider>(
      builder: (context, healthProvider, child) {
        final vaccinations = healthProvider.getHealthRecordsByType(HealthRecordType.vaccination);
        
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'ค้นหาการฉีดวัคซีน...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: vaccinations.length,
                itemBuilder: (context, index) {
                  final record = vaccinations[index];
                  if (_searchQuery.isNotEmpty && 
                      !record.title.toLowerCase().contains(_searchQuery.toLowerCase()) &&
                      !record.livestockName.toLowerCase().contains(_searchQuery.toLowerCase())) {
                    return const SizedBox.shrink();
                  }
                  return _buildHealthRecordItem(record);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTreatmentTab() {
    return Consumer<HealthProvider>(
      builder: (context, healthProvider, child) {
        final treatments = healthProvider.getHealthRecordsByType(HealthRecordType.treatment);
        
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'ค้นหาการรักษา...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: treatments.length,
                itemBuilder: (context, index) {
                  final record = treatments[index];
                  if (_searchQuery.isNotEmpty && 
                      !record.title.toLowerCase().contains(_searchQuery.toLowerCase()) &&
                      !record.livestockName.toLowerCase().contains(_searchQuery.toLowerCase())) {
                    return const SizedBox.shrink();
                  }
                  return _buildHealthRecordItem(record);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHistoryTab() {
    return Consumer<HealthProvider>(
      builder: (context, healthProvider, child) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'ค้นหาประวัติสุขภาพ...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: healthProvider.healthRecords.length,
                itemBuilder: (context, index) {
                  final record = healthProvider.healthRecords[index];
                  if (_searchQuery.isNotEmpty && 
                      !record.title.toLowerCase().contains(_searchQuery.toLowerCase()) &&
                      !record.livestockName.toLowerCase().contains(_searchQuery.toLowerCase())) {
                    return const SizedBox.shrink();
                  }
                  return _buildHealthRecordItem(record);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHealthRecordItem(HealthRecord record) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: record.type.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(record.type.icon, color: record.type.color),
        ),
        title: Text(
          record.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(record.livestockName),
            Text(
              '${record.date.day}/${record.date.month}/${record.date.year}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            if (record.cost != null)
              Text(
                'ค่าใช้จ่าย: ฿${record.cost!.toStringAsFixed(0)}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: record.status.color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            record.status.displayName,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
        onTap: () => _showHealthRecordDetails(record),
      ),
    );
  }

  void _showAddHealthRecordDialog() {
    // Implementation for adding new health record
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('เพิ่มบันทึกสุขภาพ'),
        content: const Text('ฟีเจอร์นี้จะพัฒนาในขั้นตอนถัดไป'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ปิด'),
          ),
        ],
      ),
    );
  }

  void _showHealthRecordDetails(HealthRecord record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(record.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('สัตว์: ${record.livestockName}'),
              Text('ประเภท: ${record.type.displayName}'),
              Text('วันที่: ${record.date.day}/${record.date.month}/${record.date.year}'),
              if (record.veterinarian != null)
                Text('สัตวแพทย์: ${record.veterinarian}'),
              if (record.cost != null)
                Text('ค่าใช้จ่าย: ฿${record.cost!.toStringAsFixed(0)}'),
              const SizedBox(height: 8),
              Text('รายละเอียด: ${record.description}'),
              if (record.notes != null)
                Text('หมายเหตุ: ${record.notes}'),
            ],
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
}
