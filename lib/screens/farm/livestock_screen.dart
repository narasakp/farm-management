import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LivestockScreen extends StatefulWidget {
  const LivestockScreen({super.key});

  @override
  State<LivestockScreen> createState() => _LivestockScreenState();
}

class _LivestockScreenState extends State<LivestockScreen> {
  final List<Map<String, dynamic>> _livestock = [
    {
      'id': '1',
      'name': 'โคนม #001',
      'type': 'โคนม',
      'age': '3 ปี',
      'weight': '450 กก.',
      'health': 'ดี',
      'lastCheckup': '15/08/2567',
      'status': 'ปกติ',
    },
    {
      'id': '2', 
      'name': 'โคนม #002',
      'type': 'โคนม',
      'age': '2 ปี 6 เดือน',
      'weight': '380 กก.',
      'health': 'ดี',
      'lastCheckup': '10/08/2567',
      'status': 'ปกติ',
    },
    {
      'id': '3',
      'name': 'ไก่ไข่ #A01',
      'type': 'ไก่ไข่',
      'age': '8 เดือน',
      'weight': '1.8 กก.',
      'health': 'ดี',
      'lastCheckup': '20/08/2567',
      'status': 'ปกติ',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('จัดการปศุสัตว์'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddLivestockDialog,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCards(),
            const SizedBox(height: 24),
            Text(
              'รายการปศุสัตว์',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _livestock.length,
                itemBuilder: (context, index) {
                  final animal = _livestock[index];
                  return _buildLivestockCard(animal);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: [
        _buildSummaryCard('รวม', '${_livestock.length}', 'ตัว', Icons.pets, Colors.blue),
        _buildSummaryCard('สุขภาพดี', '${_livestock.where((a) => a['health'] == 'ดี').length}', 'ตัว', Icons.favorite, Colors.green),
        _buildSummaryCard('ต้องดูแล', '0', 'ตัว', Icons.warning, Colors.orange),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, String unit, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(unit, style: Theme.of(context).textTheme.bodySmall),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLivestockCard(Map<String, dynamic> animal) {
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
                  backgroundColor: Colors.green.shade100,
                  child: Icon(
                    animal['type'] == 'โคนม' ? Icons.agriculture : Icons.egg,
                    color: Colors.green.shade700,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        animal['name'],
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${animal['type']} • ${animal['age']}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    animal['status'],
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem('น้ำหนัก', animal['weight']),
                ),
                Expanded(
                  child: _buildInfoItem('สุขภาพ', animal['health']),
                ),
                Expanded(
                  child: _buildInfoItem('ตรวจล่าสุด', animal['lastCheckup']),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _showEditDialog(animal),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('แก้ไข'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _showHealthDialog(animal),
                  icon: const Icon(Icons.medical_services, size: 16),
                  label: const Text('บันทึกสุขภาพ'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _showAddLivestockDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('เพิ่มปศุสัตว์'),
        content: const Text('ฟีเจอร์นี้จะเปิดใช้งานในเร็วๆ นี้'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ตกลง'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(Map<String, dynamic> animal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('แก้ไขข้อมูล ${animal['name']}'),
        content: const Text('ฟีเจอร์นี้จะเปิดใช้งานในเร็วๆ นี้'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('บันทึก'),
          ),
        ],
      ),
    );
  }

  void _showHealthDialog(Map<String, dynamic> animal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('บันทึกสุขภาพ ${animal['name']}'),
        content: const Text('ฟีเจอร์นี้จะเปิดใช้งานในเร็วๆ นี้'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('บันทึก'),
          ),
        ],
      ),
    );
  }
}
