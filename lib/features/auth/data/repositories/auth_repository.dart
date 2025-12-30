import '../../../../core/network/api_client.dart';
import '../../../../core/storage/token_storage.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/register_request.dart';
import '../models/register_response.dart';

class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await _apiClient.dio.post(
        '/Auth/Login', // Adjust endpoint
        data: request.toJson(),
      );
      
      // Assuming response.data is the JSON object
      final loginResponse = LoginResponse.fromJson(response.data);
      
      // Check for API-returned errors
      if (loginResponse.error != null && loginResponse.error!.isNotEmpty) {
        throw Exception("${loginResponse.error} (Code: ${loginResponse.errorCode})");
      }

      // Save token automatically on success
      if (loginResponse.token.isNotEmpty) {
        await TokenStorage.saveToken(loginResponse.token);
      }
      
      return loginResponse;
    } catch (e) {
      rethrow;
    }
  }

  Future<RegisterResponse> register(RegisterRequest request) async {
    try {
      final response = await _apiClient.dio.post(
        '/Auth/Register', // Adjust endpoint
        data: request.toJson(),
      );
      final registerResponse = RegisterResponse.fromJson(response.data);
      
      if (registerResponse.error != null && registerResponse.error!.isNotEmpty) {
        throw Exception("${registerResponse.error} (Code: ${registerResponse.errorCode})");
      }
      
      return registerResponse;
    } catch (e) {
      // You might want to parse error messages from API here
      rethrow;
    }
  }

  Future<void> logout() async {
    await TokenStorage.deleteToken();
  }
}
