import 'package:flutter/material.dart';
import '../../../../core/network/api_client.dart';
import '../models/workout_plan_model.dart';

class WorkoutService {
  final ApiClient apiClient;

  WorkoutService({required this.apiClient});

  Future<WorkoutPlan?> getUserWorkoutPlan() async {
    try {
      final response = await apiClient.dio.get('/AIChat/GetUserWorkoutPlan');
      
      debugPrint("Workout Plan API Response: ${response.data}");

      if (response.data != null &&
          response.data['success'] == true && 
          response.data['data'] != null) {
        return WorkoutPlan.fromJson(response.data['data']);
      }
      
      debugPrint("Workout Plan API returned success=false or null data.");
      return null;
    } catch (e) {
      debugPrint("Error fetching workout plan: $e");
      return null;
    }
  }
}
