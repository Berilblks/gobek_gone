import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import '../../core/storage/token_storage.dart';

class ApiClient {
  final Dio _dio;

  ApiClient({required String baseUrl})
      : _dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 120),
          receiveTimeout: const Duration(seconds: 120),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        )) {
    
    // DEVELOPMENT ONLY: Bypass SSL certificate verification for local development
    // Remove this in production!
    (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await TokenStorage.getToken();
          if (token != null) {
            print("Adding Token to Request: $token"); // DEBUG: Check if token exists
            options.headers['Authorization'] = 'Bearer $token';
          } else {
            print("WARNING: No token found in storage!");
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
           print("API RESPONSE [${response.statusCode}] path: ${response.requestOptions.path}"); 
           return handler.next(response);
        },
        onError: (DioException e, handler) {
          print("API ERROR [${e.response?.statusCode}] path: ${e.requestOptions.path} msg: ${e.message}");
          // Handle global errors here (e.g. 401 Unauthorized -> Logout)
          return handler.next(e);
        },
      ),
    );
  }

  Dio get dio => _dio;
}
