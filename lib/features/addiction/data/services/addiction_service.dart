import 'package:gobek_gone/core/network/api_client.dart';
import '../models/Addaddiction_request.dart';
import '../models/Addictioncounter_response.dart';
import '../models/Relapse_request.dart';

class AddictionService {
  final ApiClient _apiClient;

  AddictionService({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<bool> checkDailyStatus() async {
    try {
      final response = await _apiClient.dio.get('/Addiction/CheckDailyStatus');
      
      if (response.data == null) return false;

      if (response.data is bool) return response.data;

      if (response.data is Map) {
          final data = response.data;
          
          if (data.containsKey('success') && data['success'] == false) return false;

          if (data.containsKey('data')) {
              final innerData = data['data'];
              if (innerData is bool) return innerData;
              if (innerData != null) return true;
              return false;
          }
          
          return true;
      }
      return false; 
    } catch (e) {
      print("CheckDailyStatus Error: $e");
      return false;
    }
  }

  Future<List<AddictionCounterResponse>> getCounter() async {
    try {
      final response = await _apiClient.dio.get('/Addiction/Counter');
      
      if (response.data == null) return [];

      AddictionCounterResponse? parseItem(dynamic item) {
          if (item == null) return null;
          return AddictionCounterResponse.fromJson(item);
      }

      dynamic targetData = response.data;
      if (response.data is Map && response.data.containsKey('data')) {
          targetData = response.data['data'];
      }

      if (targetData is List) {
        return targetData.map((e) => parseItem(e)).whereType<AddictionCounterResponse>().toList();
      } else if (targetData is Map) {
        final item = parseItem(targetData);
        return item != null ? [item] : [];
      } else {
          return [];
      }
    } catch (e) {
      print("GetCounter Error: $e");
      return [];
    }
  }

  Future<bool> addAddiction(AddAddictionRequest request) async {
    try {
      final response = await _apiClient.dio.post(
        '/Addiction/Add',
        data: request.toJson(),
      );
      return response.data['success'] == true;
    } catch (e) {
      print("AddAddiction Error: $e");
      rethrow;
    }
  }

  Future<bool> relapse(DateTime newQuitDate) async {
    try {
      final request = RelapseRequest(newQuitDate: newQuitDate);
      final response = await _apiClient.dio.post(
        '/Addiction/QuitDate',
        data: request.toJson(),
      );
      return response.data['success'] == true;
    } catch (e) {
      print("Relapse Error: $e");
      return false;
    }
  }
}
