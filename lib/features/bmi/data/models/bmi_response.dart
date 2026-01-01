import 'bmi_status.dart';

class BmiResponse {
  final double bmiResult;
  final BmiStatus status;
  final String statusDescription;
  final DateTime calculationDate;

  BmiResponse({required this.bmiResult, required this.status, required this.statusDescription, required this.calculationDate});

  factory BmiResponse.fromJson(Map<String, dynamic> json) {
    return BmiResponse(
      bmiResult: (json['bmiResult'] as num).toDouble(),
      status: BmiStatus.fromValue(json['status']),
      statusDescription: json['statusDescription'],
      calculationDate: DateTime.parse(json['calculationDate']),
    );
  }
}