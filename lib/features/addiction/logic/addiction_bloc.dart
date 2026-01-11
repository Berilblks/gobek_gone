import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/models/Addaddiction_request.dart';
import '../data/models/Addictioncounter_response.dart';
import '../data/services/addiction_service.dart';

abstract class AddictionEvent extends Equatable {
  const AddictionEvent();
  @override
  List<Object> get props => [];
}

class LoadAddictionStatus extends AddictionEvent {}

class SelectAddictionRequested extends AddictionEvent {
  final AddAddictionRequest request;
  const SelectAddictionRequested(this.request);
  @override
  List<Object> get props => [request];
}

class RelapseRequested extends AddictionEvent {
  final DateTime newQuitDate;
  const RelapseRequested(this.newQuitDate);
  @override
  List<Object> get props => [newQuitDate];
}


abstract class AddictionState extends Equatable {
  const AddictionState();
  @override
  List<Object> get props => [];
}

class AddictionInitial extends AddictionState {}
class AddictionLoading extends AddictionState {}

class AddictionNone extends AddictionState {
}

class AddictionActive extends AddictionState {
  final List<AddictionCounterResponse> counters;
  const AddictionActive(this.counters);
  @override
  List<Object> get props => [counters];
}

class AddictionFailure extends AddictionState {
  final String error;
  const AddictionFailure(this.error);
  @override
  List<Object> get props => [error];
}



class AddictionBloc extends Bloc<AddictionEvent, AddictionState> {
  final AddictionService _service;

  AddictionBloc({required AddictionService service}) : _service = service, super(AddictionInitial()) {
    on<LoadAddictionStatus>(_onLoadAddictionStatus);
    on<SelectAddictionRequested>(_onSelectAddictionRequested);
    on<RelapseRequested>(_onRelapseRequested);
  }

  Future<void> _onLoadAddictionStatus(LoadAddictionStatus event, Emitter<AddictionState> emit) async {
    emit(AddictionLoading());
    try {
      // Direct check: Try to fetch counters. If they exist, we are active.
      final counters = await _service.getCounter();
      
      if (counters.isNotEmpty) {
        emit(AddictionActive(counters));
      } else {
        emit(AddictionNone());
      }
    } catch (e) {
      emit(AddictionFailure("Failed to load status: $e"));
    }
  }

  Future<void> _onSelectAddictionRequested(SelectAddictionRequested event, Emitter<AddictionState> emit) async {
    emit(AddictionLoading());
    try {
      final success = await _service.addAddiction(event.request);
      if (success) {
        add(LoadAddictionStatus());
      } else {
        emit(const AddictionFailure("Failed to save addiction details."));
      }
    } catch (e) {
      emit(AddictionFailure(e.toString()));
    }
  }

  Future<void> _onRelapseRequested(RelapseRequested event, Emitter<AddictionState> emit) async {
    emit(AddictionLoading());
    try {
      final success = await _service.relapse(event.newQuitDate);
      if (success) {
        add(LoadAddictionStatus());
      } else {
         emit(const AddictionFailure("Failed to update quit date."));
         add(LoadAddictionStatus());
      }
    } catch (e) {
      emit(AddictionFailure(e.toString()));
      add(LoadAddictionStatus());
    }
  }
}
