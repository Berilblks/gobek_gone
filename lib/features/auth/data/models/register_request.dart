class RegisterRequest {
  final String name;
  final String surname;
  final String username;
  final String email;
  final String password;
  // Add other fields as needed

  RegisterRequest({required this.name, required this.surname, required this.username, required this.email, required this.password});

  Map<String, dynamic> toJson() {
    return {
      'name' : name,
      'surname' : surname,
      'username': username,
      'email': email,
      'password': password,
    };
  }
}