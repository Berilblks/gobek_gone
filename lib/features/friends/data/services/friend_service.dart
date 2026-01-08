import 'package:gobek_gone/core/network/api_client.dart';
import '../models/friend_response.dart';

class FriendService {
  final ApiClient _apiClient;

  FriendService(this._apiClient);

  Future<List<FriendResponse>> searchUsers(String query) async {
    try {
      print("STARTING SEARCH REQUEST for query: '$query'");
      final response = await _apiClient.dio.get('/Friend/Search', queryParameters: {'q': query});
      print("FRIEND SEARCH RAW: ${response.data}");
      if (response.data['success']) {
        final list = response.data['data'] as List;
        print("FRIEND LIST RAW SIZE: ${list.length}");
        return list
            .map((e) {
              try {
                return FriendResponse.fromJson(e);
              } catch (parseError) {
                print("PARSING ERROR for item $e: $parseError");
                rethrow;
              }
            })
            .toList();
      }
      return [];
    } catch (e) {
      print("Search error CRIFTICAL: $e");
      return [];
    }
  }

  Future<bool> sendFriendRequest(int friendId) async {
    try {
      final response = await _apiClient.dio.post('/Friend/Request', queryParameters: {'friendId': friendId});
      return response.data['success'] == true;
    } catch (e) {
      print("Send request error: $e");
      return false;
    }
  }

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
