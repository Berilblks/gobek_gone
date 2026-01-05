import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/chat_message.dart';
import '../data/repositories/ai_repository.dart';
import '../../auth/data/repositories/auth_repository.dart';
import '../../diet/data/diet_service.dart';
import '../../workout/data/services/workout_service.dart'; 

// Events
abstract class ChatEvent {}

class StartChat extends ChatEvent {}

class SendMessage extends ChatEvent {
  final String message;
  SendMessage(this.message);
}

// States
abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {
  final List<ChatMessage> messages;
  ChatLoading(this.messages);
}

class ChatLoaded extends ChatState {
  final List<ChatMessage> messages;
  final bool showOptions; 
  final bool isDietReady; 
  final bool hasDietPlan; 
  final String? generatedDietPlan; 
  final bool isWorkoutReady; 
  final bool hasWorkoutPlan; 
  final bool targetWeightUpdated;
  
  ChatLoaded(this.messages, {
    this.showOptions = false, 
    this.isDietReady = false, 
    this.hasDietPlan = false,
    this.generatedDietPlan,
    this.isWorkoutReady = false,
    this.hasWorkoutPlan = false,
    this.targetWeightUpdated = false,
  });
}

class ChatError extends ChatState {
  final List<ChatMessage> messages;
  final String error;
  ChatError(this.messages, this.error);
}

// Bloc
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final AiRepository aiRepository;
  final AuthRepository authRepository; 
  final DietService dietService; 
  final WorkoutService workoutService;
  final List<ChatMessage> _messages = [];

  ChatBloc({
    required this.aiRepository, 
    required this.authRepository,
    required this.dietService,
    required this.workoutService,
  }) : super(ChatInitial()) {
    
    on<StartChat>((event, emit) async {
       emit(ChatLoading([]));
       try {
         final user = await authRepository.getUserInfo();
         final name = user.fullname.isNotEmpty ? user.fullname : (user.username.isNotEmpty ? user.username : "Friend");
         
         bool dietExists = false;
         try {
            final plan = await dietService.getLatestDietPlan();
            if (plan != null) dietExists = true;
         } catch (_) {}

         bool workoutExists = false;
         try {
            final wPlan = await workoutService.getUserWorkoutPlan();
            if (wPlan != null) workoutExists = true;
         } catch (_) {}

         _messages.clear();

         // Always Add Welcome Message & Options (No History)
         _messages.add(ChatMessage(
           text: "Hi $name! I'm Belly, your personal health assistant. How can I help you today?",
           isUser: false,
           timestamp: DateTime.now(),
         ));
         
         emit(ChatLoaded(List.from(_messages), 
            showOptions: true, 
            hasDietPlan: dietExists,
            hasWorkoutPlan: workoutExists
         ));
       } catch (e) {
         _messages.clear();
         _messages.add(ChatMessage(
           text: "Hi there! I'm Belly. How can I help you today?",
           isUser: false,
           timestamp: DateTime.now(),
         ));
         emit(ChatLoaded(List.from(_messages), showOptions: true));
       }
    });

    on<SendMessage>((event, emit) async {
      _messages.add(ChatMessage(
        text: event.message,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      
      emit(ChatLoading(List.from(_messages)));

      try {
        final response = await aiRepository.sendMessage(event.message);

        bool dietReady = false;
        bool workoutReady = false;
        bool weightUpdated = false;
        String finalResponse = response;
        String? dietContent;

        if (response.contains("[GENERATE_DIET]")) {
           dietReady = true;
           finalResponse = response.replaceAll("[GENERATE_DIET]", "").trim();
           dietContent = finalResponse;
        }
        
        if (response.contains("[GENERATE_WORKOUT]")) {
           workoutReady = true;
           finalResponse = finalResponse.replaceAll("[GENERATE_WORKOUT]", "").trim();
        }

        // Check for Target Weight
        final weightRegex = RegExp(r"\[SET_TARGET_WEIGHT:\s*(\d+)\]");
        if (weightRegex.hasMatch(response)) {
           weightUpdated = true;
           finalResponse = finalResponse.replaceAll(weightRegex, "").trim();
        }

        _messages.add(ChatMessage(
          text: finalResponse,
          isUser: false,
          timestamp: DateTime.now(),
        ));

        // Preserve previous hasDietPlan/hasWorkoutPlan state if possible
        // Actually, for simplicity, we assume they default to false here or 
        // ideally we should carry them over from previous state if we had access to it easily.
        // But since this is a new emit, the UI will re-render options if showOptions is true.
        // Wait, showOptions is false here. So hasDietPlan/hasWorkoutPlan doesn't matter for the chip display 
        // (chips are only shown if showOptions=true).
        // However, if we ever wanted to show options again, we'd need to re-fetch or store them.
        // For now, this is consistent with existing logic.
        
        emit(ChatLoaded(List.from(_messages), 
          showOptions: false, 
          isDietReady: dietReady, 
          generatedDietPlan: dietContent,
          isWorkoutReady: workoutReady,
          targetWeightUpdated: weightUpdated
        ));
      } catch (e) {
        emit(ChatError(List.from(_messages), e.toString()));
      }
    });
  }
}
