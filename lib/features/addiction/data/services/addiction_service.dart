import 'package:gobek_gone/core/network/api_client.dart';
import '../models/Addaddiction_request.dart';
import '../models/Addictioncounter_response.dart';
import '../models/Addictiontype.dart';
import '../models/Relapse_request.dart';

class AddictionService {
  final ApiClient _apiClient;

  AddictionService({required ApiClient apiClient}) : _apiClient = apiClient;

  // Check if user has an active addiction record
  Future<bool> checkDailyStatus() async {
    try {
      final response = await _apiClient.dio.get('/Addiction/CheckDailyStatus');
      
      if (response.data == null) return false;

      // Case 1: Direct boolean response
      if (response.data is bool) return response.data;

      // Case 2: Wrapped response (e.g. { "success": true, "data": ... })
      if (response.data is Map) {
          final data = response.data;
          
          // If explicit success flag is false, then formatted response says "fail" or "no data"
          if (data.containsKey('success') && data['success'] == false) return false;

          // Check 'data' field specifically
          if (data.containsKey('data')) {
              final innerData = data['data'];
              if (innerData is bool) return innerData;
              // If data is an object (Map) and not null, it means record exists
              if (innerData != null) return true;
              return false;
          }
          
          // If no 'data' field but 'success' is true or missing, and it's a Map, describe it as Found
          // This covers cases where the user object itself is returned directly
          return true;
      }
      return false; 
    } catch (e) {
      print("CheckDailyStatus Error: $e");
      return false;
    }
  }

  // Get current counter details (Returns a list to support multiple addictions)
  Future<List<AddictionCounterResponse>> getCounter() async {
    try {
      final response = await _apiClient.dio.get('/Addiction/Counter');
      
      if (response.data == null) return [];

      // Helper to parse a single item
      AddictionCounterResponse? parseItem(dynamic item) {
          if (item == null) return null;
          return AddictionCounterResponse.fromJson(item);
      }

      // Check if wrapped in "data"
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

  // Add (or update) addiction
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

  // Report Relapse (Update Quit Date)
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
