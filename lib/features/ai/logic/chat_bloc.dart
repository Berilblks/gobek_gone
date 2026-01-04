import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/chat_message.dart';
import '../data/repositories/ai_repository.dart';
import '../../auth/data/repositories/auth_repository.dart';
import '../../diet/data/diet_service.dart';

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
  final bool showOptions; // To persist options if needed
  final bool isDietReady; // Trigger for diet list generation
  final bool hasDietPlan; // Check if user already has a plan
  final String? generatedDietPlan; // New: Hold the content to pass to UI
  
  ChatLoaded(this.messages, {
    this.showOptions = false, 
    this.isDietReady = false, 
    this.hasDietPlan = false,
    this.generatedDietPlan,
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
  final List<ChatMessage> _messages = [];

  ChatBloc({
    required this.aiRepository, 
    required this.authRepository,
    required this.dietService,
  }) : super(ChatInitial()) {
    
    on<StartChat>((event, emit) async {
       emit(ChatLoading([]));
       try {
         final user = await authRepository.getUserInfo();
         final name = user.fullname.isNotEmpty ? user.fullname : (user.username.isNotEmpty ? user.username : "Friend");
         
         bool planExists = false;
         try {
            final plan = await dietService.getLatestDietPlan();
            if (plan != null) planExists = true;
         } catch (_) {}

         _messages.clear();

         // Always Add Welcome Message & Options (No History)
         _messages.add(ChatMessage(
           text: "Hi $name! I'm Belly, your personal health assistant. How can I help you today?",
           isUser: false,
           timestamp: DateTime.now(),
         ));
         
         emit(ChatLoaded(List.from(_messages), showOptions: true, hasDietPlan: planExists));
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
        String finalResponse = response;
        String? dietContent;

        if (response.contains("[GENERATE_DIET]")) {
           dietReady = true;
           finalResponse = response.replaceAll("[GENERATE_DIET]", "").trim();
           dietContent = finalResponse;
        }

        _messages.add(ChatMessage(
          text: finalResponse,
          isUser: false,
          timestamp: DateTime.now(),
        ));

        emit(ChatLoaded(List.from(_messages), 
          showOptions: false, 
          isDietReady: dietReady, 
          generatedDietPlan: dietContent
        ));
      } catch (e) {
        emit(ChatError(List.from(_messages), e.toString()));
      }
    });
  }
}
