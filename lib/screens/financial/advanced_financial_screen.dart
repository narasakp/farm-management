import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/advanced_financial_provider.dart';
import '../../models/advanced_financial.dart';
import '../../utils/app_theme.dart';

class AdvancedFinancialScreen extends StatefulWidget {
  const AdvancedFinancialScreen({super.key});

  @override
  State<AdvancedFinancialScreen> createState() => _AdvancedFinancialScreenState();
}

class _AdvancedFinancialScreenState extends State<AdvancedFinancialScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'การเงินขั้นสูง',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.forestGreen,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white),
            onPressed: () => context.go('/dashboard'),
            tooltip: 'กลับหน้าหลัก',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          isScrollable: true,
          tabs: const [
            Tab(text: 'กำไร-ขาดทุน'),
            Tab(text: 'กลุ่มออม'),
            Tab(text: 'เงินปันผล'),
            Tab(text: 'พยากรณ์'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProfitLossTab(),
          _buildGroupSavingsTab(),
          _buildDividendTab(),
          _buildForecastTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        backgroundColor: AppTheme.goldenYellow,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text(
          'เพิ่มรายการ',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildProfitLossTab() {
    return Consumer<AdvancedFinancialProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.profitLossAnalyses.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.analytics,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'ยังไม่มีรายงานกำไร-ขาดทุน',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'สร้างรายงานเพื่อวิเคราะห์ผลประกอบการ',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.profitLossAnalyses.length,
          itemBuilder: (context, index) {
            final analysis = provider.profitLossAnalyses[index];
            return _buildProfitLossCard(analysis);
          },
        );
      },
    );
  }

  Widget _buildProfitLossCard(ProfitLossAnalysis analysis) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: AppTheme.forestGreen, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'รายงานกำไร-ขาดทุน',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: analysis.netProfit > 0 ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    analysis.netProfit > 0 ? 'กำไร' : 'ขาดทุน',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildFinancialSummary(
                    'รายได้รวม',
                    analysis.totalRevenue,
                    Icons.trending_up,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildFinancialSummary(
                    'ค่าใช้จ่าย',
                    analysis.totalExpenses,
                    Icons.trending_down,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildFinancialSummary(
                    'กำไรสุทธิ',
                    analysis.netProfit,
                    Icons.account_balance_wallet,
                    analysis.netProfit > 0 ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildFinancialSummary(
                    'อัตรากำไร',
                    analysis.profitMargin,
                    Icons.percent,
                    AppTheme.goldenYellow,
                    isPercentage: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'ช่วงเวลา: ${_formatDate(analysis.startDate)} - ${_formatDate(analysis.endDate)}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialSummary(String label, double value, IconData icon, Color color, {bool isPercentage = false}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            isPercentage 
                ? '${value.toStringAsFixed(1)}%'
                : '฿${_formatNumber(value)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupSavingsTab() {
    return Consumer<AdvancedFinancialProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.groupSavings.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.savings,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'ยังไม่มีรายการออมกลุ่ม',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'เริ่มต้นการออมเงินกลุ่มเกษตรกร',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.groupSavings.length,
          itemBuilder: (context, index) {
            final savings = provider.groupSavings[index];
            return _buildSavingsCard(savings);
          },
        );
      },
    );
  }

  Widget _buildSavingsCard(GroupSavings savings) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getSavingsTypeColor(savings.type),
          child: Icon(
            _getSavingsTypeIcon(savings.type),
            color: Colors.white,
          ),
        ),
        title: Text(
          savings.type.displayName,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              savings.description,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              '฿${_formatNumber(savings.amount)} • ${_formatDate(savings.date)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStatusChip(savings.status),
            if (savings.status == SavingsStatus.pending)
              TextButton(
                onPressed: () => _approveSavings(savings.id),
                child: const Text('อนุมัติ', style: TextStyle(fontSize: 12)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(SavingsStatus status) {
    Color backgroundColor;
    Color textColor = Colors.white;

    switch (status) {
      case SavingsStatus.pending:
        backgroundColor = Colors.orange;
        break;
      case SavingsStatus.approved:
        backgroundColor = Colors.blue;
        break;
      case SavingsStatus.completed:
        backgroundColor = Colors.green;
        break;
      case SavingsStatus.rejected:
        backgroundColor = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDividendTab() {
    return Consumer<AdvancedFinancialProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.dividendDistributions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.pie_chart,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'ยังไม่มีการจ่ายเงินปันผล',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'คำนวณและจัดสรรเงินปันผลให้สมาชิก',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.dividendDistributions.length,
          itemBuilder: (context, index) {
            final dividend = provider.dividendDistributions[index];
            return _buildDividendCard(dividend);
          },
        );
      },
    );
  }

  Widget _buildDividendCard(DividendDistribution dividend) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.pie_chart, color: AppTheme.goldenYellow, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'การจ่ายเงินปันผล',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildDividendStatusChip(dividend.status),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.account_balance_wallet, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'ยอดรวม: ฿${_formatNumber(dividend.totalAmount)}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calculate, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'วิธีคำนวณ: ${dividend.calculationMethod}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'วันที่จ่าย: ${_formatDate(dividend.distributionDate)}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'รายละเอียดสมาชิก:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ...dividend.memberDividends.map((member) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      member.memberName,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  Text(
                    '${member.sharePercentage.toStringAsFixed(1)}%',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '฿${_formatNumber(member.amount)}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildDividendStatusChip(DividendStatus status) {
    Color backgroundColor;
    switch (status) {
      case DividendStatus.calculated:
        backgroundColor = Colors.blue;
        break;
      case DividendStatus.approved:
        backgroundColor = Colors.green;
        break;
      case DividendStatus.distributed:
        backgroundColor = AppTheme.forestGreen;
        break;
      case DividendStatus.cancelled:
        backgroundColor = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status.displayName,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildForecastTab() {
    return Consumer<AdvancedFinancialProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.forecasts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.trending_up,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'ยังไม่มีการพยากรณ์ทางการเงิน',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'สร้างการพยากรณ์เพื่อวางแผนการเงิน',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.forecasts.length,
          itemBuilder: (context, index) {
            final forecast = provider.forecasts[index];
            return _buildForecastCard(forecast);
          },
        );
      },
    );
  }

  Widget _buildForecastCard(FinancialForecast forecast) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up, color: AppTheme.forestGreen, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'การพยากรณ์ทางการเงิน',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.goldenYellow,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${forecast.confidenceLevel.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.model_training, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'โมเดล: ${forecast.model.displayName}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(width: 16),
                Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'ระยะเวลา: ${forecast.forecastMonths} เดือน',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'พยากรณ์ 3 เดือนแรก:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ...forecast.monthlyForecasts.take(3).map((monthly) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(
                      '${monthly.month}/${monthly.year}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'กำไร: ฿${_formatNumber(monthly.predictedProfit)}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Text(
                    '±${monthly.confidenceInterval.toStringAsFixed(0)}%',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Color _getSavingsTypeColor(SavingsType type) {
    switch (type) {
      case SavingsType.deposit:
        return Colors.green;
      case SavingsType.withdrawal:
        return Colors.orange;
      case SavingsType.interest:
        return Colors.blue;
      case SavingsType.dividend:
        return AppTheme.goldenYellow;
    }
  }

  IconData _getSavingsTypeIcon(SavingsType type) {
    switch (type) {
      case SavingsType.deposit:
        return Icons.add;
      case SavingsType.withdrawal:
        return Icons.remove;
      case SavingsType.interest:
        return Icons.percent;
      case SavingsType.dividend:
        return Icons.pie_chart;
    }
  }

  String _formatNumber(double number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(0)}K';
    } else {
      return number.toStringAsFixed(0);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showAddDialog() {
    final currentTab = _tabController.index;
    switch (currentTab) {
      case 0:
        _showProfitLossDialog();
        break;
      case 1:
        _showSavingsDialog();
        break;
      case 2:
        _showDividendDialog();
        break;
      case 3:
        _showForecastDialog();
        break;
    }
  }

  void _showProfitLossDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ฟีเจอร์สร้างรายงานกำไร-ขาดทุนจะพัฒนาในขั้นตอนถัดไป'),
        backgroundColor: AppTheme.goldenYellow,
      ),
    );
  }

  void _showSavingsDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ฟีเจอร์เพิ่มรายการออมจะพัฒนาในขั้นตอนถัดไป'),
        backgroundColor: AppTheme.goldenYellow,
      ),
    );
  }

  void _showDividendDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ฟีเจอร์คำนวณเงินปันผลจะพัฒนาในขั้นตอนถัดไป'),
        backgroundColor: AppTheme.goldenYellow,
      ),
    );
  }

  void _showForecastDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ฟีเจอร์สร้างการพยากรณ์จะพัฒนาในขั้นตอนถัดไป'),
        backgroundColor: AppTheme.goldenYellow,
      ),
    );
  }

  void _approveSavings(String savingsId) async {
    final provider = Provider.of<AdvancedFinancialProvider>(context, listen: false);
    await provider.approveGroupSavings(savingsId, 'ADMIN001');
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('อนุมัติรายการออมเรียบร้อย'),
        backgroundColor: AppTheme.forestGreen,
      ),
    );
  }
}
