import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/services/diet_service.dart';

abstract class DietEvent extends Equatable {
  const DietEvent();

  @override
  List<Object?> get props => [];
}

class LoadDietPlan extends DietEvent {
  final bool forceRefresh;
  final String? initialDietContent;

  const LoadDietPlan({this.forceRefresh = false, this.initialDietContent});

  @override
  List<Object?> get props => [forceRefresh, initialDietContent];
}

class CheckDietStatusEvent extends DietEvent {}

abstract class DietState extends Equatable {
  const DietState();
  
  @override
  List<Object?> get props => [];
}

class DietInitial extends DietState {}

class DietLoading extends DietState {}

class DietLoaded extends DietState {
  final DietPlan plan;
  final Map<String, String> dailyPlans;
  final List<String> daysOrder;
  final bool weighInRequired;

  const DietLoaded({
    required this.plan,
    required this.dailyPlans,
    required this.daysOrder,
    this.weighInRequired = false,
  });

  @override
  List<Object?> get props => [plan, dailyPlans, daysOrder, weighInRequired];

  DietLoaded copyWith({
    DietPlan? plan,
    Map<String, String>? dailyPlans,
    List<String>? daysOrder,
    bool? weighInRequired,
  }) {
    return DietLoaded(
      plan: plan ?? this.plan,
      dailyPlans: dailyPlans ?? this.dailyPlans,
      daysOrder: daysOrder ?? this.daysOrder,
      weighInRequired: weighInRequired ?? this.weighInRequired,
    );
  }
}

class DietEmpty extends DietState {}

class DietError extends DietState {
  final String message;
  
  const DietError(this.message);
  
  @override
  List<Object?> get props => [message];
}

class DietBloc extends Bloc<DietEvent, DietState> {
  final DietService _dietService;

  DietBloc({required DietService dietService}) 
    : _dietService = dietService,
      super(DietInitial()) {
    
    on<LoadDietPlan>(_onLoadDietPlan);
    on<CheckDietStatusEvent>(_onCheckDietStatus);
  }

  Future<void> _onLoadDietPlan(LoadDietPlan event, Emitter<DietState> emit) async {
    if (event.initialDietContent != null && event.initialDietContent!.isNotEmpty) {
      final plan = DietPlan(
         id: 0, 
         content: event.initialDietContent!, 
         createdAt: DateTime.now()
      );
      final parsingResult = _parseDietContent(plan.content);
      emit(DietLoaded(
        plan: plan,
        dailyPlans: parsingResult.dailyPlans,
        daysOrder: parsingResult.daysOrder,
      ));
      
      if (!event.forceRefresh) return;
    }

    emit(DietLoading());

    try {
      final plan = await _dietService.getLatestDietPlan();
      
      if (plan != null) {
        final parsingResult = _parseDietContent(plan.content);
        emit(DietLoaded(
          plan: plan,
          dailyPlans: parsingResult.dailyPlans,
          daysOrder: parsingResult.daysOrder,
        ));
      } else {
        emit(DietEmpty());
      }
    } catch (e) {
      emit(DietError("Failed to load diet plan: ${e.toString()}"));
    }
  }

  Future<void> _onCheckDietStatus(CheckDietStatusEvent event, Emitter<DietState> emit) async {
    final currentState = state;
    if (currentState is DietLoaded) {
      try {
        final status = await _dietService.checkDietStatus();
        if (status != null && status.status == "WeighInRequired") {
          emit(currentState.copyWith(weighInRequired: true));
        }
      } catch (e) {
        print("Error checking diet status: $e");
      }
    }
  }

  ({Map<String, String> dailyPlans, List<String> daysOrder}) _parseDietContent(String content) {
    final days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    
    String normalized = content.replaceAll('\r\n', '\n');
    
    List<String> lines = normalized.split('\n');
    Map<String, List<String>> chunks = {};
    String currentDay = "General";
    chunks[currentDay] = [];

    for (String line in lines) {
      String trimmed = line.trim();
      
      bool isHeader = false;
      String foundDay = "";
      
      for (String d in days) {
        if (trimmed.toLowerCase().contains(d.toLowerCase())) {
          if (trimmed.length < 30 || trimmed.startsWith('**') || trimmed.startsWith('#')) {
             isHeader = true;
             foundDay = d;
             break;
          }
        }
      }

      if (isHeader) {
        String normalizedDay = foundDay[0].toUpperCase() + foundDay.substring(1).toLowerCase();
        currentDay = normalizedDay;

        if (!chunks.containsKey(currentDay)) {
          chunks[currentDay] = [];
        }
      } else {
        chunks[currentDay]?.add(line);
      }
    }
    
    Map<String, String> result = {};
    List<String> order = [];
    
    final sortOrder = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday', 'General'];
    
    chunks.forEach((key, value) {
       String body = value.join('\n').trim();
       if (key != "General" || body.length > 20) { 
         result[key] = body;
       }
    });

    for (var d in sortOrder) {
      if (result.containsKey(d)) order.add(d);
    }
    result.keys.forEach((k) {
      if (!sortOrder.contains(k) && !order.contains(k)) order.add(k);
    });

    return (dailyPlans: result, daysOrder: order);
  }
}
