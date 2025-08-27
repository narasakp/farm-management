import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/livestock_provider.dart';
import '../providers/farm_provider.dart';
import '../models/livestock.dart';

class LivestockSummaryChart extends StatelessWidget {
  const LivestockSummaryChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.pets,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'สรุปปศุสัตว์',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Consumer2<LivestockProvider, FarmProvider>(
              builder: (context, livestockProvider, farmProvider, child) {
                if (farmProvider.selectedFarm == null) {
                  return const Center(
                    child: Text('กรุณาเลือกฟาร์ม'),
                  );
                }

                final summary = livestockProvider.getLivestockSummary(
                  farmProvider.selectedFarm!.id,
                );

                if (summary.isEmpty) {
                  return const Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.pets_outlined,
                          size: 48,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 8),
                        Text('ยังไม่มีข้อมูลปศุสัตว์'),
                      ],
                    ),
                  );
                }

                return Column(
                  children: summary.entries.map((entry) {
                    final type = entry.key;
                    final count = entry.value;
                    final color = _getColorForType(type);
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              type.displayName,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$count ตัว',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorForType(LivestockType type) {
    switch (type) {
      case LivestockType.cattle:
        return Colors.brown;
      case LivestockType.dairyCow:
        return Colors.blue;
      case LivestockType.buffalo:
        return Colors.grey;
      case LivestockType.pig:
        return Colors.pink;
      case LivestockType.chicken:
        return Colors.orange;
      case LivestockType.duck:
        return Colors.yellow;
      case LivestockType.goat:
        return Colors.green;
      case LivestockType.sheep:
        return Colors.purple;
      case LivestockType.quail:
        return Colors.teal;
      case LivestockType.dog:
        return Colors.indigo;
      case LivestockType.cat:
        return Colors.cyan;
      case LivestockType.other:
        return Colors.red;
    }
  }
}
