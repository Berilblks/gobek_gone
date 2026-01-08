class AddAddictionRequest {
  final int addictionType;
  final double dailyUsage;
  final double costPerUnit;
  final DateTime quitDate;

  AddAddictionRequest({
    required this.addictionType,
    required this.dailyUsage,
    required this.costPerUnit,
    required this.quitDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'addictionType': addictionType,
      'dailyUsage': dailyUsage,
      'costPerUnit': costPerUnit,
      'quitDate': quitDate.toIso8601String(),
    };
  }
}