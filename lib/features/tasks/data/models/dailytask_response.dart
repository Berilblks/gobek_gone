class DailyTaskResponse {
  final int id;
  final String title;
  final String description;
  final bool isCompleted;

  DailyTaskResponse({
    required this.id,
    required this.title,
    required this.description,
    required this.isCompleted,
  });

  factory DailyTaskResponse.fromJson(Map<String, dynamic> json) {
    return DailyTaskResponse(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  // Adding copyWith for optimistic updates in Bloc
  DailyTaskResponse copyWith({
    int? id,
    String? title,
    String? description,
    bool? isCompleted,
  }) {
    return DailyTaskResponse(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}