import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/farm_record_provider.dart';
import '../../models/farm_record.dart';
import '../../utils/responsive_helper.dart';

class FarmListScreen extends StatefulWidget {
  const FarmListScreen({super.key});

  @override
  State<FarmListScreen> createState() => _FarmListScreenState();
}

class _FarmListScreenState extends State<FarmListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = 'ทั้งหมด';
  String _selectedFarmType = 'ทั้งหมด';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FarmRecordProvider>(context, listen: false).loadFarmRecords();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายการฟาร์ม'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
      body: Consumer<FarmRecordProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final filteredRecords = _getFilteredRecords(provider.farmRecords);

          return Column(
            children: [
              _buildSearchAndFilter(),
              _buildSummaryCards(provider),
              Expanded(
                child: _buildFarmList(filteredRecords),
              ),
            ],
          );
        },
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
              hintText: 'ค้นหาฟาร์ม...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (value) => setState(() {}),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: InputDecoration(
                    labelText: 'สถานะ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: ['ทั้งหมด', 'active', 'inactive', 'maintenance']
                      .map((status) => DropdownMenuItem(
                            value: status,
                            child: Text(status == 'ทั้งหมด' ? status : 
                              status == 'active' ? 'ใช้งาน' :
                              status == 'inactive' ? 'ไม่ใช้งาน' : 'ปรับปรุง'),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedStatus = value!),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedFarmType,
                  decoration: InputDecoration(
                    labelText: 'ประเภทฟาร์ม',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: ['ทั้งหมด', 'โคนม', 'โคเนื้อ', 'สุกร', 'ไก่ไข่', 'ไก่เนื้อ', 'แพะ', 'เป็ด', 'ปลาน้ำจืด', 'กบ', 'กระบือ', 'แกะ', 'ฟาร์มผสม']
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedFarmType = value!),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(FarmRecordProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              'ฟาร์มทั้งหมด',
              provider.getTotalFarms().toString(),
              Icons.home,
              Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'ฟาร์มที่ใช้งาน',
              provider.getActiveFarms().toString(),
              Icons.check_circle,
              Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'ปศุสัตว์รวม',
              provider.getTotalLivestock().toString(),
              Icons.pets,
              Colors.orange,
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

  Widget _buildFarmList(List<FarmRecord> records) {
    if (records.isEmpty) {
      return const Center(
        child: Text('ไม่พบข้อมูลฟาร์ม'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        return _buildFarmCard(record);
      },
    );
  }

  Widget _buildFarmCard(FarmRecord record) {
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
                Expanded(
                  child: Text(
                    record.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildStatusChip(record.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'เจ้าของ: ${record.ownerName}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'โทร: ${record.phoneNumber}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    record.location,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildInfoChip('ประเภท: ${record.farmType}', Colors.blue),
                const SizedBox(width: 8),
                _buildInfoChip('พื้นที่: ${record.area} ไร่', Colors.green),
                const SizedBox(width: 8),
                _buildInfoChip('ปศุสัตว์: ${record.livestockCount} ตัว', Colors.orange),
              ],
            ),
            if (record.description != null) ...[
              const SizedBox(height: 8),
              Text(
                record.description!,
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

  Widget _buildStatusChip(String status) {
    Color color;
    String text;
    
    switch (status) {
      case 'active':
        color = Colors.green;
        text = 'ใช้งาน';
        break;
      case 'inactive':
        color = Colors.red;
        text = 'ไม่ใช้งาน';
        break;
      case 'maintenance':
        color = Colors.orange;
        text = 'ปรับปรุง';
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

  List<FarmRecord> _getFilteredRecords(List<FarmRecord> records) {
    var filtered = records;

    // Filter by search query
    if (_searchController.text.isNotEmpty) {
      filtered = filtered.where((record) =>
          record.name.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          record.location.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          record.ownerName.toLowerCase().contains(_searchController.text.toLowerCase())).toList();
    }

    // Filter by status
    if (_selectedStatus != 'ทั้งหมด') {
      filtered = filtered.where((record) => record.status == _selectedStatus).toList();
    }

    // Filter by farm type
    if (_selectedFarmType != 'ทั้งหมด') {
      filtered = filtered.where((record) => record.farmType == _selectedFarmType).toList();
    }

    return filtered;
  }
}
