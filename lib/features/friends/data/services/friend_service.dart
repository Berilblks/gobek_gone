import 'package:dio/dio.dart';
import 'package:gobek_gone/core/network/api_client.dart';
import '../models/friend_response.dart';

class FriendService {
  final ApiClient _apiClient;

  FriendService(this._apiClient);

  // Search Users
  Future<List<FriendResponse>> searchUsers(String query) async {
    try {
      print("STARTING SEARCH REQUEST for query: '$query'"); // DEBUG START
      final response = await _apiClient.dio.get('/Friend/Search', queryParameters: {'q': query});
      print("FRIEND SEARCH RAW: ${response.data}"); // DEBUG 1
      if (response.data['success']) {
        final list = response.data['data'] as List;
        print("FRIEND LIST RAW SIZE: ${list.length}"); // DEBUG 2
        return list
            .map((e) {
              try {
                return FriendResponse.fromJson(e);
              } catch (parseError) {
                print("PARSING ERROR for item $e: $parseError"); // DEBUG 3
                rethrow;
              }
            })
            .toList();
      }
      return [];
    } catch (e) {
      print("Search error CRIFTICAL: $e"); // DEBUG 4
      return [];
    }
  }

  // Send Friend Request
  Future<bool> sendFriendRequest(int friendId) async {
    try {
      final response = await _apiClient.dio.post('/Friend/Request', queryParameters: {'friendId': friendId});
      return response.data['success'] == true;
    } catch (e) {
      print("Send request error: $e");
      return false;
    }
  }

  // Accept Friend Request
  Future<bool> acceptRequest(int senderId) async {
    try {
      final response = await _apiClient.dio.post('/Friend/Accept', queryParameters: {'senderId': senderId});
      return response.data['success'] == true;
    } catch (e) {
      print("Accept request error: $e");
      return false;
    }
  }
}
