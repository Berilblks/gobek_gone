class AIChatRequest {
  final String message;

  AIChatRequest({required this.message});

  Map<String, dynamic> toJson() => {
    "message": message,
  };
}