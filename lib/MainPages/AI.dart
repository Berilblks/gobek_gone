import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gobek_gone/General/app_colors.dart';
import 'package:gobek_gone/MainPages/Contents/DietList.dart';
import '../../features/ai/logic/chat_bloc.dart';
import '../../features/ai/data/models/chat_message.dart';

class AIpage extends StatelessWidget {
  final String? initialMessage;
  const AIpage({super.key, this.initialMessage});

  @override
  Widget build(BuildContext context) {
    // ChatBloc is provided globally in main.dart
    return _AIChatView(initialMessage: initialMessage);
  }
}

class _AIChatView extends StatefulWidget {
  final String? initialMessage;
  const _AIChatView({this.initialMessage});

  @override
  State<_AIChatView> createState() => _AIChatViewState();
}

class _AIChatViewState extends State<_AIChatView> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Always refresh chat when entering to check for updates and show welcome
    context.read<ChatBloc>().add(StartChat());
    
    // Auto-send initial message if provided (e.g. from DietList weigh-in)
    if (widget.initialMessage != null && widget.initialMessage!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
         // Sending slightly delayed to ensure StartChat clears things first or handles state
         Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) _sendMessage(text: widget.initialMessage);
         });
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage({String? text}) {
    final messageText = text ?? _textController.text.trim();
    if (messageText.isNotEmpty) {
      _textController.clear();
      context.read<ChatBloc>().add(SendMessage(messageText));
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Assistant', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.appbar_color, 
        foregroundColor: Colors.black54,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<ChatBloc, ChatState>(
              listener: (context, state) {
                if (state is ChatError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.error), backgroundColor: Colors.red),
                  );
                }
                
                if (state is ChatLoaded && state.isDietReady) {
                  final dietContent = state.generatedDietPlan;
                  // Delay the snackbar slightly to let the user see the AI message first
                  Future.delayed(const Duration(seconds: 2), () {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text("Your Diet List is Ready!"),
                          backgroundColor: Colors.green,
                          duration: const Duration(seconds: 8),
                          action: SnackBarAction(
                            label: "OPEN LIST",
                            textColor: Colors.white,
                            onPressed: () {
                              Navigator.push(
                                context, 
                                MaterialPageRoute(builder: (context) => DietList(initialDietPlan: dietContent))
                              );
                            },
                          ),
                        ),
                      );
                    }
                  });
                }

                _scrollToBottom();
              },
              builder: (context, state) {
                List<ChatMessage> messages = [];
                bool isLoading = false;
                bool showOptions = false;

                if (state is ChatInitial) {
                   // Initial state
                } else if (state is ChatLoading) {
                  messages = state.messages;
                  isLoading = true;
                } else if (state is ChatLoaded) {
                  messages = state.messages;
                  showOptions = state.showOptions;
                } else if (state is ChatError) {
                  messages = state.messages;
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length + (isLoading ? 1 : 0) + (showOptions ? 1 : 0),
                  itemBuilder: (context, index) {
                    // 1. Loading Indicator
                    if (isLoading && index == messages.length) {
                       return const Align(
                        alignment: Alignment.centerLeft,
                        child:  Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                          child: Chip(
                            backgroundColor: Colors.white,
                            label: SizedBox(
                              width: 30,
                              height: 15,
                              child: LinearProgressIndicator(color: AppColors.AI_color)
                            )
                          ),
                        ),
                      );
                    }
                    
                    // 2. Options Chips
                    if (showOptions && index == (messages.length + (isLoading ? 1 : 0))) {
                        final hasDiet = (state is ChatLoaded) ? state.hasDietPlan : false;
                        
                        return Padding(
                          padding: const EdgeInsets.only(top: 10, left: 4),
                          child: Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: [
                              ActionChip(
                                avatar: Icon(hasDiet ? Icons.edit_note : Icons.restaurant_menu, size: 16, color: Colors.white),
                                label: Text(hasDiet ? "Update Diet List" : "Create Diet List", style: const TextStyle(color: Colors.white)),
                                backgroundColor: AppColors.bottombar_color,
                                onPressed: () => _sendMessage(text: hasDiet 
                                    ? "I want to update my existing diet plan. Ask me what I'd like to change." 
                                    : "Create a diet list for me"),
                              ),
                              ActionChip(
                                avatar: const Icon(Icons.chat, size: 16, color: Colors.black54),
                                label: const Text("Just Chat"),
                                backgroundColor: Colors.grey[200],
                                onPressed: () => _sendMessage(text: "I just want to chat about healthy living"),
                              ),
                            ],
                          ),
                        );
                    }

                    // 3. Messages
                    if (index < messages.length) {
                       final message = messages[index];
                       return _buildMessageBubble(message);
                    }
                    return const SizedBox.shrink();
                  },
                );
              },
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.bottombar_color.withValues(alpha: 0.9),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: "Type a message...",
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.AI_color,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: () => _sendMessage(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isUser;
    final alignment = isUser ? Alignment.centerRight : Alignment.centerLeft;
    final bgColor = isUser ? AppColors.AI_color : Colors.grey[200];
    final textColor = isUser ? Colors.white : Colors.black87;
    final borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(4),
      bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(16),
    );

    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: borderRadius,
        ),
        child: Text(
          message.text,
          style: TextStyle(color: textColor, fontSize: 16),
        ),
      ),
    );
  }
}
