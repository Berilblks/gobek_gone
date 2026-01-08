import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/chat_message.dart';
import '../data/repositories/ai_repository.dart';
import '../../auth/data/repositories/auth_repository.dart';
import '../../diet/data/services/diet_service.dart';
import '../../workout/data/services/workout_service.dart'; 

abstract class ChatEvent {}

class StartChat extends ChatEvent {}

class SendMessage extends ChatEvent {
  final String message;
  SendMessage(this.message);
}

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
  final String? generatedWorkoutPlan; 
  final bool targetWeightUpdated;
  
  ChatLoaded(this.messages, {
    this.showOptions = false, 
    this.isDietReady = false, 
    this.hasDietPlan = false,
    this.generatedDietPlan,
    this.isWorkoutReady = false,
    this.hasWorkoutPlan = false,
    this.generatedWorkoutPlan, 
    this.targetWeightUpdated = false,
  });
}

class ChatError extends ChatState {
  final List<ChatMessage> messages;
  final String error;
  ChatError(this.messages, this.error);
}

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
        String? workoutContent;

        if (response.contains("[GENERATE_DIET]")) {
           dietReady = true;
           finalResponse = response.replaceAll("[GENERATE_DIET]", "").trim();
           dietContent = finalResponse;
        }
        
        if (response.contains("[GENERATE_WORKOUT]")) {
           workoutReady = true;
           finalResponse = finalResponse.replaceAll("[GENERATE_WORKOUT]", "").trim();
           workoutContent = finalResponse;
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

        emit(ChatLoaded(List.from(_messages), 
          showOptions: false, 
          isDietReady: dietReady, 
          generatedDietPlan: dietContent,
          isWorkoutReady: workoutReady,
          generatedWorkoutPlan: workoutContent,
          targetWeightUpdated: weightUpdated
        ));
      } catch (e) {
        emit(ChatError(List.from(_messages), e.toString()));
      }
    });
  }
}
