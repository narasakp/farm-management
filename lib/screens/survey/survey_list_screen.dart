import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import '../../providers/survey_provider.dart';
import '../../models/survey_form.dart';

class SurveyListScreen extends StatefulWidget {
  static const routeName = '/survey-list';

  const SurveyListScreen({Key? key}) : super(key: key);

  @override
  State<SurveyListScreen> createState() => _SurveyListScreenState();
}

class _SurveyListScreenState extends State<SurveyListScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  final TextEditingController _searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to avoid calling provider during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SurveyProvider>(context, listen: false).loadSurveys();
    });
  }

  Future<void> _showFilterDialog() async {
    final surveyProvider = context.read<SurveyProvider>();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      surveyProvider.setDateRange(_startDate, _endDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายการสำรวจ'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              setState(() {
                _startDate = null;
                _endDate = null;
                _searchController.clear();
              });
              context.read<SurveyProvider>().clearFilters();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'ค้นหาตามชื่อเกษตรกร',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: (value) {
                context.read<SurveyProvider>().searchSurveys(value);
              },
            ),
          ),
          Expanded(
            child: Consumer<SurveyProvider>(
              builder: (context, surveyProvider, child) {
                if (surveyProvider.isLoading && surveyProvider.surveys.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (surveyProvider.surveys.isEmpty) {
                  return const Center(
                    child: Text('ไม่พบข้อมูลการสำรวจที่ตรงกัน'),
                  );
                }

                return ListView.builder(
                  itemCount: surveyProvider.surveys.length,
                  itemBuilder: (context, index) {
                    final survey = surveyProvider.surveys[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text('เกษตรกร: ${survey.farmerInfo.fullName}'),
                        subtitle: Text('วันที่สำรวจ: ${DateFormat('dd/MM/yyyy').format(survey.surveyDate)}\nผู้สำรวจ: ${survey.surveyorId}'),
                        isThreeLine: true,
                        onTap: () {
                          context.go('/survey-detail', extra: survey);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
