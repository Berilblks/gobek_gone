class LevelProgressResponse {
  final int level;
  final int currentXp;
  final int xpForNextLevel;
  final double progressPercentage;

  LevelProgressResponse({
    required this.level,
    required this.currentXp,
    required this.xpForNextLevel,
    required this.progressPercentage,
  });

  factory LevelProgressResponse.fromJson(Map<String, dynamic> json) {
    return LevelProgressResponse(
      level: json['level'] ?? 1,
      currentXp: json['currentXp'] ?? 0,
      xpForNextLevel: json['xpForNextLevel'] ?? 100,
      progressPercentage: (json['progressPercentage'] as num).toDouble(),
    );
  }
}
