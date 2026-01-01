import 'package:dio/dio.dart';
import 'package:gobek_gone/core/network/api_client.dart';
import '../models/bmi_response.dart';
import '../models/createbmi_request.dart';

class BmiService {
  final ApiClient _apiClient;

  BmiService({required ApiClient apiClient}) : _apiClient = apiClient;

  // 1. Hesapla ve Kaydet
  Future<BmiResponse?> calculateAndSave(CreateBmiRequest request) async {
    try {
      final response = await _apiClient.dio.post(
        '/Bmi/calculate',
        data: request.toJson(),
      );
      // Response format check: if data is directly the object or wrapped in 'data'
      // Assuming standard API response, but following user's snippet which does response.data
      return BmiResponse.fromJson(response.data);
    } catch (e) {
      print("BMI Error: $e");
      return null; // Or rethrow
    }
  }

  // 2. Geçmişi Getir
  Future<List<BmiResponse>> getHistory() async {
    try {
      final response = await _apiClient.dio.get(
        '/Bmi/history',
      );
      return (response.data as List).map((x) => BmiResponse.fromJson(x)).toList();
    } catch (e) {
      print("History Error: $e");
      return [];
    }
  }

  // 3. Streak (Seri) Bilgisi
  Future<int> getStreak() async {
    try {
      final response = await _apiClient.dio.get(
        '/Bmi/streak',
      );
      return response.data['streakCount'];
    } catch (e) {
      print("Streak Error: $e");
      return 0;
    }
  }
}
