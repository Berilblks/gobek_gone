import '../../../../core/network/api_client.dart';
import '../models/diet_status.dart';

class DietPlan {
  final int id;
  final String content;
  final DateTime createdAt;

  DietPlan({required this.id, required this.content, required this.createdAt});

  factory DietPlan.fromJson(Map<String, dynamic> json) {
    return DietPlan(
      id: json['id'] ?? json['Id'] ?? 0,
      content: json['content'] ?? json['Content'] ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : (json['CreatedAt'] != null ? DateTime.parse(json['CreatedAt']) : DateTime.now()),
    );
  }
}

class DietService {
  final ApiClient _apiClient;

  DietService({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<DietPlan?> getLatestDietPlan() async {
    try {
      final response = await _apiClient.dio.get('/AIChat/GetUserDietPlan'); 

      if (response.statusCode == 200 && response.data != null) {
        // Handling standard response wrapper if exists (success: true, data: {...})
        final data = response.data is Map && response.data.containsKey('data') 
            ? response.data['data'] 
            : response.data;
            
        if (data != null) {
          return DietPlan.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      print("Error fetching diet plan: $e");
      return null;
    }
  }
  Future<DietStatus?> checkDietStatus() async {
    try {
      final response = await _apiClient.dio.get('/Diet/CheckStatus'); 
      if (response.statusCode == 200 && response.data != null) {
         final data = response.data is Map && response.data.containsKey('data') 
            ? response.data['data'] 
            : response.data;
         
         if (data != null) {
           return DietStatus.fromJson(data);
         }
      }
      return null;
    } catch (e) {
      print("Error checking diet status: $e");
      return null;
    }
  }
}
