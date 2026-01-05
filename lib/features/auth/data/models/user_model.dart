class User {
  final int id;
  final String fullname;
  final String username;
  final String email;
  final String gender;
  final int birthDay;
  final int birthMonth;
  final int birthYear;
  final double height;
  final double weight;
  final double targetWeight;

  final String? profilePhoto;

  User({
    required this.id,
    required this.fullname,
    required this.username,
    required this.email,
    required this.gender,
    required this.birthDay,
    required this.birthMonth,
    required this.birthYear,
    required this.height,
    required this.weight,
    required this.targetWeight,
    this.profilePhoto,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Handle BirthDate parsing if present
    int d = 0, m = 0, y = 0;
    if (json['birthDate'] != null) {
      try {
        DateTime date = DateTime.parse(json['birthDate']);
        d = date.day;
        m = date.month;
        y = date.year;
      } catch (e) {
        print("Error parsing birthDate: $e");
      }
    } else if (json['BirthDate'] != null) {
       try {
        DateTime date = DateTime.parse(json['BirthDate']);
        d = date.day;
        m = date.month;
        y = date.year;
      } catch (e) {
        print("Error parsing BirthDate: $e");
      }
    } else {
      // Fallback if separate fields are sent (unlikely based on plan but good for safety)
      d = json['birthDay'] ?? 0;
      m = json['birthMonth'] ?? 0;
      y = json['birthYear'] ?? 0;
    }

    return User(
      id: json['id'] ?? json['Id'] ?? 0,
      fullname: json['fullname'] ?? json['FullName'] ?? json['fullName'] ?? '',
      username: json['username'] ?? json['Username'] ?? '',
      email: json['email'] ?? json['Email'] ?? '',
      gender: json['gender'] ?? json['Gender'] ?? '',
      birthDay: d,
      birthMonth: m,
      birthYear: y,
      height: (json['height'] ?? json['Height'] ?? 0.0).toDouble(),
      weight: (json['weight'] ?? json['Weight'] ?? 0.0).toDouble(),
      targetWeight: (json['targetWeight'] ?? json['TargetWeight'] ?? 0.0).toDouble(),
      profilePhoto: json['profilePhoto'] ?? json['ProfilePhoto'],
    );
  }
}
