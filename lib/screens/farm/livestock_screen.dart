import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/livestock.dart';
import '../../providers/farm_provider.dart';
import '../../providers/livestock_provider.dart';
import 'widgets/health_record_form.dart';

class LivestockScreen extends StatefulWidget {
  const LivestockScreen({super.key});

  @override
  State<LivestockScreen> createState() => _LivestockScreenState();
}

class _LivestockScreenState extends State<LivestockScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final farmProvider = Provider.of<FarmProvider>(context, listen: false);
      if (farmProvider.selectedFarm != null) {
        Provider.of<LivestockProvider>(context, listen: false)
            .loadLivestock(farmProvider.selectedFarm!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final farmProvider = Provider.of<FarmProvider>(context);
    final farmId = farmProvider.selectedFarm?.id;

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
            onPressed: () {
              context.push('/add-livestock');
            },
          ),
        ],
      ),
      body: Consumer<LivestockProvider>(
        builder: (context, livestockProvider, child) {
          if (farmId == null) {
            return const Center(child: Text('กรุณาเลือกฟาร์มก่อน'));
          }
          if (livestockProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final livestock = livestockProvider.getLivestockByFarm(farmId);

          if (livestock.isEmpty) {
            return const Center(child: Text('ยังไม่มีข้อมูลปศุสัตว์ในฟาร์มนี้'));
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCards(livestock),
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
                    itemCount: livestock.length,
                    itemBuilder: (context, index) {
                      final animal = livestock[index];
                      return _buildLivestockCard(animal);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCards(List<Livestock> livestock) {
    final healthyCount = livestock.where((a) => a.status == LivestockStatus.healthy).length;
    final needsAttentionCount = livestock.length - healthyCount;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: [
        _buildSummaryCard('รวม', '${livestock.length}', 'ตัว', Icons.pets, Colors.blue),
        _buildSummaryCard('สุขภาพดี', '$healthyCount', 'ตัว', Icons.favorite, Colors.green),
        _buildSummaryCard('ต้องดูแล', '$needsAttentionCount', 'ตัว', Icons.warning, Colors.orange),
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

  Widget _buildLivestockCard(Livestock animal) {
    final ageInMonths = animal.ageInMonths;
    String ageString = ageInMonths != null ? '${(ageInMonths / 12).floor()} ปี ${(ageInMonths % 12)} เดือน' : 'ไม่ระบุ';

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
                    animal.type == LivestockType.dairyCow ? Icons.agriculture : Icons.egg,
                    color: Colors.green.shade700,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        animal.displayName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${animal.type.displayName} • $ageString',
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
                    animal.status.displayName,
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
                  child: _buildInfoItem('น้ำหนัก', animal.weight != null ? '${animal.weight} กก.' : 'N/A'),
                ),
                Expanded(
                  child: _buildInfoItem('เพศ', animal.gender.displayName),
                ),
                Expanded(
                  child: _buildInfoItem('เบอร์หู', animal.earTag ?? 'N/A'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    context.push('/edit-livestock', extra: animal);
                  },
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


  void _showHealthDialog(Livestock animal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('บันทึกสุขภาพ ${animal.displayName}'),
        content: HealthRecordForm(livestockId: animal.id),

      ),
    );
  }
}
