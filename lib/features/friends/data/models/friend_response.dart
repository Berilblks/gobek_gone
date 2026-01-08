class FriendResponse {
  final int id;
  final String name;
  final String? username;
  final String? photoUrl;
  final String? level;
  final int steps;
  final String status;

  FriendResponse({
    required this.id,
    required this.name,
    this.username,
    this.photoUrl,
    this.level,
    required this.steps,
    this.status = "None",
  });

  factory FriendResponse.fromJson(Map<String, dynamic> json) {
    return FriendResponse(
      id: json['id'] ?? json['Id'] ?? 0,
      name: json['FullName'] ?? json['name'] ?? '',
      username: json['Username'] ?? json['username'],
      photoUrl: json['PhotoUrl'] ?? json['photoUrl'],
      level: json['Level'] ?? json['level'],
      steps: json['Steps'] ?? json['steps'] ?? 0,
      status: json['Status'] ?? json['status'] ?? "None",
    );
  }
}
