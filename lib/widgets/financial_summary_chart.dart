import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/financial_provider.dart';
import '../providers/farm_provider.dart';

class FinancialSummaryChart extends StatelessWidget {
  const FinancialSummaryChart({super.key});

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
                  Icons.account_balance_wallet,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'สรุปการเงิน (30 วันล่าสุด)',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Consumer2<FinancialProvider, FarmProvider>(
              builder: (context, financialProvider, farmProvider, child) {
                if (farmProvider.selectedFarm == null) {
                  return const Center(
                    child: Text('กรุณาเลือกฟาร์ม'),
                  );
                }

                final farmId = farmProvider.selectedFarm!.id;
                final startDate = DateTime.now().subtract(const Duration(days: 30));
                final endDate = DateTime.now();
                
                final totalIncome = financialProvider.getTotalIncome(farmId, startDate, endDate);
                final totalExpense = financialProvider.getTotalExpense(farmId, startDate, endDate);
                final netProfit = totalIncome - totalExpense;

                if (totalIncome == 0 && totalExpense == 0) {
                  return const Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 48,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 8),
                        Text('ยังไม่มีข้อมูลการเงิน'),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'สรุปการเงิน',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              height: 200,
                              child: const Center(
                                child: Text('กราฟการเงิน (ใช้งานได้ในเวอร์ชันเต็ม)'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Income
                    _buildFinancialItem(
                      context,
                      'รายรับ',
                      totalIncome,
                      Colors.green,
                      Icons.trending_up,
                    ),
                    const SizedBox(height: 12),
                    
                    // Expense
                    _buildFinancialItem(
                      context,
                      'รายจ่าย',
                      totalExpense,
                      Colors.red,
                      Icons.trending_down,
                    ),
                    const SizedBox(height: 12),
                    
                    const Divider(),
                    const SizedBox(height: 12),
                    
                    // Net Profit
                    _buildFinancialItem(
                      context,
                      'กำไรสุทธิ',
                      netProfit,
                      netProfit >= 0 ? Colors.green : Colors.red,
                      netProfit >= 0 ? Icons.attach_money : Icons.money_off,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialItem(
    BuildContext context,
    String label,
    double amount,
    Color color,
    IconData icon,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                '${NumberFormat('#,##0').format(amount)} บาท',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
