import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/models/dailytask_response.dart';
import '../data/services/task_service.dart';

// Events
abstract class TasksEvent extends Equatable {
  const TasksEvent();
  @override
  List<Object> get props => [];
}

class LoadTodayTasksRequested extends TasksEvent {}

class ToggleTaskCompletionRequested extends TasksEvent {
  final int taskId;
  final bool isCompleted;

  const ToggleTaskCompletionRequested({required this.taskId, required this.isCompleted});

  @override
  List<Object> get props => [taskId, isCompleted];
}

// States
abstract class TasksState extends Equatable {
  const TasksState();
  @override
  List<Object> get props => [];
}

class TasksInitial extends TasksState {}

class TasksLoading extends TasksState {}

class TasksLoaded extends TasksState {
  final List<DailyTaskResponse> tasks;

  const TasksLoaded({required this.tasks});

  @override
  List<Object> get props => [tasks];
}

class TasksFailure extends TasksState {
  final String error;

  const TasksFailure({required this.error});

  @override
  List<Object> get props => [error];
}

// Bloc
class TasksBloc extends Bloc<TasksEvent, TasksState> {
  final TaskService _taskService;

  TasksBloc({required TaskService taskService})
      : _taskService = taskService,
        super(TasksInitial()) {
    on<LoadTodayTasksRequested>(_onLoadTodayTasksRequested);
    on<ToggleTaskCompletionRequested>(_onToggleTaskCompletionRequested);
  }

  Future<void> _onLoadTodayTasksRequested(LoadTodayTasksRequested event, Emitter<TasksState> emit) async {
    emit(TasksLoading());
    try {
      final tasks = await _taskService.getTodayTasks();
      emit(TasksLoaded(tasks: tasks));
    } catch (e) {
      emit(TasksFailure(error: e.toString()));
    }
  }

  Future<void> _onToggleTaskCompletionRequested(ToggleTaskCompletionRequested event, Emitter<TasksState> emit) async {
    // Optimistic Update can be tricky if we don't have current list.
    // If we are in Loaded state, we can update immediately.
    final currentState = state;
    if (currentState is TasksLoaded) {
      // 1. Optimistic Update
      final updatedTasks = currentState.tasks.map((task) {
        if (task.id == event.taskId) {
           return task.copyWith(isCompleted: event.isCompleted);
        }
        return task;
      }).toList();
      
      emit(TasksLoaded(tasks: updatedTasks));

      try {
        // 2. Call API
        final success = await _taskService.toggleCompletion(event.taskId, event.isCompleted);
        if (!success) {
           // Revert if API fail
           final revertedTasks = currentState.tasks.map((task) {
             if (task.id == event.taskId) {
                return task.copyWith(isCompleted: !event.isCompleted);
             }
             return task;
           }).toList();
           emit(TasksLoaded(tasks: revertedTasks));
           // Optionally emit failure
        }
      } catch (e) {
        // Revert on error
         final revertedTasks = currentState.tasks.map((task) {
             if (task.id == event.taskId) {
                return task.copyWith(isCompleted: !event.isCompleted);
             }
             return task;
           }).toList();
           emit(TasksLoaded(tasks: revertedTasks));
           // emit(TasksFailure(error: "Failed to toggle task: $e")); // Maybe snackbar?
      }
    }
  }
}
