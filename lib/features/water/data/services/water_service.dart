import 'package:gobek_gone/core/network/api_client.dart';

class WaterService {
  final ApiClient _client;

  WaterService(this._client);

  Future<int?> getWaterIntake() async {
    try {
      final response = await _client.dio.get('/Water/Intake');
      if (response.statusCode == 200) {
        return response.data;
      }
    } catch (e) {
      print("WaterService Error (get): $e");
    }
    return null;
  }

  Future<int?> updateWaterIntake(int change) async {
    try {
      final response = await _client.dio.post(
        '/Water/Update',
        data: change,
      );
      if (response.statusCode == 200) {
        // Backend returns the new total count
        return response.data;
      }
    } catch (e) {
      print("WaterService Error (update): $e");
    }
    return null;
  }
}
