import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/chat_message.dart';
import '../repository/chat_repository.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository repository;
  final String userId;

  ChatCubit({required this.repository, required this.userId})
    : super(ChatInitial());

  Future<void> loadMessages() async {
    emit(ChatLoading());
    try {
      final messages = await repository.getMessagesWithUser(userId);
      emit(ChatLoaded(messages));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> sendMessage(String content) async {
    try {
      await repository.sendMessage(userId, content);
      await loadMessages();
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> markMessagesRead(List<String> messageIds) async {
    try {
      await repository.markMessagesRead(messageIds);
      await loadMessages();
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }
}
