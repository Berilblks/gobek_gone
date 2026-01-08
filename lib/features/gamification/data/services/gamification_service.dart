import 'package:gobek_gone/core/network/api_client.dart';
import '../models/level_progress_response.dart';

class GamificationService {
  final ApiClient _apiClient;

  GamificationService(this._apiClient);

  Future<LevelProgressResponse?> getLevelProgress() async {
    try {
      print("GAMIFICATION: Fetching level progress...");
      final response = await _apiClient.dio.get('/Gamification/Progress');
      print("GAMIFICATION RESPONSE: ${response.data}");

      if (response.data is Map<String, dynamic> && response.data.containsKey('data')) {
          return LevelProgressResponse.fromJson(response.data['data']);
      } else if (response.data is Map<String, dynamic>) {
          return LevelProgressResponse.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print("Gamification error: $e");
      return null;
    }
  }
}
