import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/chat_message.dart';
import '../data/repositories/ai_repository.dart';

// Events
abstract class ChatEvent {}

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
  ChatLoaded(this.messages);
}

class ChatError extends ChatState {
  final List<ChatMessage> messages;
  final String error;
  ChatError(this.messages, this.error);
}

// Bloc
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final AiRepository aiRepository;
  final List<ChatMessage> _messages = [];

  ChatBloc({required this.aiRepository}) : super(ChatInitial()) {
    on<SendMessage>((event, emit) async {
      // 1. Add User Message
      _messages.add(ChatMessage(
        text: event.message,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      
      // Emit loading state (keeps messages)
      emit(ChatLoading(List.from(_messages)));

      try {
        // 2. Call API
        final response = await aiRepository.sendMessage(event.message);

        // 3. Add AI Response
        _messages.add(ChatMessage(
          text: response,
          isUser: false,
          timestamp: DateTime.now(),
        ));

        emit(ChatLoaded(List.from(_messages)));
      } catch (e) {
        emit(ChatError(List.from(_messages), e.toString()));
      }
    });
  }
}
