import 'package:client/features/chat/cubit/chat_cubit.dart';
import 'package:client/features/chat/repository/chat_repository.dart';
import 'package:client/features/other_user_profile/models/other_user_profile_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:client/core/themes/pallete.dart';

class ChatPage extends StatelessWidget {
  final OtherUserProfileModel otherUser;
  final String authToken;
  final String baseUrl;

  const ChatPage({
    Key? key,
    required this.otherUser,
    required this.authToken,
    required this.baseUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (_) => ChatCubit(
            repository: ChatRepository(baseUrl: baseUrl),
            userId: otherUser.id,
          )..loadMessages(),
      child: _ChatView(otherUser: otherUser),
    );
  }
}

class _ChatView extends StatefulWidget {
  final OtherUserProfileModel otherUser;
  const _ChatView({Key? key, required this.otherUser}) : super(key: key);

  @override
  State<_ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<_ChatView> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage:
                  widget.otherUser.profilePicUrl != null &&
                          widget.otherUser.profilePicUrl!.isNotEmpty
                      ? NetworkImage(widget.otherUser.profilePicUrl!)
                      : null,
              child:
                  (widget.otherUser.profilePicUrl == null ||
                          widget.otherUser.profilePicUrl!.isEmpty)
                      ? Icon(Icons.person, color: Colors.grey[700])
                      : null,
              backgroundColor: Colors.grey[200],
            ),
            const SizedBox(width: 10),
            Text(
              widget.otherUser.username,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<ChatCubit, ChatState>(
              builder: (context, state) {
                if (state is ChatLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ChatLoaded) {
                  return ListView.builder(
                    reverse: false, // Show newer messages at the bottom
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final msg = state.messages[index];
                      final isMe = msg.senderId != widget.otherUser.id;
                      return Align(
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            vertical: 2,
                            horizontal: 8,
                          ),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isMe ? Pallete.greenColor : Colors.white,
                            border:
                                isMe
                                    ? null
                                    : Border.all(color: Colors.black, width: 1),
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(12),
                              topRight: const Radius.circular(12),
                              bottomLeft: Radius.circular(isMe ? 12 : 0),
                              bottomRight: Radius.circular(isMe ? 0 : 12),
                            ),
                          ),
                          child: Text(
                            msg.content,
                            style: TextStyle(
                              color: isMe ? Colors.white : Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                } else if (state is ChatError) {
                  return Center(
                    child: Text('Error: [38;5;9m${state.message}[0m'),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 45, // Lower height than login
                    alignment: Alignment.center,
                    child: TextField(
                      controller: _controller,
                      style: TextStyle(color: Pallete.blackColor),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 16,
                        ),
                        hintText: 'Type a message...',
                        hintStyle: TextStyle(color: Pallete.blackColor),
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Pallete.borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Pallete.greenColor,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  height: 45,
                  width: 45,
                  decoration: BoxDecoration(
                    color: Pallete.greenColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () {
                      final text = _controller.text.trim();
                      if (text.isNotEmpty) {
                        context.read<ChatCubit>().sendMessage(text);
                        _controller.clear();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
