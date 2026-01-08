import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/services/exercise_service.dart';
import '../data/models/exercise_model.dart';

// --- Events ---
abstract class ExerciseEvent extends Equatable {
  const ExerciseEvent();
  @override
  List<Object?> get props => [];
}

class LoadExercises extends ExerciseEvent {
  final bool isHome;
  final int? bodyPart;
  final int? level;

  const LoadExercises({
    required this.isHome,
    this.bodyPart,
    this.level,
  });

  @override
  List<Object?> get props => [isHome, bodyPart, level];
}

// --- States ---
abstract class ExerciseState extends Equatable {
  const ExerciseState();
  @override
  List<Object?> get props => [];
}

class ExerciseInitial extends ExerciseState {}

class ExerciseLoading extends ExerciseState {}

class ExerciseLoaded extends ExerciseState {
  final List<Exercise> exercises;

  const ExerciseLoaded(this.exercises);

  @override
  List<Object?> get props => [exercises];
}

class ExerciseError extends ExerciseState {
  final String message;

  const ExerciseError(this.message);

  @override
  List<Object?> get props => [message];
}

// --- Bloc ---
class ExerciseBloc extends Bloc<ExerciseEvent, ExerciseState> {
  final ExerciseService _exerciseService;

  ExerciseBloc({required ExerciseService exerciseService})
      : _exerciseService = exerciseService,
        super(ExerciseInitial()) {
    on<LoadExercises>(_onLoadExercises);
  }

  Future<void> _onLoadExercises(
      LoadExercises event, Emitter<ExerciseState> emit) async {
    emit(ExerciseLoading());
    try {
      final fetched = await _exerciseService.getExercises(
        isHome: event.isHome,
        bodyPart: event.bodyPart,
        exerciseLevel: event.level,
      );

      // Filter locally for exact home match if API doesn't do strict check
      final filtered = fetched.where((e) {
         if (event.isHome) {
           return e.isHome == true;
         } else {
           return e.isHome == false;
         }
      }).toList();

      emit(ExerciseLoaded(filtered));
    } catch (e) {
      emit(ExerciseError(e.toString()));
    }
  }
}
