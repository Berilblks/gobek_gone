import 'package:gobek_gone/features/exercise/data/models/exercise_model.dart';

class WorkoutPlan {
  int? id;
  String? planName;
  String? goal;
  String? difficulty;
  List<WorkoutDay>? days;

  WorkoutPlan({this.id, this.planName, this.goal, this.difficulty, this.days});

  WorkoutPlan.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    planName = json['planName'];
    goal = json['goal'];
    difficulty = json['difficulty'];
    if (json['days'] != null) {
      days = <WorkoutDay>[];
      json['days'].forEach((v) {
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
    id = json['id'];
    dayName = json['dayName'];
    focusArea = json['focusArea'];
    if (json['exercises'] != null) {
      exercises = <WorkoutExercise>[];
      json['exercises'].forEach((v) {
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
    id = json['id'];
    exerciseId = json['exerciseId'];
    sets = json['sets'];
    reps = json['reps'];
    notes = json['notes'];
    exercise = json['exercise'] != null ? Exercise.fromJson(json['exercise']) : null;
  }
}
