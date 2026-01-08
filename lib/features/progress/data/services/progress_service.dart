import 'package:gobek_gone/core/network/api_client.dart';
import '../models/progress_overview_response.dart';

class ProgressService {
  final ApiClient _apiClient;

  ProgressService(this._apiClient);

  Future<ProgressOverviewResponse?> getProgressOverview() async {
    try {
      final response = await _apiClient.dio.get('/Progress/Overview');
      
      print("PROGRESS OVERVIEW RAW: ${response.data}");

      if (response.data != null && response.data['success'] == true) {
        return ProgressOverviewResponse.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      print("Progress service error: $e");
      return null;
    }
  }
}
