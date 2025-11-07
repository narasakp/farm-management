import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/production_record.dart';
import '../models/livestock.dart';
import '../providers/production_records_provider.dart';
import '../providers/auth_provider.dart';

/// Production Records Tab - Real API integration
class ProductionRecordsTab extends StatefulWidget {
  final Livestock? livestock;

  const ProductionRecordsTab({super.key, this.livestock});

  @override
  State<ProductionRecordsTab> createState() => _ProductionRecordsTabState();
}

class _ProductionRecordsTabState extends State<ProductionRecordsTab> {
  ProductionType? _selectedType;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized && widget.livestock != null) {
      _loadData();
      _isInitialized = true;
    }
  }

  Future<void> _loadData() async {
    final provider = Provider.of<ProductionRecordsProvider>(context, listen: false);
    await provider.loadRecords(
      widget.livestock!.id,
      startDate: _startDate?.toIso8601String().split('T')[0],
      endDate: _endDate?.toIso8601String().split('T')[0],
      productionType: _selectedType?.code,
    );
    await provider.loadStatistics(
      widget.livestock!.id,
      startDate: _startDate?.toIso8601String().split('T')[0],
      endDate: _endDate?.toIso8601String().split('T')[0],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.livestock == null) {
      return const Center(
        child: Text('กรุณาเลือกสัตว์เพื่อดูบันทึกผลผลิต'),
      );
    }

    return Consumer<ProductionRecordsProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            _buildFilters(provider),
            _buildStatistics(provider),
            Expanded(
              child: _buildRecordsList(provider),
            ),
          ],
        );
      },
    );
  }

  /// Build filter section
  Widget _buildFilters(ProductionRecordsProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[50],
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<ProductionType>(
                  value: _selectedType,
                  decoration: InputDecoration(
                    labelText: 'ประเภทผลผลิต',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('ทั้งหมด'),
                    ),
                    ...ProductionType.values.map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(type.displayName),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value;
                    });
                    _loadData();
                  },
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => _showAddDialog(),
                icon: const Icon(Icons.add),
                label: const Text('บันทึกผลผลิต'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _selectDateRange(),
                  icon: const Icon(Icons.date_range),
                  label: Text(
                    _startDate != null && _endDate != null
                        ? '${DateFormat('dd/MM/yy').format(_startDate!)} - ${DateFormat('dd/MM/yy').format(_endDate!)}'
                        : 'เลือกช่วงเวลา',
                  ),
                ),
              ),
              if (_startDate != null)
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _startDate = null;
                      _endDate = null;
                    });
                    _loadData();
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build statistics cards
  Widget _buildStatistics(ProductionRecordsProvider provider) {
    if (provider.statistics.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'สถิติผลผลิต',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: provider.statistics.map((stat) {
              return _buildStatCard(stat);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(ProductionStatistics stat) {
    return Container(
      width: (MediaQuery.of(context).size.width - 56) / 2,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            stat.productionType.displayName,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${stat.totalQuantity.toStringAsFixed(1)} ${stat.unit}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'เฉลี่ย: ${stat.avgQuantity.toStringAsFixed(1)} ${stat.unit}',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          Text(
            '${stat.recordCount} รายการ',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  /// Build records list
  Widget _buildRecordsList(ProductionRecordsProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'เกิดข้อผิดพลาด',
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            Text(
              provider.error!,
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('ลองใหม่'),
            ),
          ],
        ),
      );
    }

    if (provider.records.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'ยังไม่มีบันทึกผลผลิต',
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            const Text(
              'เริ่มต้นด้วยการเพิ่มบันทึกผลผลิตแรก',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showAddDialog(),
              icon: const Icon(Icons.add),
              label: const Text('บันทึกผลผลิต'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.records.length,
      itemBuilder: (context, index) {
        final record = provider.records[index];
        return _buildRecordCard(record, provider);
      },
    );
  }

  Widget _buildRecordCard(ProductionRecord record, ProductionRecordsProvider provider) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getTypeColor(record.productionType),
          child: Icon(
            _getTypeIcon(record.productionType),
            color: Colors.white,
          ),
        ),
        title: Text(
          '${record.quantity} ${record.unit}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(record.productionType.displayName),
            Text(dateFormat.format(record.productionDate)),
            if (record.notes != null) Text(record.notes!, style: const TextStyle(fontSize: 12)),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('แก้ไข'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('ลบ', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'edit') {
              _showEditDialog(record);
            } else if (value == 'delete') {
              _confirmDelete(record, provider);
            }
          },
        ),
      ),
    );
  }

  Color _getTypeColor(ProductionType type) {
    switch (type) {
      case ProductionType.milk:
        return Colors.blue;
      case ProductionType.egg:
        return Colors.orange;
      case ProductionType.weight:
        return Colors.green;
    }
  }

  IconData _getTypeIcon(ProductionType type) {
    switch (type) {
      case ProductionType.milk:
        return Icons.water_drop;
      case ProductionType.egg:
        return Icons.egg;
      case ProductionType.weight:
        return Icons.scale;
    }
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _loadData();
    }
  }

  Future<void> _showAddDialog() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    ProductionType? selectedType = ProductionType.milk;
    final dateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(DateTime.now()),
    );
    final quantityController = TextEditingController();
    final notesController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('บันทึกผลผลิต'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<ProductionType>(
                value: selectedType,
                decoration: const InputDecoration(
                  labelText: 'ประเภทผลผลิต',
                ),
                items: ProductionType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.displayName),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedType = value;
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: dateController,
                decoration: const InputDecoration(
                  labelText: 'วันที่',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    dateController.text = DateFormat('yyyy-MM-dd').format(date);
                  }
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: quantityController,
                decoration: InputDecoration(
                  labelText: 'ปริมาณ',
                  suffixText: selectedType?.defaultUnit ?? '',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'หมายเหตุ (ไม่บังคับ)',
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (selectedType == null || quantityController.text.isEmpty) {
                return;
              }

              final provider = Provider.of<ProductionRecordsProvider>(
                context,
                listen: false,
              );

              final record = ProductionRecord(
                livestockId: widget.livestock!.id,
                userId: int.tryParse(authProvider.currentUser!.id) ?? 0,
                productionDate: DateTime.parse(dateController.text),
                productionType: selectedType!,
                quantity: double.parse(quantityController.text),
                unit: selectedType!.defaultUnit,
                notes: notesController.text.isEmpty ? null : notesController.text,
              );

              final success = await provider.createRecord(record);
              if (context.mounted) {
                Navigator.pop(context, success);
              }
            },
            child: const Text('บันทึก'),
          ),
        ],
      ),
    );

    if (result == true) {
      _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('บันทึกผลผลิตสำเร็จ')),
        );
      }
    }
  }

  Future<void> _showEditDialog(ProductionRecord record) async {
    // Similar to _showAddDialog but for editing
    // Implementation similar to above
  }

  Future<void> _confirmDelete(ProductionRecord record, ProductionRecordsProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: const Text('คุณต้องการลบบันทึกผลผลิตนี้ใช่หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await provider.deleteRecord(record.id!);
      if (success && mounted) {
        _loadData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ลบบันทึกผลผลิตสำเร็จ')),
        );
      }
    }
  }
}
