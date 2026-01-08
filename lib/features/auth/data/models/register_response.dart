class RegisterResponse {
  final bool success;
  final String message;
  final String? error;
  final int? errorCode;

  RegisterResponse({
    required this.success,
    required this.message,
    this.error,
    this.errorCode,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      success: json['success'] ?? true,
      message: json['message'] ?? '',
      error: json['error'],
      errorCode: json['errorCode'],
    );
  }
}