class Exercise {
  final int id;
  final String name;
  final String imageUrl; // Egzersiz GIF/Resim linki
  final int exerciseLevel; // 0, 1, 2
  final int bodyPart; // 0, 1, 2, 3, 4
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
      id: json['id'] ?? 0,
      name: json['name'] ?? "",
      imageUrl: json['imageUrl'] ?? "",
      exerciseLevel: json['exerciseLevel'] ?? 0,
      bodyPart: json['bodyPart'] ?? 0,
      description: json['description'] ?? "",
      detail: json['detail'] ?? "",
      isHome: json['isHome'] ?? false,
    );
  }
}
