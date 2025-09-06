import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/production_provider.dart';
import '../../models/production_management.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class ProductionManagementScreen extends StatefulWidget {
  const ProductionManagementScreen({super.key});

  @override
  State<ProductionManagementScreen> createState() => _ProductionManagementScreenState();
}

class _ProductionManagementScreenState extends State<ProductionManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  ProductionType? _selectedType;

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
        title: const Text('จัดการการผลิต'),
        backgroundColor: const Color(0xFF8B4513).shade700,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'ภาพรวม'),
            Tab(icon: Icon(Icons.trending_up), text: 'แนวโน้ม'),
            Tab(icon: Icon(Icons.inventory), text: 'บันทึก'),
            Tab(icon: Icon(Icons.flag), text: 'เป้าหมาย'),
          ],
        ),
      ),
      body: Consumer<ProductionProvider>(
        builder: (context, productionProvider, child) {
          if (productionProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (productionProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: const Color(0xFFCD5C5C).shade300),
                  const SizedBox(height: 16),
                  Text(productionProvider.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: productionProvider.clearError,
                    child: const Text('ลองใหม่'),
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(productionProvider),
              _buildTrendsTab(productionProvider),
              _buildRecordsTab(productionProvider),
              _buildTargetsTab(productionProvider),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddProductionDialog(context),
        backgroundColor: const Color(0xFF8B4513).shade700,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildOverviewTab(ProductionProvider provider) {
    final summary = provider.getProductionSummary();
    
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
                'รวมการผลิต',
                '${summary.totalQuantity.toStringAsFixed(1)}',
                Icons.production_quantity_limits,
                const Color(0xFF228B22),
                subtitle: 'หน่วย',
              ),
              _buildSummaryCard(
                'มูลค่ารวม',
                '${NumberFormat('#,##0').format(summary.totalValue)}',
                Icons.attach_money,
                const Color(0xFF8B4513),
                subtitle: 'บาท',
              ),
              _buildSummaryCard(
                'คุณภาพเฉลี่ย',
                '${(summary.averageQuality * 25).toStringAsFixed(0)}%',
                Icons.star,
                const Color(0xFFDAA520),
                subtitle: 'คะแนน',
              ),
              _buildSummaryCard(
                'บันทึกทั้งหมด',
                summary.totalRecords.toString(),
                Icons.list_alt,
                const Color(0xFF8B4513),
                subtitle: 'รายการ',
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Production by Type
          const Text(
            'การผลิตแยกตามประเภท',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...summary.quantityByType.entries
              .where((entry) => entry.value > 0)
              .map((entry) => _buildProductionTypeCard(entry.key, entry.value, summary.valueByType[entry.key] ?? 0)),
          
          const SizedBox(height: 24),
          
          // Recent Records
          const Text(
            'บันทึกล่าสุด',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...summary.recentRecords.take(5).map((record) => _buildProductionCard(record)),
        ],
      ),
    );
  }

  Widget _buildTrendsTab(ProductionProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Type Selection
          Row(
            children: [
              const Text('ประเภทการผลิต: ', style: TextStyle(fontWeight: FontWeight.bold)),
              Expanded(
                child: DropdownButton<ProductionType?>(
                  value: _selectedType,
                  isExpanded: true,
                  hint: const Text('เลือกประเภท'),
                  items: [
                    const DropdownMenuItem<ProductionType?>(
                      value: null,
                      child: Text('ทั้งหมด'),
                    ),
                    ...ProductionType.values.map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(type.displayName),
                    )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value;
                    });
                  },
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Production Trends Chart
          const Text(
            'แนวโน้มการผลิต (7 วันที่ผ่านมา)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          
          if (_selectedType != null) ...[
            Container(
              height: 300,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: _buildTrendChart(provider, _selectedType!),
            ),
          ] else ...[
            const Card(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: Text('เลือกประเภทการผลิตเพื่อดูแนวโน้ม'),
                ),
              ),
            ),
          ],
          
          const SizedBox(height: 24),
          
          // Target Progress
          const Text(
            'ความคืบหน้าเป้าหมาย',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          
          ...ProductionType.values.map((type) {
            final dailyProgress = provider.getTargetProgress(type, 'daily');
            final monthlyProgress = provider.getTargetProgress(type, 'monthly');
            
            if (dailyProgress == 0 && monthlyProgress == 0) return const SizedBox.shrink();
            
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(type.icon, color: type.color),
                        const SizedBox(width: 8),
                        Text(
                          type.displayName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('วันนี้', style: TextStyle(fontSize: 12)),
                              LinearProgressIndicator(
                                value: dailyProgress / 100,
                                backgroundColor: Colors.grey.shade300,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  dailyProgress >= 100 ? const Color(0xFF8B4513) : const Color(0xFF228B22),
                                ),
                              ),
                              Text('${dailyProgress.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('เดือนนี้', style: TextStyle(fontSize: 12)),
                              LinearProgressIndicator(
                                value: monthlyProgress / 100,
                                backgroundColor: Colors.grey.shade300,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  monthlyProgress >= 100 ? const Color(0xFF8B4513) : const Color(0xFF228B22),
                                ),
                              ),
                              Text('${monthlyProgress.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRecordsTab(ProductionProvider provider) {
    final filteredRecords = _searchQuery.isEmpty
        ? provider.productionRecords
        : provider.searchProductionRecords(_searchQuery);
    
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
                  hintText: 'ค้นหาบันทึกการผลิต...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
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
                    ...ProductionType.values.map((type) => Padding(
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
        
        // Records List
        Expanded(
          child: filteredRecords.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('ไม่มีบันทึกการผลิต'),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredRecords.length,
                  itemBuilder: (context, index) {
                    final record = filteredRecords[index];
                    if (_selectedType != null && record.type != _selectedType) {
                      return const SizedBox.shrink();
                    }
                    return _buildProductionCard(record);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildTargetsTab(ProductionProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.productionTargets.length,
      itemBuilder: (context, index) {
        final target = provider.productionTargets[index];
        return _buildTargetCard(target, provider);
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

  Widget _buildProductionTypeCard(ProductionType type, double quantity, double value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: type.color,
          child: Icon(type.icon, color: Colors.white),
        ),
        title: Text(type.displayName),
        subtitle: Text('${quantity.toStringAsFixed(1)} ${type.unit}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${NumberFormat('#,##0').format(value)} บาท',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              '${(value / quantity).toStringAsFixed(1)} บาท/${type.unit}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductionCard(ProductionRecord record) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: record.type.color,
          child: Icon(record.type.icon, color: Colors.white, size: 20),
        ),
        title: Text('${record.livestockName} - ${record.type.displayName}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${record.quantity} ${record.type.unit} - ${DateFormat('dd/MM/yyyy').format(record.date)}'),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: record.quality.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    record.quality.displayName,
                    style: TextStyle(
                      fontSize: 10,
                      color: record.quality.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (record.calculatedTotalValue > 0)
                  Text(
                    '${NumberFormat('#,##0').format(record.calculatedTotalValue)} บาท',
                    style: const TextStyle(fontSize: 12, color: const Color(0xFF8B4513)),
                  ),
              ],
            ),
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
          onSelected: (value) => _handleProductionAction(value.toString(), record),
        ),
        onTap: () => _showProductionDetails(record),
      ),
    );
  }

  Widget _buildTargetCard(ProductionTarget target, ProductionProvider provider) {
    final dailyProgress = provider.getTargetProgress(target.type, 'daily');
    final monthlyProgress = provider.getTargetProgress(target.type, 'monthly');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(target.type.icon, color: target.type.color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${target.type.displayName} - ${target.livestockName ?? 'ทั้งหมด'}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: target.isActive ? const Color(0xFF8B4513) : Colors.grey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    target.isActive ? 'ใช้งาน' : 'ไม่ใช้งาน',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _buildTargetItem('รายวัน', target.dailyTarget, target.type.unit, dailyProgress),
                ),
                Expanded(
                  child: _buildTargetItem('รายเดือน', target.monthlyTarget, target.type.unit, monthlyProgress),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            Row(
              children: [
                Expanded(
                  child: _buildTargetItem('รายสัปดาห์', target.weeklyTarget, target.type.unit, null),
                ),
                Expanded(
                  child: _buildTargetItem('รายปี', target.yearlyTarget, target.type.unit, null),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetItem(String period, double target, String unit, double? progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(period, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text('${target.toStringAsFixed(0)} $unit', style: const TextStyle(fontWeight: FontWeight.bold)),
        if (progress != null) ...[
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: progress / 100,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(
              progress >= 100 ? const Color(0xFF8B4513) : const Color(0xFF228B22),
            ),
          ),
          Text('${progress.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 10)),
        ],
      ],
    );
  }

  Widget _buildTrendChart(ProductionProvider provider, ProductionType type) {
    final trends = provider.getProductionTrends(type, 7);
    
    if (trends.isEmpty) {
      return const Center(child: Text('ไม่มีข้อมูลแนวโน้ม'));
    }

    final spots = trends.entries.map((entry) {
      final index = trends.keys.toList().indexOf(entry.key);
      return FlSpot(index.toDouble(), entry.value);
    }).toList();

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < trends.keys.length) {
                  return Text(
                    trends.keys.elementAt(index),
                    style: const TextStyle(fontSize: 10),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: type.color,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: type.color.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  void _handleProductionAction(String action, ProductionRecord record) {
    switch (action) {
      case 'view':
        _showProductionDetails(record);
        break;
      case 'edit':
        _showEditProductionDialog(record);
        break;
      case 'delete':
        _showDeleteConfirmation(record);
        break;
    }
  }

  void _showProductionDetails(ProductionRecord record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('รายละเอียดการผลิต'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('สัตว์', record.livestockName),
              _buildDetailRow('ประเภท', record.type.displayName),
              _buildDetailRow('ปริมาณ', '${record.quantity} ${record.type.unit}'),
              _buildDetailRow('คุณภาพ', record.quality.displayName),
              _buildDetailRow('วันที่', DateFormat('dd/MM/yyyy').format(record.date)),
              if (record.timeCollected != null)
                _buildDetailRow('เวลาที่เก็บ', DateFormat('HH:mm').format(record.timeCollected!)),
              if (record.pricePerUnit != null)
                _buildDetailRow('ราคาต่อหน่วย', '${record.pricePerUnit!.toStringAsFixed(2)} บาท'),
              if (record.calculatedTotalValue > 0)
                _buildDetailRow('มูลค่ารวม', '${NumberFormat('#,##0.00').format(record.calculatedTotalValue)} บาท'),
              if (record.collectedBy != null)
                _buildDetailRow('ผู้เก็บ', record.collectedBy!),
              if (record.storageLocation != null)
                _buildDetailRow('สถานที่เก็บ', record.storageLocation!),
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

  void _showAddProductionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('เพิ่มบันทึกการผลิต'),
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

  void _showEditProductionDialog(ProductionRecord record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('แก้ไขบันทึกการผลิต'),
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

  void _showDeleteConfirmation(ProductionRecord record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: Text('คุณต้องการลบบันทึกการผลิต ${record.type.displayName} ของ ${record.livestockName} หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<ProductionProvider>().deleteProductionRecord(record.id);
            },
            child: const Text('ลบ', style: TextStyle(color: const Color(0xFFCD5C5C))),
          ),
        ],
      ),
    );
  }
}
