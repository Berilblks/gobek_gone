import '../../../../core/network/api_client.dart';
import '../../../../core/storage/token_storage.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/register_request.dart';
import '../models/register_response.dart';
import '../models/forgot_password_request.dart';
import '../models/reset_password_request.dart';

import '../models/user_model.dart';
import '../models/update_profile_request.dart';
import '../models/change_password_request.dart';

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
      print("RAW LOGIN RESPONSE: ${response.data}"); // DEBUG: See actual backend response
      
      // Backend returns BaseResponse<LoginResponse> structure:
      // { "success": true, "data": { "token": "..." }, "error": null }
      
      Map<String, dynamic> responseData;
      if (response.data is Map<String, dynamic> && response.data.containsKey('data')) {
           responseData = response.data['data'];
      } else {
           responseData = response.data; // Fallback for older structure
      }

      final loginResponse = LoginResponse.fromJson(responseData);
      
      // Check for API-returned errors
      if (loginResponse.error != null && loginResponse.error!.isNotEmpty) {
        throw Exception("${loginResponse.error} (Code: ${loginResponse.errorCode})");
      }

      // Save token automatically on success
      print("Login Response Token: ${loginResponse.token}"); // DEBUG
      if (loginResponse.token.isNotEmpty) {
        await TokenStorage.saveToken(loginResponse.token);
        print("Token saved to storage");
      } else {
        print("WARNING: Login response token is empty!");
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

  Future<void> forgotPassword(ForgotPasswordRequest request) async {
    try {
       await _apiClient.dio.post(
        '/Auth/SendVerificationCode', 
        data: request.toJson(),
      );
      // Assuming success if no error is thrown
    } catch (e) {
      rethrow;
    }
  }

  Future<void> resetPassword(ResetPasswordRequest request) async {
    try {
      await _apiClient.dio.post(
        '/Auth/ResetPassword', 
        data: request.toJson(),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<User> getUserInfo() async {
    try {
      final response = await _apiClient.dio.get(
        '/Auth/Profile', 
      );
      
      // Check structure
      Map<String, dynamic> userData;
      if (response.data is Map<String, dynamic> && response.data.containsKey('data')) {
           userData = response.data['data'];
      } else {
           userData = response.data;
      }

      return User.fromJson(userData);
    } catch (e) {
      rethrow;
    }
  }

  Future<User> updateProfile(UpdateProfileRequest request) async {
    try {
      final response = await _apiClient.dio.put(
        '/Auth/UpdateProfile', 
        data: request.toJson(),
      );
      
      // Expected response: The updated User object
      Map<String, dynamic> userData;
      if (response.data is Map<String, dynamic> && response.data.containsKey('data')) {
           userData = response.data['data'];
      } else {
           userData = response.data;
      }

      return User.fromJson(userData);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> changePassword(ChangePasswordRequest request) async {
    try {
      await _apiClient.dio.post(
        '/Auth/ChangePassword',
        data: request.toJson(),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> requestDeleteAccount() async {
    try {
      await _apiClient.dio.post('/Auth/RequestDeleteAccount');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> confirmDeleteAccount(String code) async {
    try {
      await _apiClient.dio.delete(
        '/Auth/ConfirmDeleteAccount',
        data: {'code': code},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateUserWeight(double newWeight) async {
    try {
      await _apiClient.dio.post(
        '/Auth/UpdateWeight', // Matched with Backend
        data: {'weight': newWeight},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await TokenStorage.deleteToken();
  }
}
