class RegisterRequest {
  final String fullname;
  final String username;
  final int birthDay;
  final int birthMonth;
  final int birthYear;
  final double height;
  final double weight;
  final String gender;
  final String email;
  final String password;

  RegisterRequest({
    required this.fullname,
    required this.username,
    required this.birthDay,
    required this.birthMonth,
    required this.birthYear,
    required this.height,
    required this.weight,
    required this.gender,
    required this.email,
    required this.password,
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
      'Email': email,
      'Password': password,
    };
  }
}