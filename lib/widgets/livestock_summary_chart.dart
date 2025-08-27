import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/livestock_provider.dart';
import '../providers/farm_provider.dart';
import '../models/livestock.dart';

class LivestockSummaryChart extends StatelessWidget {
  const LivestockSummaryChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<LivestockProvider, FarmProvider>(
      builder: (context, livestockProvider, farmProvider, child) {
        final selectedFarm = farmProvider.selectedFarm;
        if (selectedFarm == null) {
          return const Center(
            child: Text('กรุณาเลือกฟาร์มก่อน'),
          );
        }

        final livestock = livestockProvider.getLivestockByFarm(selectedFarm.id);
        final typeCount = <LivestockType, int>{};
        
        for (final animal in livestock) {
          typeCount[animal.type] = (typeCount[animal.type] ?? 0) + 1;
        }

        if (typeCount.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    'สัดส่วนปศุสัตว์ตามประเภท',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 200,
                    child: const Center(
                      child: Text('ยังไม่มีข้อมูลปศุสัตว์'),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final sections = typeCount.entries.map((entry) {
          return PieChartSectionData(
            color: _getTypeColor(entry.key),
            value: entry.value.toDouble(),
            title: '${entry.value}',
            radius: 60,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList();

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'สัดส่วนปศุสัตว์ตามประเภท',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sections: sections,
                      centerSpaceRadius: 40,
                      sectionsSpace: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  children: typeCount.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 16, bottom: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            color: _getTypeColor(entry.key),
                          ),
                          const SizedBox(width: 4),
                          Text(_getTypeDisplayName(entry.key)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getTypeDisplayName(LivestockType type) {
    switch (type) {
      case LivestockType.cattle:
        return 'โค';
      case LivestockType.buffalo:
        return 'ควาย';
      case LivestockType.pig:
        return 'หมู';
      case LivestockType.chicken:
        return 'ไก่';
      case LivestockType.duck:
        return 'เป็ด';
      case LivestockType.goat:
        return 'แพะ';
      case LivestockType.sheep:
        return 'แกะ';
    }
  }

  Color _getTypeColor(LivestockType type) {
    switch (type) {
      case LivestockType.cattle:
        return Colors.brown;
      case LivestockType.buffalo:
        return Colors.grey;
      case LivestockType.pig:
        return Colors.pink;
      case LivestockType.chicken:
        return Colors.yellow;
      case LivestockType.duck:
        return Colors.blue;
      case LivestockType.goat:
        return Colors.green;
      case LivestockType.sheep:
        return Colors.purple;
    }
  }
}
