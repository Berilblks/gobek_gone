class RelapseRequest {
  final DateTime newQuitDate;

  RelapseRequest({required this.newQuitDate});

  Map<String, dynamic> toJson() {
    return {
      'newQuitDate': newQuitDate.toIso8601String(),
    };
  }
}