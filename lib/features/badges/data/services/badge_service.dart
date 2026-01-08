import '../../../../core/network/api_client.dart';
import '../models/badge_model.dart';

class BadgeService {
  final ApiClient _apiClient;

  BadgeService({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<List<BadgeModel>> getMyBadges() async {
    try {
      print("BadgeService: Fetching from /Badge/GetAll");
      final response = await _apiClient.dio.get('/Badge/GetAll');

      print("BadgeService: Response Status: ${response.statusCode}");
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        print("BadgeService: Raw Data: $data");
        
        List<dynamic>? listData;
        if (data is Map && data.containsKey('data')) {
          listData = data['data'] as List<dynamic>?;
        } else if (data is List) {
          listData = data;
        }

        if (listData != null) {
          return listData.map((e) => BadgeModel.fromJson(e)).toList();
        }
      }
      return [];
    } catch (e) {
      print("Error fetching badges: $e");
      return [];
    }
  }
}
