class DietStatus {
  final String status;
  final int daysLeft;

  DietStatus({required this.status, required this.daysLeft});

  factory DietStatus.fromJson(Map<String, dynamic> json) {
    return DietStatus(
      status: json['status'] ?? "Active",
      daysLeft: json['daysLeft'] ?? 0,
    );
  }
}
