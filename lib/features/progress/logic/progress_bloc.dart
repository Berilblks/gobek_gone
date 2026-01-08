import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/services/progress_service.dart';
import '../../auth/data/repositories/auth_repository.dart';
import '../data/models/progress_overview_response.dart';

abstract class ProgressEvent extends Equatable {
  const ProgressEvent();
  @override
  List<Object?> get props => [];
}

class LoadProgressOverview extends ProgressEvent {}

class UpdateWeightEvent extends ProgressEvent {
  final double weight;
  const UpdateWeightEvent(this.weight);

  @override
  List<Object?> get props => [weight];
}

abstract class ProgressState extends Equatable {
  const ProgressState();
  @override
  List<Object?> get props => [];
}

class ProgressInitial extends ProgressState {}

class ProgressLoading extends ProgressState {}

class ProgressLoaded extends ProgressState {
  final ProgressOverviewResponse data;
  const ProgressLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

class ProgressError extends ProgressState {
  final String message;
  const ProgressError(this.message);

  @override
  List<Object?> get props => [message];
}

class WeightUpdateSuccess extends ProgressState {
}

class ProgressBloc extends Bloc<ProgressEvent, ProgressState> {
  final ProgressService _progressService;
  final AuthRepository _authRepository;

  ProgressBloc({
    required ProgressService progressService,
    required AuthRepository authRepository,
  }) : _progressService = progressService,
       _authRepository = authRepository,
       super(ProgressInitial()) {
    
    on<LoadProgressOverview>(_onLoadProgress);
    on<UpdateWeightEvent>(_onUpdateWeight);
  }

  Future<void> _onLoadProgress(LoadProgressOverview event, Emitter<ProgressState> emit) async {
    emit(ProgressLoading());
    try {
      final data = await _progressService.getProgressOverview();
      if (data != null) {
        emit(ProgressLoaded(data));
      } else {
         emit(const ProgressError("Failed to load progress data"));
      }
    } catch (e) {
      emit(ProgressError(e.toString()));
    }
  }

  Future<void> _onUpdateWeight(UpdateWeightEvent event, Emitter<ProgressState> emit) async {
    emit(ProgressLoading());
    try {
      await _authRepository.updateUserWeight(event.weight);
      add(LoadProgressOverview());
    } catch (e) {
      emit(ProgressError(e.toString()));
    }
  }
}
