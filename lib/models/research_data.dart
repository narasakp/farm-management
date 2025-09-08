class ResearchData {
  final String id;
  final String projectId;
  final String dataType;
  final String title;
  final String description;
  final Map<String, dynamic> data;
  final String? location;
  final double? latitude;
  final double? longitude;
  final DateTime collectionDate;
  final String collectorName;
  final List<String> tags;
  final String? notes;
  final List<String> attachments;
  final DateTime createdAt;
  final DateTime updatedAt;

  ResearchData({
    required this.id,
    required this.projectId,
    required this.dataType,
    required this.title,
    required this.description,
    required this.data,
    this.location,
    this.latitude,
    this.longitude,
    required this.collectionDate,
    required this.collectorName,
    required this.tags,
    this.notes,
    required this.attachments,
    required this.createdAt,
    required this.updatedAt,
  });

  ResearchData copyWith({
    String? id,
    String? projectId,
    String? dataType,
    String? title,
    String? description,
    Map<String, dynamic>? data,
    String? location,
    double? latitude,
    double? longitude,
    DateTime? collectionDate,
    String? collectorName,
    List<String>? tags,
    String? notes,
    List<String>? attachments,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ResearchData(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      dataType: dataType ?? this.dataType,
      title: title ?? this.title,
      description: description ?? this.description,
      data: data ?? this.data,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      collectionDate: collectionDate ?? this.collectionDate,
      collectorName: collectorName ?? this.collectorName,
      tags: tags ?? this.tags,
      notes: notes ?? this.notes,
      attachments: attachments ?? this.attachments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'dataType': dataType,
      'title': title,
      'description': description,
      'data': data,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'collectionDate': collectionDate.toIso8601String(),
      'collectorName': collectorName,
      'tags': tags,
      'notes': notes,
      'attachments': attachments,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ResearchData.fromJson(Map<String, dynamic> json) {
    return ResearchData(
      id: json['id'],
      projectId: json['projectId'],
      dataType: json['dataType'],
      title: json['title'],
      description: json['description'],
      data: Map<String, dynamic>.from(json['data']),
      location: json['location'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      collectionDate: DateTime.parse(json['collectionDate']),
      collectorName: json['collectorName'],
      tags: List<String>.from(json['tags']),
      notes: json['notes'],
      attachments: List<String>.from(json['attachments']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

// Sample data templates for different research types
class ResearchDataTemplates {
  static Map<String, dynamic> get livestockHealthTemplate => {
    'animalId': '',
    'species': '',
    'breed': '',
    'age': 0,
    'weight': 0.0,
    'temperature': 0.0,
    'heartRate': 0,
    'respiratoryRate': 0,
    'symptoms': <String>[],
    'diagnosis': '',
    'treatment': '',
    'medication': <String>[],
    'followUpDate': '',
  };

  static Map<String, dynamic> get breedingTemplate => {
    'maleId': '',
    'femaleId': '',
    'breedingDate': '',
    'method': '',
    'success': false,
    'pregnancyConfirmed': false,
    'expectedBirthDate': '',
    'actualBirthDate': '',
    'offspring': <Map<String, dynamic>>[],
    'complications': <String>[],
  };

  static Map<String, dynamic> get nutritionTemplate => {
    'feedType': '',
    'feedBrand': '',
    'quantity': 0.0,
    'unit': '',
    'nutritionalContent': <String, dynamic>{},
    'cost': 0.0,
    'supplier': '',
    'feedingSchedule': <String>[],
    'animalResponse': '',
    'weightGain': 0.0,
  };

  static Map<String, dynamic> get productionTemplate => {
    'productType': '', // milk, eggs, meat
    'quantity': 0.0,
    'unit': '',
    'quality': '',
    'date': '',
    'animalId': '',
    'marketPrice': 0.0,
    'productionCost': 0.0,
    'profit': 0.0,
    'notes': '',
  };

  static Map<String, dynamic> get environmentTemplate => {
    'temperature': 0.0,
    'humidity': 0.0,
    'airQuality': '',
    'waterQuality': '',
    'soilCondition': '',
    'weatherConditions': '',
    'seasonalFactors': <String>[],
    'environmentalStress': <String>[],
  };

  static Map<String, dynamic> getTemplate(String dataType) {
    switch (dataType.toLowerCase()) {
      case 'livestock_health':
        return livestockHealthTemplate;
      case 'breeding':
        return breedingTemplate;
      case 'nutrition':
        return nutritionTemplate;
      case 'production':
        return productionTemplate;
      case 'environment':
        return environmentTemplate;
      default:
        return <String, dynamic>{};
    }
  }
}
