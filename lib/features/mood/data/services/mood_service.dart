import 'package:gobek_gone/core/network/api_client.dart';
import 'package:flutter/foundation.dart';

class MoodService {
  final ApiClient _client;

  MoodService(this._client);

  Future<String?> getCurrentMood() async {
    try {
      final response = await _client.dio.get('/Mood/Current');
      if (response.statusCode == 200) {
        return response.data;
      }
    } catch (e) {
      debugPrint("MoodService Error (get): $e");
    }
    return null;
  }

  Future<String?> updateMood(String mood) async {
    try {
      final response = await _client.dio.post(
        '/Mood/Update',
        data: "\"$mood\"",
      );
      if (response.statusCode == 200) {
        return response.data;
      }
    } catch (e) {
      debugPrint("MoodService Error (update): $e");
    }
    return null;
  }
}
