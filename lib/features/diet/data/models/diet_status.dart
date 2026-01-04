class DietStatus {
  final String status; // "WeighInRequired", "Active"
  final int daysLeft; // Days until next weigh-in

  DietStatus({required this.status, required this.daysLeft});

  factory DietStatus.fromJson(Map<String, dynamic> json) {
    return DietStatus(
      status: json['status'] ?? "Active",
      daysLeft: json['daysLeft'] ?? 0,
    );
  }
}
