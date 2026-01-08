import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/models/dailytask_response.dart';
import '../data/services/task_service.dart';

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
    final currentState = state;
    if (currentState is TasksLoaded) {
      final updatedTasks = currentState.tasks.map((task) {
        if (task.id == event.taskId) {
           return task.copyWith(isCompleted: event.isCompleted);
        }
        return task;
      }).toList();
      
      emit(TasksLoaded(tasks: updatedTasks));

      try {
        final success = await _taskService.toggleCompletion(event.taskId, event.isCompleted);
        if (!success) {
           final revertedTasks = currentState.tasks.map((task) {
             if (task.id == event.taskId) {
                return task.copyWith(isCompleted: !event.isCompleted);
             }
             return task;
           }).toList();
           emit(TasksLoaded(tasks: revertedTasks));
        }
      } catch (e) {
         final revertedTasks = currentState.tasks.map((task) {
             if (task.id == event.taskId) {
                return task.copyWith(isCompleted: !event.isCompleted);
             }
             return task;
           }).toList();
           emit(TasksLoaded(tasks: revertedTasks));
      }
    }
  }
}
