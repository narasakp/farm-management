import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../providers/farm_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/farm.dart';
import '../../widgets/farm_card.dart';
import 'add_farm_screen.dart';

class FarmManagementScreen extends StatefulWidget {
  const FarmManagementScreen({super.key});

  @override
  State<FarmManagementScreen> createState() => _FarmManagementScreenState();
}

class _FarmManagementScreenState extends State<FarmManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFarms();
    });
  }

  Future<void> _loadFarms() async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.currentUser != null) {
      await context.read<FarmProvider>().loadFarms(authProvider.currentUser!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).equals(MOBILE);
    
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadFarms,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.agriculture,
                    size: 32,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'จัดการฟาร์ม',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'บริหารจัดการข้อมูลฟาร์มของคุณ',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddFarmScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: Text(isMobile ? 'เพิ่ม' : 'เพิ่มฟาร์ม'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Farm List
              Consumer<FarmProvider>(
                builder: (context, farmProvider, child) {
                  if (farmProvider.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (farmProvider.farms.isEmpty) {
                    return _buildEmptyState();
                  }

                  return _buildFarmGrid(farmProvider.farms, isMobile);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.agriculture_outlined,
            size: 80,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
          const SizedBox(height: 16),
          Text(
            'ยังไม่มีฟาร์ม',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'เริ่มต้นด้วยการเพิ่มฟาร์มแรกของคุณ',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddFarmScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('เพิ่มฟาร์มแรก'),
          ),
        ],
      ),
    );
  }

  Widget _buildFarmGrid(List<Farm> farms, bool isMobile) {
    final crossAxisCount = isMobile ? 1 : 2;
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: isMobile ? 1.2 : 1.5,
      ),
      itemCount: farms.length,
      itemBuilder: (context, index) {
        return FarmCard(
          farm: farms[index],
          onTap: () => _selectFarm(farms[index]),
          onEdit: () => _editFarm(farms[index]),
          onDelete: () => _deleteFarm(farms[index]),
        );
      },
    );
  }

  void _selectFarm(Farm farm) {
    context.read<FarmProvider>().selectFarm(farm);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('เลือกฟาร์ม "${farm.name}" แล้ว'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  void _editFarm(Farm farm) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddFarmScreen(farm: farm),
      ),
    );
  }

  void _deleteFarm(Farm farm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: Text('คุณต้องการลบฟาร์ม "${farm.name}" หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await context.read<FarmProvider>().deleteFarm(farm.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('ลบฟาร์มสำเร็จ'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString()),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );
  }
}
