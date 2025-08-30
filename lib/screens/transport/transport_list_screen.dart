import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/transport_provider.dart';
import '../../models/transport_record.dart';

class TransportListScreen extends StatefulWidget {
  const TransportListScreen({super.key});

  @override
  State<TransportListScreen> createState() => _TransportListScreenState();
}

class _TransportListScreenState extends State<TransportListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedType = 'ทั้งหมด';
  String _selectedStatus = 'ทั้งหมด';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TransportProvider>(context, listen: false).loadTransportRecords();
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
        title: const Text('รายการขนส่ง'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
      body: Consumer<TransportProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final filteredRecords = _getFilteredRecords(provider.transportRecords);

          return Column(
            children: [
              _buildSearchAndFilter(),
              _buildSummaryCards(provider),
              Expanded(
                child: _buildTransportList(filteredRecords),
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
              hintText: 'ค้นหารายการขนส่ง...',
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
                  value: _selectedType,
                  decoration: InputDecoration(
                    labelText: 'ประเภท',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: ['ทั้งหมด', 'delivery', 'pickup', 'transfer']
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type == 'ทั้งหมด' ? type : 
                              type == 'delivery' ? 'ส่งของ' :
                              type == 'pickup' ? 'รับของ' : 'ย้าย'),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedType = value!),
                ),
              ),
              const SizedBox(width: 12),
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
                  items: ['ทั้งหมด', 'scheduled', 'in_transit', 'delivered', 'cancelled']
                      .map((status) => DropdownMenuItem(
                            value: status,
                            child: Text(status == 'ทั้งหมด' ? status : 
                              status == 'scheduled' ? 'กำหนดการ' :
                              status == 'in_transit' ? 'กำลังขนส่ง' :
                              status == 'delivered' ? 'ส่งแล้ว' : 'ยกเลิก'),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedStatus = value!),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(TransportProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              'ค่าขนส่งรวม',
              '฿${NumberFormat('#,##0').format(provider.getTotalTransportCost())}',
              Icons.attach_money,
              Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'ระยะทางรวม',
              '${NumberFormat('#,##0.0').format(provider.getTotalDistance())} กม.',
              Icons.route,
              Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'รายการทั้งหมด',
              provider.getTotalTransports().toString(),
              Icons.local_shipping,
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
              fontSize: 16,
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

  Widget _buildTransportList(List<TransportRecord> records) {
    if (records.isEmpty) {
      return const Center(
        child: Text('ไม่พบข้อมูลรายการขนส่ง'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        return _buildTransportCard(record);
      },
    );
  }

  Widget _buildTransportCard(TransportRecord record) {
    IconData typeIcon;
    Color typeColor;
    
    switch (record.type) {
      case 'delivery':
        typeIcon = Icons.local_shipping;
        typeColor = Colors.blue;
        break;
      case 'pickup':
        typeIcon = Icons.get_app;
        typeColor = Colors.green;
        break;
      case 'transfer':
        typeIcon = Icons.swap_horiz;
        typeColor = Colors.orange;
        break;
      default:
        typeIcon = Icons.local_shipping;
        typeColor = Colors.grey;
    }
    
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
                Icon(typeIcon, color: typeColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    record.itemName,
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
              'คนขับ: ${record.driverName} (${record.vehicleNumber})',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'กำหนดการ: ${DateFormat('dd/MM/yyyy').format(record.scheduledDate)}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            if (record.actualDate != null) ...[
              const SizedBox(height: 4),
              Text(
                'วันที่ส่งจริง: ${DateFormat('dd/MM/yyyy').format(record.actualDate!)}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.green[600],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${record.fromLocation} → ${record.toLocation}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildInfoChip('จำนวน: ${record.quantity}', Colors.blue),
                const SizedBox(width: 8),
                _buildInfoChip('ระยะทาง: ${record.distance} กม.', Colors.green),
                const Spacer(),
                Text(
                  'ค่าขนส่ง: ฿${NumberFormat('#,##0').format(record.cost)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[700],
                  ),
                ),
              ],
            ),
            if (record.notes != null) ...[
              const SizedBox(height: 8),
              Text(
                'หมายเหตุ: ${record.notes}',
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
      case 'scheduled':
        color = Colors.blue;
        text = 'กำหนดการ';
        break;
      case 'in_transit':
        color = Colors.orange;
        text = 'กำลังขนส่ง';
        break;
      case 'delivered':
        color = Colors.green;
        text = 'ส่งแล้ว';
        break;
      case 'cancelled':
        color = Colors.red;
        text = 'ยกเลิก';
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

  List<TransportRecord> _getFilteredRecords(List<TransportRecord> records) {
    var filtered = records;

    // Filter by search query
    if (_searchController.text.isNotEmpty) {
      filtered = filtered.where((record) =>
          record.itemName.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          record.driverName.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          record.fromLocation.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          record.toLocation.toLowerCase().contains(_searchController.text.toLowerCase())).toList();
    }

    // Filter by type
    if (_selectedType != 'ทั้งหมด') {
      filtered = filtered.where((record) => record.type == _selectedType).toList();
    }

    // Filter by status
    if (_selectedStatus != 'ทั้งหมด') {
      filtered = filtered.where((record) => record.status == _selectedStatus).toList();
    }

    return filtered;
  }
}
