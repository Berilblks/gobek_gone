class Exercise {
  final int id;
  final String name;
  final String imageUrl;
  final int exerciseLevel;
  final int bodyPart;
  final String description;
  final String detail;
  final bool isHome;

  Exercise({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.exerciseLevel,
    required this.bodyPart,
    required this.description,
    required this.detail,
    required this.isHome,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] ?? json['Id'] ?? 0,
      name: json['name'] ?? json['Name'] ?? "",
      imageUrl: json['imageUrl'] ?? json['ImageUrl'] ?? "",
      exerciseLevel: json['exerciseLevel'] ?? json['ExerciseLevel'] ?? 0,
      bodyPart: json['bodyPart'] ?? json['BodyPart'] ?? 0,
      description: json['description'] ?? json['Description'] ?? "",
      detail: json['detail'] ?? json['Detail'] ?? "",
      isHome: json['isHome'] ?? json['IsHome'] ?? false,
    );
  }
}
