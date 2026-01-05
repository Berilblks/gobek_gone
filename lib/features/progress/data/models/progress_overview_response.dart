class WeightRecordDto {
  final DateTime date;
  final double weight;
  final double bmi;

  WeightRecordDto({required this.date, required this.weight, required this.bmi});

  factory WeightRecordDto.fromJson(Map<String, dynamic> json) {
    return WeightRecordDto(
      date: DateTime.parse(json['date']),
      weight: (json['weight'] as num).toDouble(),
      bmi: (json['bmi'] as num).toDouble(),
    );
  }
}

class ProgressOverviewResponse {
  final double currentWeight;
  final double startWeight;
  final double targetWeight;
  final double weightLost;
  final double remainingWeight;
  final double progressPercentage;
  
  final double currentBmi;
  final String bmiStatus;
  final int currentStreak;
  final List<WeightRecordDto> history;

  ProgressOverviewResponse({
    required this.currentWeight,
    required this.startWeight,
    required this.targetWeight,
    required this.weightLost,
    required this.remainingWeight,
    required this.progressPercentage,
    required this.currentBmi,
    required this.bmiStatus,
    required this.currentStreak,
    required this.history,
  });

  factory ProgressOverviewResponse.fromJson(Map<String, dynamic> json) {
    return ProgressOverviewResponse(
      currentWeight: (json['currentWeight'] as num).toDouble(),
      startWeight: (json['startWeight'] as num).toDouble(),
      targetWeight: (json['targetWeight'] as num).toDouble(),
      weightLost: (json['weightLost'] as num).toDouble(),
      remainingWeight: (json['remainingWeight'] as num).toDouble(),
      progressPercentage: (json['progressPercentage'] as num).toDouble(),
      currentBmi: (json['currentBmi'] as num).toDouble(),
      bmiStatus: json['bmiStatus'] ?? "",
      currentStreak: json['currentStreak'] ?? 0,
      history: (json['history'] as List)
          .map((e) => WeightRecordDto.fromJson(e))
          .toList(),
    );
  }
}
