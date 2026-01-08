import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/services/diet_service.dart';

// --- Events ---
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

// --- States ---
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

// --- Bloc ---
class DietBloc extends Bloc<DietEvent, DietState> {
  final DietService _dietService;

  DietBloc({required DietService dietService}) 
    : _dietService = dietService,
      super(DietInitial()) {
    
    on<LoadDietPlan>(_onLoadDietPlan);
    on<CheckDietStatusEvent>(_onCheckDietStatus);
  }

  Future<void> _onLoadDietPlan(LoadDietPlan event, Emitter<DietState> emit) async {
    // If initial content is provided, use it immediately
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
      
      // Optionally sync in background if needed, but usually initial content is enough for immediate display
      // If forceRefresh is false, we stop here.
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
        // Silently fail for status check or log it
        print("Error checking diet status: $e");
      }
    }
  }

  // Parsing Logic
  ({Map<String, String> dailyPlans, List<String> daysOrder}) _parseDietContent(String content) {
    // Basic parser to split content by day headers
    final days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    
    // Normalize newlines
    String normalized = content.replaceAll('\r\n', '\n');
    
    // Split by lines to find headers
    List<String> lines = normalized.split('\n');
    Map<String, List<String>> chunks = {};
    String currentDay = "General";
    chunks[currentDay] = [];

    // Regex to match lines that strongly look like day headers
    for (String line in lines) {
      String trimmed = line.trim();
      
      bool isHeader = false;
      String foundDay = "";
      
      for (String d in days) {
        if (trimmed.toLowerCase().contains(d.toLowerCase())) {
          // Check if the line is SHORT (likely a header) or bolded or header
          if (trimmed.length < 30 || trimmed.startsWith('**') || trimmed.startsWith('#')) {
             isHeader = true;
             foundDay = d;
             break;
          }
        }
      }

      if (isHeader) {
        // Normalize day name to Title Case
        String normalizedDay = foundDay[0].toUpperCase() + foundDay.substring(1).toLowerCase();
        currentDay = normalizedDay;

        if (!chunks.containsKey(currentDay)) {
          chunks[currentDay] = [];
        }
      } else {
        chunks[currentDay]?.add(line);
      }
    }
    
    // Cleanup chunks
    Map<String, String> result = {};
    List<String> order = [];
    
    // Standard Sort Order
    final sortOrder = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday', 'General'];
    
    chunks.forEach((key, value) {
       String body = value.join('\n').trim();
       if (key != "General" || body.length > 20) { 
         result[key] = body;
       }
    });

    // Populate order list based on sortOrder
    for (var d in sortOrder) {
      if (result.containsKey(d)) order.add(d);
    }
    // Add any others not in sort order (unexpected headers)
    result.keys.forEach((k) {
      if (!sortOrder.contains(k) && !order.contains(k)) order.add(k);
    });

    return (dailyPlans: result, daysOrder: order);
  }
}
