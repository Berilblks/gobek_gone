import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/services/workout_service.dart';
import '../data/models/workout_plan_model.dart';

// --- Events ---
abstract class WorkoutEvent extends Equatable {
  const WorkoutEvent();

  @override
  List<Object?> get props => [];
}

class LoadWorkoutPlan extends WorkoutEvent {
  final bool forceRefresh;
  final WorkoutPlan? initialPlan; // For passing data from AI directly

  const LoadWorkoutPlan({this.forceRefresh = false, this.initialPlan});
  
  @override
  List<Object?> get props => [forceRefresh, initialPlan];
}

// --- States ---
abstract class WorkoutState extends Equatable {
  const WorkoutState();
  
  @override
  List<Object?> get props => [];
}

class WorkoutInitial extends WorkoutState {}

class WorkoutLoading extends WorkoutState {}

class WorkoutLoaded extends WorkoutState {
  final WorkoutPlan plan;
  
  const WorkoutLoaded(this.plan);
  
  @override
  List<Object?> get props => [plan];
}

class WorkoutEmpty extends WorkoutState {}

class WorkoutError extends WorkoutState {
  final String message;
  
  const WorkoutError(this.message);
  
  @override
  List<Object?> get props => [message];
}

// --- Bloc ---
class WorkoutBloc extends Bloc<WorkoutEvent, WorkoutState> {
  final WorkoutService _workoutService;

  WorkoutBloc({required WorkoutService workoutService}) 
    : _workoutService = workoutService,
      super(WorkoutInitial()) {
    
    on<LoadWorkoutPlan>(_onLoadWorkoutPlan);
  }

  Future<void> _onLoadWorkoutPlan(LoadWorkoutPlan event, Emitter<WorkoutState> emit) async {
    // If initial plan is provided, use it immediately
    if (event.initialPlan != null) {
      emit(WorkoutLoaded(event.initialPlan!));
      // Optionally continue to refresh in background, but for now we trust the AI output 
      // or we can silently update. UI logic usually prefers showing data first.
      return; 
    }

    emit(WorkoutLoading());

    try {
      final plan = await _workoutService.getUserWorkoutPlan();
      
      if (plan != null) {
        emit(WorkoutLoaded(plan));
      } else {
        emit(WorkoutEmpty());
      }
    } catch (e) {
      emit(WorkoutError("Failed to load workout plan: ${e.toString()}"));
    }
  }
}
