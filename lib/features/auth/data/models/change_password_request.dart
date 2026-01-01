class ChangePasswordRequest {
  final String email;
  final String oldPassword;
  final String newPassword;

  ChangePasswordRequest({
    required this.email,
    required this.oldPassword,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'oldPassword': oldPassword,
      'newPassword': newPassword,
    };
  }
}
