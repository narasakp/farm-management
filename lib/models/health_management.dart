import 'package:flutter/material.dart';

enum HealthRecordType {
  vaccination,
  treatment,
  checkup,
  medication,
  surgery,
  injury,
  illness,
  preventive,
}

extension HealthRecordTypeExtension on HealthRecordType {
  String get displayName {
    switch (this) {
      case HealthRecordType.vaccination:
        return 'การฉีดวัคซีน';
      case HealthRecordType.treatment:
        return 'การรักษา';
      case HealthRecordType.checkup:
        return 'การตรวจสุขภาพ';
      case HealthRecordType.medication:
        return 'การให้ยา';
      case HealthRecordType.surgery:
        return 'การผ่าตัด';
      case HealthRecordType.injury:
        return 'การบาดเจ็บ';
      case HealthRecordType.illness:
        return 'การเจ็บป่วย';
      case HealthRecordType.preventive:
        return 'การป้องกัน';
    }
  }

  IconData get icon {
    switch (this) {
      case HealthRecordType.vaccination:
        return Icons.vaccines;
      case HealthRecordType.treatment:
        return Icons.medical_services;
      case HealthRecordType.checkup:
        return Icons.health_and_safety;
      case HealthRecordType.medication:
        return Icons.medication;
      case HealthRecordType.surgery:
        return Icons.local_hospital;
      case HealthRecordType.injury:
        return Icons.healing;
      case HealthRecordType.illness:
        return Icons.sick;
      case HealthRecordType.preventive:
        return Icons.shield;
    }
  }

  Color get color {
    switch (this) {
      case HealthRecordType.vaccination:
        return Colors.green;
      case HealthRecordType.treatment:
        return Colors.blue;
      case HealthRecordType.checkup:
        return Colors.teal;
      case HealthRecordType.medication:
        return Colors.orange;
      case HealthRecordType.surgery:
        return Colors.red;
      case HealthRecordType.injury:
        return Colors.deepOrange;
      case HealthRecordType.illness:
        return Colors.red.shade300;
      case HealthRecordType.preventive:
        return Colors.purple;
    }
  }
}

enum HealthStatus {
  healthy,
  sick,
  recovering,
  critical,
  quarantine,
  deceased,
}

extension HealthStatusExtension on HealthStatus {
  String get displayName {
    switch (this) {
      case HealthStatus.healthy:
        return 'แข็งแรง';
      case HealthStatus.sick:
        return 'เจ็บป่วย';
      case HealthStatus.recovering:
        return 'กำลังหาย';
      case HealthStatus.critical:
        return 'อาการหนัก';
      case HealthStatus.quarantine:
        return 'กักกัน';
      case HealthStatus.deceased:
        return 'ตาย';
    }
  }

  Color get color {
    switch (this) {
      case HealthStatus.healthy:
        return Colors.green;
      case HealthStatus.sick:
        return Colors.orange;
      case HealthStatus.recovering:
        return Colors.blue;
      case HealthStatus.critical:
        return Colors.red;
      case HealthStatus.quarantine:
        return Colors.purple;
      case HealthStatus.deceased:
        return Colors.grey;
    }
  }
}

class HealthRecord {
  final String id;
  final String livestockId;
  final String livestockName;
  final HealthRecordType type;
  final String title;
  final String description;
  final DateTime date;
  final String? veterinarian;
  final String? clinic;
  final double? cost;
  final String? medication;
  final String? dosage;
  final DateTime? nextDueDate;
  final HealthStatus status;
  final List<String> symptoms;
  final String? notes;
  final List<String> attachments;
  final DateTime createdAt;
  final DateTime updatedAt;

  HealthRecord({
    required this.id,
    required this.livestockId,
    required this.livestockName,
    required this.type,
    required this.title,
    required this.description,
    required this.date,
    this.veterinarian,
    this.clinic,
    this.cost,
    this.medication,
    this.dosage,
    this.nextDueDate,
    required this.status,
    this.symptoms = const [],
    this.notes,
    this.attachments = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  HealthRecord copyWith({
    String? id,
    String? livestockId,
    String? livestockName,
    HealthRecordType? type,
    String? title,
    String? description,
    DateTime? date,
    String? veterinarian,
    String? clinic,
    double? cost,
    String? medication,
    String? dosage,
    DateTime? nextDueDate,
    HealthStatus? status,
    List<String>? symptoms,
    String? notes,
    List<String>? attachments,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HealthRecord(
      id: id ?? this.id,
      livestockId: livestockId ?? this.livestockId,
      livestockName: livestockName ?? this.livestockName,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      veterinarian: veterinarian ?? this.veterinarian,
      clinic: clinic ?? this.clinic,
      cost: cost ?? this.cost,
      medication: medication ?? this.medication,
      dosage: dosage ?? this.dosage,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      status: status ?? this.status,
      symptoms: symptoms ?? this.symptoms,
      notes: notes ?? this.notes,
      attachments: attachments ?? this.attachments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'livestockId': livestockId,
      'livestockName': livestockName,
      'type': type.name,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'veterinarian': veterinarian,
      'clinic': clinic,
      'cost': cost,
      'medication': medication,
      'dosage': dosage,
      'nextDueDate': nextDueDate?.toIso8601String(),
      'status': status.name,
      'symptoms': symptoms,
      'notes': notes,
      'attachments': attachments,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory HealthRecord.fromJson(Map<String, dynamic> json) {
    return HealthRecord(
      id: json['id'],
      livestockId: json['livestockId'],
      livestockName: json['livestockName'],
      type: HealthRecordType.values.firstWhere((e) => e.name == json['type']),
      title: json['title'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      veterinarian: json['veterinarian'],
      clinic: json['clinic'],
      cost: json['cost']?.toDouble(),
      medication: json['medication'],
      dosage: json['dosage'],
      nextDueDate: json['nextDueDate'] != null ? DateTime.parse(json['nextDueDate']) : null,
      status: HealthStatus.values.firstWhere((e) => e.name == json['status']),
      symptoms: List<String>.from(json['symptoms'] ?? []),
      notes: json['notes'],
      attachments: List<String>.from(json['attachments'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class VaccinationSchedule {
  final String id;
  final String vaccineName;
  final String description;
  final int ageInDays;
  final bool isRequired;
  final String? notes;

  VaccinationSchedule({
    required this.id,
    required this.vaccineName,
    required this.description,
    required this.ageInDays,
    required this.isRequired,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vaccineName': vaccineName,
      'description': description,
      'ageInDays': ageInDays,
      'isRequired': isRequired,
      'notes': notes,
    };
  }

  factory VaccinationSchedule.fromJson(Map<String, dynamic> json) {
    return VaccinationSchedule(
      id: json['id'],
      vaccineName: json['vaccineName'],
      description: json['description'],
      ageInDays: json['ageInDays'],
      isRequired: json['isRequired'],
      notes: json['notes'],
    );
  }
}

class HealthSummary {
  final int totalRecords;
  final int vaccinationCount;
  final int treatmentCount;
  final int healthyCount;
  final int sickCount;
  final double totalCost;
  final DateTime? lastVaccination;
  final DateTime? nextDueVaccination;
  final List<HealthRecord> recentRecords;
  final List<HealthRecord> upcomingVaccinations;

  HealthSummary({
    required this.totalRecords,
    required this.vaccinationCount,
    required this.treatmentCount,
    required this.healthyCount,
    required this.sickCount,
    required this.totalCost,
    this.lastVaccination,
    this.nextDueVaccination,
    required this.recentRecords,
    required this.upcomingVaccinations,
  });
}
