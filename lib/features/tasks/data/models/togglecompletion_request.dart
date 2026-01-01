class ToggleCompletionRequest {
  final int taskId;
  final bool isCompleted;

  ToggleCompletionRequest({required this.taskId, required this.isCompleted});

  Map<String, dynamic> toJson() {
    return {
      'taskId': taskId,
      'isCompleted': isCompleted,
    };
  }
}