import 'package:gobek_gone/features/exercise/data/models/exercise_model.dart';

class WorkoutPlan {
  int? id;
  String? planName;
  String? goal;
  String? difficulty;
  List<WorkoutDay>? days;

  WorkoutPlan({this.id, this.planName, this.goal, this.difficulty, this.days});

  WorkoutPlan.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? json['Id'];
    planName = json['planName'] ?? json['PlanName'];
    goal = json['goal'] ?? json['Goal'];
    difficulty = json['difficulty'] ?? json['Difficulty'];
    final daysData = json['days'] ?? json['Days'];
    if (daysData != null) {
      days = <WorkoutDay>[];
      daysData.forEach((v) {
        days!.add(WorkoutDay.fromJson(v));
      });
    }
  }
}

class WorkoutDay {
  int? id;
  String? dayName;
  String? focusArea;
  List<WorkoutExercise>? exercises;

  WorkoutDay({this.id, this.dayName, this.focusArea, this.exercises});

  WorkoutDay.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? json['Id'];
    dayName = json['dayName'] ?? json['DayName'];
    focusArea = json['focusArea'] ?? json['FocusArea'];
    final exData = json['exercises'] ?? json['Exercises'];
    if (exData != null) {
      exercises = <WorkoutExercise>[];
      exData.forEach((v) {
        exercises!.add(WorkoutExercise.fromJson(v));
      });
    }
  }
}

class WorkoutExercise {
  int? id;
  int? exerciseId;
  String? sets;
  String? reps;
  String? notes;
  Exercise? exercise;

  WorkoutExercise({this.id, this.exerciseId, this.sets, this.reps, this.notes, this.exercise});

  WorkoutExercise.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? json['Id'];
    exerciseId = json['exerciseId'] ?? json['ExerciseId'];
    sets = json['sets']?.toString() ?? json['Sets']?.toString();
    reps = json['reps']?.toString() ?? json['Reps']?.toString();
    notes = json['notes'] ?? json['Notes'];
    final exData = json['exercise'] ?? json['Exercise'];
    exercise = exData != null ? Exercise.fromJson(exData) : null;
  }
}
