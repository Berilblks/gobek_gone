import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/models/bmi_response.dart';
import '../data/models/createbmi_request.dart';
import '../data/services/bmi_service.dart';

// Events
abstract class BmiEvent extends Equatable {
  const BmiEvent();
  @override
  List<Object> get props => [];
}

class CalculateBmiRequested extends BmiEvent {
  final double height;
  final double weight;
  final int age;
  final String gender;

  const CalculateBmiRequested({
    required this.height,
    required this.weight,
    required this.age,
    required this.gender,
  });

  @override
  List<Object> get props => [height, weight, age, gender];
}

class LoadBmiHistoryRequested extends BmiEvent {}

// States
abstract class BmiState extends Equatable {
  const BmiState();
  @override
  List<Object?> get props => [];
}

class BmiInitial extends BmiState {}

class BmiLoading extends BmiState {}

class BmiSuccess extends BmiState {
  final BmiResponse? latestBmi;
  final List<BmiResponse> history;

  const BmiSuccess({this.latestBmi, this.history = const []});

  @override
  List<Object?> get props => [latestBmi, history];
}

class BmiFailure extends BmiState {
  final String error;
  const BmiFailure({required this.error});
  @override
  List<Object> get props => [error];
}

// Bloc
class BmiBloc extends Bloc<BmiEvent, BmiState> {
  final BmiService bmiService;

  BmiBloc({required this.bmiService}) : super(BmiInitial()) {
    on<CalculateBmiRequested>(_onCalculateBmiRequested);
    on<LoadBmiHistoryRequested>(_onLoadBmiHistoryRequested);
  }

  Future<void> _onCalculateBmiRequested(CalculateBmiRequested event, Emitter<BmiState> emit) async {
    emit(BmiLoading());
    try {
      final result = await bmiService.calculateAndSave(CreateBmiRequest(
        height: event.height,
        weight: event.weight,
        age: event.age,
        gender: event.gender,
      ));
      
      // After calc, we might want to refresh history too, or just show result
      emit(BmiSuccess(latestBmi: result));
    } catch (e) {
      emit(BmiFailure(error: e.toString()));
    }
  }

  Future<void> _onLoadBmiHistoryRequested(LoadBmiHistoryRequested event, Emitter<BmiState> emit) async {
    emit(BmiLoading());
    try {
      final history = await bmiService.getHistory();
      final latest = history.isNotEmpty ? history.first : null; // Assuming API returns sorted or we sort
      emit(BmiSuccess(latestBmi: latest, history: history));
    } catch (e) {
      emit(BmiFailure(error: e.toString()));
    }
  }
}
