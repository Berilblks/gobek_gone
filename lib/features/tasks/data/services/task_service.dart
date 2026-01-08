import 'package:gobek_gone/core/network/api_client.dart';
import '../models/dailytask_response.dart';
import '../models/togglecompletion_request.dart';

class TaskService {
  final ApiClient _apiClient;

  TaskService({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<List<DailyTaskResponse>> getTodayTasks() async {
    try {
      final response = await _apiClient.dio.get('/Tasks/today');
      
      if (response.data is Map<String, dynamic> && response.data['success'] == true) {
         if (response.data['data'] != null) {
           return (response.data['data'] as List)
              .map((x) => DailyTaskResponse.fromJson(x))
              .toList();
         }
      }
      return [];
    } catch (e) {
      print("GetTasks Error: $e");
      rethrow;
    }
  }

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
