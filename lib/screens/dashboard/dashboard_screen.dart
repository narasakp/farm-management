import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:intl/intl.dart';
import '../../providers/farm_provider.dart';
import '../../providers/livestock_provider.dart';
import '../../providers/financial_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/dashboard_card.dart';
import '../../widgets/livestock_summary_chart.dart';
import '../../widgets/financial_summary_chart.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final authProvider = context.read<AuthProvider>();
    final farmProvider = context.read<FarmProvider>();
    
    if (authProvider.currentUser != null) {
      await farmProvider.loadFarms(authProvider.currentUser!.id);
      
      if (farmProvider.selectedFarm != null) {
        await context.read<LivestockProvider>().loadLivestock(farmProvider.selectedFarm!.id);
        await context.read<FinancialProvider>().loadFinancialRecords(farmProvider.selectedFarm!.id);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).equals(MOBILE);
    final isTablet = ResponsiveBreakpoints.of(context).equals(TABLET);
    
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(),
              const SizedBox(height: 24),
              
              // Farm Selector
              _buildFarmSelector(),
              const SizedBox(height: 24),
              
              // Summary Cards
              _buildSummaryCards(isMobile, isTablet),
              const SizedBox(height: 24),
              
              // Charts Section
              _buildChartsSection(isMobile),
              const SizedBox(height: 24),
              
              // Recent Activities
              _buildRecentActivities(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;
        final now = DateTime.now();
        final formatter = DateFormat('EEEE, d MMMM yyyy', 'th_TH');
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'สวัสดี, ${user?.firstName ?? 'ผู้ใช้'}!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              formatter.format(now),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFarmSelector() {
    return Consumer<FarmProvider>(
      builder: (context, farmProvider, child) {
        if (farmProvider.farms.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(
                    Icons.agriculture_outlined,
                    size: 48,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ยังไม่มีฟาร์ม',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'เริ่มต้นด้วยการเพิ่มฟาร์มแรกของคุณ',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Navigate to add farm screen
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('เพิ่มฟาร์ม'),
                  ),
                ],
              ),
            ),
          );
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.agriculture,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ฟาร์มที่เลือก',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      DropdownButton<String>(
                        value: farmProvider.selectedFarm?.id,
                        isExpanded: true,
                        underline: const SizedBox(),
                        items: farmProvider.farms.map((farm) {
                          return DropdownMenuItem(
                            value: farm.id,
                            child: Text(
                              farm.name,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          );
                        }).toList(),
                        onChanged: (farmId) {
                          final farm = farmProvider.farms.firstWhere((f) => f.id == farmId);
                          farmProvider.selectFarm(farm);
                          _loadData();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryCards(bool isMobile, bool isTablet) {
    return Consumer3<FarmProvider, LivestockProvider, FinancialProvider>(
      builder: (context, farmProvider, livestockProvider, financialProvider, child) {
        if (farmProvider.selectedFarm == null) {
          return const SizedBox();
        }

        final farmId = farmProvider.selectedFarm!.id;
        final livestockSummary = livestockProvider.getLivestockSummary(farmId);
        final totalAnimals = livestockSummary.values.fold(0, (sum, count) => sum + count);
        final monthlyIncome = financialProvider.getTotalIncome(
          farmId, 
          DateTime.now().subtract(const Duration(days: 30)), 
          DateTime.now(),
        );
        final monthlyExpense = financialProvider.getTotalExpense(
          farmId, 
          DateTime.now().subtract(const Duration(days: 30)), 
          DateTime.now(),
        );
        final netProfit = monthlyIncome - monthlyExpense;

        final crossAxisCount = isMobile ? 2 : (isTablet ? 3 : 4);
        
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: isMobile ? 1.2 : 1.5,
          children: [
            DashboardCard(
              title: 'จำนวนปศุสัตว์',
              value: totalAnimals.toString(),
              subtitle: 'ตัว',
              icon: Icons.pets,
              color: Colors.blue,
            ),
            DashboardCard(
              title: 'รายได้เดือนนี้',
              value: NumberFormat('#,##0').format(monthlyIncome),
              subtitle: 'บาท',
              icon: Icons.trending_up,
              color: Colors.green,
            ),
            DashboardCard(
              title: 'รายจ่ายเดือนนี้',
              value: NumberFormat('#,##0').format(monthlyExpense),
              subtitle: 'บาท',
              icon: Icons.trending_down,
              color: Colors.orange,
            ),
            DashboardCard(
              title: 'กำไรสุทธิ',
              value: NumberFormat('#,##0').format(netProfit),
              subtitle: 'บาท',
              icon: netProfit >= 0 ? Icons.attach_money : Icons.money_off,
              color: netProfit >= 0 ? Colors.green : Colors.red,
            ),
          ],
        );
      },
    );
  }

  Widget _buildChartsSection(bool isMobile) {
    return Consumer2<LivestockProvider, FinancialProvider>(
      builder: (context, livestockProvider, financialProvider, child) {
        return Column(
          children: [
            if (isMobile) ...[
              // Mobile: Stack charts vertically
              const LivestockSummaryChart(),
              const SizedBox(height: 16),
              const FinancialSummaryChart(),
            ] else ...[
              // Desktop/Tablet: Side by side
              Row(
                children: [
                  const Expanded(child: LivestockSummaryChart()),
                  const SizedBox(width: 16),
                  const Expanded(child: FinancialSummaryChart()),
                ],
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildRecentActivities() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.history,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'กิจกรรมล่าสุด',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final activities = [
                  {'icon': Icons.add_circle, 'title': 'เพิ่มโคนม 2 ตัว', 'time': '2 ชั่วโมงที่แล้ว'},
                  {'icon': Icons.medical_services, 'title': 'บันทึกการรักษาไก่ป่วย', 'time': '5 ชั่วโมงที่แล้ว'},
                  {'icon': Icons.attach_money, 'title': 'ขายไข่ไก่ 20 แผง', 'time': '1 วันที่แล้ว'},
                  {'icon': Icons.shopping_cart, 'title': 'ซื้ออาหารสัตว์', 'time': '2 วันที่แล้ว'},
                  {'icon': Icons.vaccines, 'title': 'ฉีดวัคซีนโค 5 ตัว', 'time': '3 วันที่แล้ว'},
                ];
                
                final activity = activities[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                    child: Icon(
                      activity['icon'] as IconData,
                      color: Theme.of(context).primaryColor,
                      size: 20,
                    ),
                  ),
                  title: Text(activity['title'] as String),
                  subtitle: Text(activity['time'] as String),
                  contentPadding: EdgeInsets.zero,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
