import 'package:dio/dio.dart';
import 'dart:convert';
import '../../../../core/network/api_client.dart';
import '../models/aiChat_request.dart';
import '../models/aiChat_response.dart';

class AiRepository {
  final ApiClient _apiClient;

  AiRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<String> sendMessage(String message) async {
    try {
      final response = await _apiClient.dio.post(
        '/AIChat/Ask',
        data: AIChatRequest(message: message).toJson(),
      );

      // Backend returns BaseResponse<AIChatResponse>
      // { "success": true, "data": { "reply": "..." } }
      if (response.statusCode == 200 && response.data != null) {
        var data = response.data;
        if (data is String) {
          try {
            data = jsonDecode(data);
          } catch (_) {
             // If parsing fails, it's just a raw string
          }
        }

        if (data is Map<String, dynamic>) {
            if (data['success'] == true && data['data'] != null) {
              // Ensure 'data' inside is also a Map
              if (data['data'] is Map<String, dynamic>) {
                 final aiResponse = AIChatResponse.fromJson(data['data']);
                 return aiResponse.reply;
              } else {
                 return data['data'].toString(); // Fallback if data is string/other
              }
            } else {
              throw Exception(data['message'] ?? 'Unknown error from server');
            }
        } else {
            // Unexpected response format (e.g. List)
            throw Exception('Unexpected response format: $data');
        }
      } else {
        throw Exception('Failed to get response from AI');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        var errorData = e.response?.data;
        if (errorData is String) {
            try { errorData = jsonDecode(errorData); } catch(_) {}
        }
        
        if (errorData is Map<String, dynamic>) {
             throw Exception(errorData['message'] ?? 'AI Connection Error (${e.response?.statusCode}): ${e.message}');
        } else {
             // If it's a List or String, just enable toString()
             throw Exception('AI Error (${e.response?.statusCode}): $errorData');
        }
      }
      throw Exception('Network Error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected Error: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getChatHistory() async {
    try {
      final response = await _apiClient.dio.get('/AIChat/History');

      if (response.statusCode == 200 && response.data != null) {
        var data = response.data;
        // Parse if string
        if (data is String) {
           try { data = jsonDecode(data); } catch(_) {}
        }

        if (data is Map<String, dynamic> && data['success'] == true) {
           // Expecting data['data'] to be a List of objects
           final historyList = data['data'];
           if (historyList is List) {
             // Map to a simpler structure or just return raw List<Map>
             return List<Map<String, dynamic>>.from(historyList);
           }
        }
      }
      return [];
    } catch (e) {
      // Silently fail or return empty list on history error to not block the app
      print("Error fetching chat history: $e");
      return [];
    }
  }
}
