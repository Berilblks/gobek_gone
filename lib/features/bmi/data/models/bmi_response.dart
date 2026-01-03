import 'bmi_status.dart';

class BmiResponse {
  final double bmiResult;
  final BmiStatus status;
  final String statusDescription;
  final DateTime calculationDate;

  BmiResponse({required this.bmiResult, required this.status, required this.statusDescription, required this.calculationDate});

  factory BmiResponse.fromJson(Map<String, dynamic> json) {
    double bmi = (json['bmiResult'] as num).toDouble();
    
    // Calculate status locally to ensure persistence
    BmiStatus derivedStatus;
    if (bmi < 18.5) {
      derivedStatus = BmiStatus.underweight;
    } else if (bmi < 25.0) {
      derivedStatus = BmiStatus.normalWeight;
    } else if (bmi < 30.0) {
      derivedStatus = BmiStatus.overweight;
    } else {
      derivedStatus = BmiStatus.obese;
    }

    return BmiResponse(
      bmiResult: bmi,
      status: derivedStatus,
      statusDescription: json['statusDescription'] ?? '',
      calculationDate: DateTime.parse(json['calculationDate']),
    );
  }
}