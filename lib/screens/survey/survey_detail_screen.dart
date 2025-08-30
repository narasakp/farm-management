import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/survey_form.dart';

class SurveyDetailScreen extends StatelessWidget {
  final FarmSurvey survey;

  const SurveyDetailScreen({Key? key, required this.survey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายละเอียดการสำรวจ'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('ข้อมูลเกษตรกร'),
            _buildDetailCard([
              _buildDetailRow('ชื่อ-สกุล:', survey.farmerInfo.fullName),
              _buildDetailRow('เลขบัตรประชาชน:', survey.farmerInfo.idCard),
              _buildDetailRow('เบอร์โทรศัพท์:', survey.farmerInfo.phoneNumber),
              _buildDetailRow('ที่อยู่:', survey.farmerInfo.address.fullAddress),
            ]),
            const SizedBox(height: 20),
            _buildSectionTitle('ข้อมูลการสำรวจ'),
            _buildDetailCard([
              _buildDetailRow('วันที่สำรวจ:', DateFormat('dd/MM/yyyy').format(survey.surveyDate)),
              _buildDetailRow('ผู้สำรวจ:', survey.surveyorId),
            ]),
            const SizedBox(height: 20),
            _buildSectionTitle('ข้อมูลปศุสัตว์'),
            _buildDetailCard(
              survey.livestockData.map((entry) {
                final breedText = entry.breed != null ? ' (${entry.breed})' : '';
                final ageGroupText = entry.ageGroup != null ? ' - ${entry.ageGroup}' : '';
                return _buildDetailRow(
                  '${entry.type.displayName}$breedText$ageGroupText:',
                  '${entry.count} ตัว',
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
             _buildSectionTitle('ข้อมูลอื่นๆ'),
            _buildDetailCard([
              _buildDetailRow('พื้นที่ปลูกพืชอาหารสัตว์ (ไร่):', survey.cropArea?.toString() ?? 'N/A'),
              _buildDetailRow('หมายเหตุ:', survey.notes ?? 'ไม่มี'),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDetailCard(List<Widget> children) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }
}
