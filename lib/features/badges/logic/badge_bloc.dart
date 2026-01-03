import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/badge_model.dart';
import '../data/services/badge_service.dart';

// Events
abstract class BadgeEvent {}

class LoadBadges extends BadgeEvent {}

// States
abstract class BadgeState {}

class BadgeInitial extends BadgeState {}

class BadgeLoading extends BadgeState {}

class BadgeLoaded extends BadgeState {
  final List<BadgeModel> badges;
  BadgeLoaded(this.badges);
}

class BadgeError extends BadgeState {
  final String error;
  BadgeError(this.error);
}

// Bloc
class BadgeBloc extends Bloc<BadgeEvent, BadgeState> {
  final BadgeService _service;

  BadgeBloc({required BadgeService service}) 
      : _service = service, 
        super(BadgeInitial()) {
    
    on<LoadBadges>((event, emit) async {
      emit(BadgeLoading());
      try {
        final badges = await _service.getMyBadges();
        emit(BadgeLoaded(badges));
      } catch (e) {
        emit(BadgeError(e.toString()));
      }
    });
  }
}
