class UpdateProfileRequest {
  final String fullname;
  final String username;
  final int birthDay;
  final int birthMonth;
  final int birthYear;
  final double height;
  final double weight;
  final String gender;
  final String? profilePhoto;

  UpdateProfileRequest({
    required this.fullname,
    required this.username,
    required this.birthDay,
    required this.birthMonth,
    required this.birthYear,
    required this.height,
    required this.weight,
    required this.gender,
    this.profilePhoto,
  });

  Map<String, dynamic> toJson() {
    return {
      'FullName': fullname,
      'Username': username,
      'BirthDay': birthDay,
      'BirthMonth': birthMonth,
      'BirthYear': birthYear,
      'Height': height,
      'Weight': weight,
      'Gender': gender,
      'ProfilePhoto': profilePhoto,
    };
  }
}
