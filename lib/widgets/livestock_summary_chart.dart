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
                          Text(_getTypeName(entry.key)),
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

  String _getTypeName(LivestockType type) {
    switch (type) {
      case LivestockType.beefCattleLocal:
      case LivestockType.beefCattlePurebred:
      case LivestockType.beefCattleCrossbred:
      case LivestockType.dairyCow:
        return 'โค';
      case LivestockType.buffaloLocal:
      case LivestockType.buffaloDairy:
        return 'กระบือ';
      case LivestockType.pigLocal:
      case LivestockType.pigBreeder:
      case LivestockType.pigFattening:
      case LivestockType.pigBreederYoung:
        return 'สุกร';
      case LivestockType.chickenLocal:
      case LivestockType.chickenCrossbred:
      case LivestockType.chickenBroiler:
      case LivestockType.chickenLayer:
      case LivestockType.chickenBreederMeatPS:
      case LivestockType.chickenBreederLayerPS:
      case LivestockType.chickenBreederMeatGP:
      case LivestockType.chickenBreederLayerGP:
        return 'ไก่';
      case LivestockType.duckMeat:
      case LivestockType.duckEgg:
      case LivestockType.duckMuscovy:
      case LivestockType.duckMeatField:
      case LivestockType.duckEggField:
        return 'เป็ด';
      case LivestockType.goatMeat:
      case LivestockType.goatDairy:
        return 'แพะ';
      case LivestockType.sheep:
        return 'แกะ';
      case LivestockType.quailMeat:
      case LivestockType.quailEgg:
        return 'นกกระทา';
      case LivestockType.dog:
        return 'สุนัข';
      case LivestockType.cat:
        return 'แมว';
      case LivestockType.fishFreshwater:
        return 'ปลาน้ำจืด';
      case LivestockType.fishSaltwater:
        return 'ปลาน้ำเค็ม';
      case LivestockType.bird:
        return 'นก';
      case LivestockType.fish:
        return 'ปลา';
      case LivestockType.shrimp:
        return 'กุ้ง';
      case LivestockType.crab:
        return 'ปู';
      case LivestockType.cricket:
        return 'จิ้งหรีด';
      case LivestockType.silkworm:
        return 'หนอนไหม';
      case LivestockType.bee:
        return 'ผึ้ง';
      case LivestockType.other:
        return 'อื่นๆ';
    }
  }

  Color _getTypeColor(LivestockType type) {
    switch (type) {
      case LivestockType.beefCattleLocal:
      case LivestockType.beefCattlePurebred:
      case LivestockType.beefCattleCrossbred:
      case LivestockType.dairyCow:
        return Colors.brown;
      case LivestockType.buffaloLocal:
      case LivestockType.buffaloDairy:
        return Colors.grey;
      case LivestockType.pigLocal:
      case LivestockType.pigBreeder:
      case LivestockType.pigFattening:
      case LivestockType.pigBreederYoung:
        return Colors.pink;
      case LivestockType.chickenLocal:
      case LivestockType.chickenCrossbred:
      case LivestockType.chickenBroiler:
      case LivestockType.chickenLayer:
      case LivestockType.chickenBreederMeatPS:
      case LivestockType.chickenBreederLayerPS:
      case LivestockType.chickenBreederMeatGP:
      case LivestockType.chickenBreederLayerGP:
        return Colors.orange;
      case LivestockType.duckMeat:
      case LivestockType.duckEgg:
      case LivestockType.duckMuscovy:
      case LivestockType.duckMeatField:
      case LivestockType.duckEggField:
        return Colors.yellow;
      case LivestockType.goatMeat:
      case LivestockType.goatDairy:
        return Colors.green;
      case LivestockType.sheep:
        return Colors.purple;
      case LivestockType.quailMeat:
      case LivestockType.quailEgg:
        return Colors.teal;
      case LivestockType.dog:
      case LivestockType.cat:
        return Colors.purple;
      case LivestockType.fishFreshwater:
        return Colors.lightBlue;
      case LivestockType.fishSaltwater:
        return Colors.deepOrange;
      case LivestockType.bird:
      case LivestockType.fish:
        return Colors.blue;
      case LivestockType.shrimp:
      case LivestockType.crab:
        return Colors.cyan;
      case LivestockType.cricket:
      case LivestockType.silkworm:
      case LivestockType.bee:
        return Colors.amber;
      case LivestockType.other:
        return Colors.blue.withOpacity(0.6);
    }
  }
}
