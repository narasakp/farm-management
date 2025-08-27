import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class FinancialScreen extends StatefulWidget {
  const FinancialScreen({super.key});

  @override
  State<FinancialScreen> createState() => _FinancialScreenState();
}

class _FinancialScreenState extends State<FinancialScreen> {
  final List<Map<String, dynamic>> _transactions = [
    {
      'id': '1',
      'type': 'income',
      'category': 'ขายนม',
      'amount': 15000,
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'description': 'ขายนมโค 500 ลิตร',
    },
    {
      'id': '2',
      'type': 'expense',
      'category': 'อาหารสัตว์',
      'amount': 8000,
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'description': 'ซื้อหญ้าแห้ง 10 กระสอบ',
    },
    {
      'id': '3',
      'type': 'income',
      'category': 'ขายไข่',
      'amount': 3500,
      'date': DateTime.now().subtract(const Duration(days: 3)),
      'description': 'ขายไข่ไก่ 100 แผง',
    },
    {
      'id': '4',
      'type': 'expense',
      'category': 'ยารักษาโรค',
      'amount': 2500,
      'date': DateTime.now().subtract(const Duration(days: 5)),
      'description': 'ซื้อยาปฏิชีวนะ',
    },
    {
      'id': '5',
      'type': 'income',
      'category': 'ขายนม',
      'amount': 12000,
      'date': DateTime.now().subtract(const Duration(days: 7)),
      'description': 'ขายนมโค 400 ลิตร',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final totalIncome = _transactions
        .where((t) => t['type'] == 'income')
        .fold<double>(0, (sum, t) => sum + t['amount']);
    
    final totalExpense = _transactions
        .where((t) => t['type'] == 'expense')
        .fold<double>(0, (sum, t) => sum + t['amount']);
    
    final netProfit = totalIncome - totalExpense;

    return Scaffold(
      appBar: AppBar(
        title: const Text('การเงิน'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddTransactionDialog,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCards(totalIncome, totalExpense, netProfit),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'รายการธุรกรรม',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: _showFilterDialog,
                  icon: const Icon(Icons.filter_list, size: 16),
                  label: const Text('กรอง'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _transactions.length,
                itemBuilder: (context, index) {
                  final transaction = _transactions[index];
                  return _buildTransactionCard(transaction);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(double income, double expense, double profit) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.0,
      children: [
        _buildSummaryCard(
          'รายได้',
          NumberFormat('#,##0').format(income),
          'บาท',
          Icons.trending_up,
          Colors.green,
        ),
        _buildSummaryCard(
          'รายจ่าย',
          NumberFormat('#,##0').format(expense),
          'บาท',
          Icons.trending_down,
          Colors.red,
        ),
        _buildSummaryCard(
          'กำไรสุทธิ',
          NumberFormat('#,##0').format(profit),
          'บาท',
          profit >= 0 ? Icons.attach_money : Icons.money_off,
          profit >= 0 ? Colors.green : Colors.red,
        ),
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
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
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

  Widget _buildTransactionCard(Map<String, dynamic> transaction) {
    final isIncome = transaction['type'] == 'income';
    final color = isIncome ? Colors.green : Colors.red;
    final icon = isIncome ? Icons.add_circle : Icons.remove_circle;
    final formatter = DateFormat('dd/MM/yyyy');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          transaction['category'],
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(transaction['description']),
            Text(
              formatter.format(transaction['date']),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        trailing: Text(
          '${isIncome ? '+' : '-'}${NumberFormat('#,##0').format(transaction['amount'])} ฿',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        onTap: () => _showTransactionDetails(transaction),
      ),
    );
  }

  void _showAddTransactionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('เพิ่มรายการ'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('เลือกประเภทรายการ'),
            SizedBox(height: 16),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _showIncomeDialog();
            },
            icon: const Icon(Icons.add_circle, color: Colors.green),
            label: const Text('รายได้'),
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _showExpenseDialog();
            },
            icon: const Icon(Icons.remove_circle, color: Colors.red),
            label: const Text('รายจ่าย'),
          ),
        ],
      ),
    );
  }

  void _showIncomeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('เพิ่มรายได้'),
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

  void _showExpenseDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('เพิ่มรายจ่าย'),
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

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('กรองข้อมูล'),
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

  void _showTransactionDetails(Map<String, dynamic> transaction) {
    final formatter = DateFormat('dd/MM/yyyy HH:mm');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(transaction['category']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ประเภท: ${transaction['type'] == 'income' ? 'รายได้' : 'รายจ่าย'}'),
            const SizedBox(height: 8),
            Text('จำนวน: ${NumberFormat('#,##0').format(transaction['amount'])} บาท'),
            const SizedBox(height: 8),
            Text('วันที่: ${formatter.format(transaction['date'])}'),
            const SizedBox(height: 8),
            Text('รายละเอียด: ${transaction['description']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ปิด'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement edit functionality
            },
            child: const Text('แก้ไข'),
          ),
        ],
      ),
    );
  }
}
