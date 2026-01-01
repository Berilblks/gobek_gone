import 'package:gobek_gone/core/network/api_client.dart';
import '../models/dailytask_response.dart';
import '../models/togglecompletion_request.dart';

class TaskService {
  final ApiClient _apiClient;

  TaskService({required ApiClient apiClient}) : _apiClient = apiClient;

  // 1. Get Today's Tasks
  Future<List<DailyTaskResponse>> getTodayTasks() async {
    try {
      final response = await _apiClient.dio.get('/Tasks/today');
      
      // Check for success flag in BaseResponse
      if (response.data is Map<String, dynamic> && response.data['success'] == true) {
         if (response.data['data'] != null) {
           return (response.data['data'] as List)
              .map((x) => DailyTaskResponse.fromJson(x))
              .toList();
         }
      }
      return [];
    } catch (e) {
      // ApiClient handles some errors, but we catch/rethrow or log here
      print("GetTasks Error: $e");
      // If endpoint returns valid error response, we might want to throw it or return empty
      // For now, return empty list on error or throw? 
      // Bloc should handle empty or error. Rethrowing lets Bloc know something went wrong.
      rethrow;
    }
  }

  // 2. Toggle Task Completion
  Future<bool> toggleCompletion(int taskId, bool isCompleted) async {
    try {
      final request = ToggleCompletionRequest(taskId: taskId, isCompleted: isCompleted);
      
      final response = await _apiClient.dio.post(
        '/Tasks/toggle-completion',
        data: request.toJson(),
      );
      
      return response.data['success'] == true;
    } catch (e) {
      print("Toggle Error: $e");
      return false;
    }
  }
}
