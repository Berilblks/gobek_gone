class BadgeModel {
  final String id;
  final String name;
  final String description;
  final String iconPath;
  final bool isEarned;
  final DateTime? earnedDate;

  BadgeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.iconPath,
    this.isEarned = true, 
    this.earnedDate,
  });

  factory BadgeModel.fromJson(Map<String, dynamic> json) {
    return BadgeModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      // Backend calls it 'icon', map it to iconPath
      iconPath: json['icon'] ?? (json['iconPath'] ?? '🏅'), 
      isEarned: json['isEarned'] ?? (json['completed'] ?? false),
      earnedDate: json['earnedDate'] != null ? DateTime.tryParse(json['earnedDate']) : null,
    );
  }
}
