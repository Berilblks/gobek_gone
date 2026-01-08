import 'package:gobek_gone/core/network/api_client.dart';
import '../models/exercise_model.dart';

class ExerciseService {
  final ApiClient _apiClient;

  ExerciseService({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<List<Exercise>> getExercises({bool? isHome, int? bodyPart, int? exerciseLevel}) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (isHome != null) queryParams['isHome'] = isHome;
      if (bodyPart != null) queryParams['bodyPart'] = bodyPart;
      if (exerciseLevel != null) queryParams['exerciseLevel'] = exerciseLevel;

      final response = await _apiClient.dio.get(
        '/Exercise/GetExercises',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data is Map && response.data.containsKey('data')
            ? response.data['data'] 
            : response.data;

        if (data is List) {
          return data.map((e) => Exercise.fromJson(e)).toList();
        }
      }
      return [];
    } catch (e) {
      print("Error fetching exercises: $e");
      return [];
    }
  }
}
