class AIChatResponse {
  final String reply;

  AIChatResponse({required this.reply});

  factory AIChatResponse.fromJson(Map<String, dynamic> json) {
    return AIChatResponse(
      reply: json['reply'] ?? "",
    );
  }
}
