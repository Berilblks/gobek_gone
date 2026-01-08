import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/services/gamification_service.dart';
import '../../badges/data/services/badge_service.dart';
import '../../badges/data/models/badge_model.dart'; // Exposed for State use
import '../data/models/level_progress_response.dart'; // Exposed for State use

// --- Events ---
abstract class GamificationEvent extends Equatable {
  const GamificationEvent();
  @override
  List<Object?> get props => [];
}

class LoadGamificationData extends GamificationEvent {}

class LoadBadges extends GamificationEvent {}

class LoadLevelProgress extends GamificationEvent {}

// --- States ---
enum GamificationStatus { initial, loading, loaded, error }

class GamificationState extends Equatable {
  final GamificationStatus status;
  final List<BadgeModel> badges;
  final LevelProgressResponse? levelProgress;
  final String? error;

  const GamificationState({
    this.status = GamificationStatus.initial,
    this.badges = const [],
    this.levelProgress,
    this.error,
  });

  GamificationState copyWith({
    GamificationStatus? status,
    List<BadgeModel>? badges,
    LevelProgressResponse? levelProgress,
    String? error,
  }) {
    return GamificationState(
      status: status ?? this.status,
      badges: badges ?? this.badges,
      levelProgress: levelProgress ?? this.levelProgress,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, badges, levelProgress, error];
}

// --- Bloc ---
class GamificationBloc extends Bloc<GamificationEvent, GamificationState> {
  final GamificationService _gamificationService;
  final BadgeService _badgeService;

  GamificationBloc({
    required GamificationService gamificationService,
    required BadgeService badgeService,
  }) : _gamificationService = gamificationService,
       _badgeService = badgeService,
       super(const GamificationState()) {
    
    on<LoadGamificationData>(_onLoadData);
    on<LoadBadges>(_onLoadBadges);
    on<LoadLevelProgress>(_onLoadLevelProgress);
  }

  Future<void> _onLoadData(LoadGamificationData event, Emitter<GamificationState> emit) async {
    emit(state.copyWith(status: GamificationStatus.loading));
    try {
      // Fetch both in parallel
      final results = await Future.wait([
        _badgeService.getMyBadges(),
        _gamificationService.getLevelProgress(),
      ]);

      emit(state.copyWith(
        status: GamificationStatus.loaded,
        badges: results[0] as dynamic, 
        levelProgress: results[1] as dynamic,
      ));
    } catch (e) {
      emit(state.copyWith(status: GamificationStatus.error, error: e.toString()));
    }
  }

  Future<void> _onLoadBadges(LoadBadges event, Emitter<GamificationState> emit) async {
    try {
      final badges = await _badgeService.getMyBadges();
      emit(state.copyWith(badges: badges));
    } catch (e) {
      print("Error loading badges: $e");
    }
  }

  Future<void> _onLoadLevelProgress(LoadLevelProgress event, Emitter<GamificationState> emit) async {
    try {
      final progress = await _gamificationService.getLevelProgress();
      emit(state.copyWith(levelProgress: progress));
    } catch (e) {
      print("Error loading level: $e");
    }
  }
}
