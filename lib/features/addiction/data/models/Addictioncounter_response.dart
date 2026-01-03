import 'package:gobek_gone/features/addiction/data/models/Addictiontype.dart';


class AddictionCounterResponse {
  final int id;
  final AddictionType addictionType;
  final DateTime quitDate;
  final double dailyUsage;
  final double costPerUnit;

  AddictionCounterResponse({
    required this.id,
    required this.addictionType,
    required this.quitDate,
    required this.dailyUsage,
    required this.costPerUnit,
  });

  int get cleanDays => DateTime.now().difference(quitDate).inDays;

  factory AddictionCounterResponse.fromJson(Map<String, dynamic> json) {
    return AddictionCounterResponse(
      id: json['id'] ?? 0,
      addictionType: AddictionType.fromValue(json['addictionType'] ?? 1),
      quitDate: json['quitDate'] != null ? DateTime.tryParse(json['quitDate']) ?? DateTime.now() : DateTime.now(),
      dailyUsage: (json['dailyUsage'] as num?)?.toDouble() ?? 0.0,
      costPerUnit: (json['costPerUnit'] as num?)?.toDouble() ?? 0.0,
    );
  }
}