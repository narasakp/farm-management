import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/trading_provider.dart';
import '../../models/trading_record.dart';

class TradingListScreen extends StatefulWidget {
  const TradingListScreen({super.key});

  @override
  State<TradingListScreen> createState() => _TradingListScreenState();
}

class _TradingListScreenState extends State<TradingListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedType = 'ทั้งหมด';
  String _selectedStatus = 'ทั้งหมด';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TradingProvider>(context, listen: false).loadTradingRecords();
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
        title: const Text('รายการซื้อขาย'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
      body: Consumer<TradingProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final filteredRecords = _getFilteredRecords(provider.tradingRecords);

          return Column(
            children: [
              _buildSearchAndFilter(),
              _buildSummaryCards(provider),
              Expanded(
                child: _buildTradingList(filteredRecords),
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
              hintText: 'ค้นหารายการซื้อขาย...',
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
                  items: ['ทั้งหมด', 'buy', 'sell']
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type == 'ทั้งหมด' ? type : 
                              type == 'buy' ? 'ซื้อ' : 'ขาย'),
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
                  items: ['ทั้งหมด', 'completed', 'pending', 'cancelled']
                      .map((status) => DropdownMenuItem(
                            value: status,
                            child: Text(status == 'ทั้งหมด' ? status : 
                              status == 'completed' ? 'สำเร็จ' :
                              status == 'pending' ? 'รอดำเนินการ' : 'ยกเลิก'),
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

  Widget _buildSummaryCards(TradingProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              'ยอดขาย',
              '฿${NumberFormat('#,##0').format(provider.getTotalSales())}',
              Icons.trending_up,
              Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'ยอดซื้อ',
              '฿${NumberFormat('#,##0').format(provider.getTotalPurchases())}',
              Icons.trending_down,
              Colors.red,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'รายการทั้งหมด',
              provider.getTotalTransactions().toString(),
              Icons.receipt,
              Colors.blue,
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

  Widget _buildTradingList(List<TradingRecord> records) {
    if (records.isEmpty) {
      return const Center(
        child: Text('ไม่พบข้อมูลรายการซื้อขาย'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        return _buildTradingCard(record);
      },
    );
  }

  Widget _buildTradingCard(TradingRecord record) {
    final isIncome = record.type == 'sell';
    final color = isIncome ? Colors.green : Colors.red;
    
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
                Icon(
                  isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                  color: color,
                  size: 20,
                ),
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
              '${isIncome ? 'ขายให้' : 'ซื้อจาก'}: ${record.buyerSeller}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'วันที่: ${DateFormat('dd/MM/yyyy').format(record.date)}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildInfoChip('หมวดหมู่: ${record.category}', Colors.blue),
                const SizedBox(width: 8),
                _buildInfoChip('จำนวน: ${record.quantity}', Colors.orange),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildInfoChip('ราคา/หน่วย: ฿${NumberFormat('#,##0.00').format(record.pricePerUnit)}', Colors.purple),
                const Spacer(),
                Text(
                  'รวม: ฿${NumberFormat('#,##0.00').format(record.totalAmount)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
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
      case 'completed':
        color = Colors.green;
        text = 'สำเร็จ';
        break;
      case 'pending':
        color = Colors.orange;
        text = 'รอดำเนินการ';
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

  List<TradingRecord> _getFilteredRecords(List<TradingRecord> records) {
    var filtered = records;

    // Filter by search query
    if (_searchController.text.isNotEmpty) {
      filtered = filtered.where((record) =>
          record.itemName.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          record.buyerSeller.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          record.category.toLowerCase().contains(_searchController.text.toLowerCase())).toList();
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
