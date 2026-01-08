class LoginResponse {
  final String token;
  final String? error;
  final int? errorCode;

  LoginResponse({required this.token, this.error, this.errorCode});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] ?? '',
      error: json['error'],
      errorCode: json['errorCode'],
    );
  }
}