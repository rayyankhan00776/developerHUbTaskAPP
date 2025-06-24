// Model for a chat message
class ChatMessage {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderUsername;
  final String senderProfilePicUrl;
  final String receiverId;
  final String receiverUsername;
  final String receiverProfilePicUrl;
  final String content;
  final DateTime createdAt;
  final bool isRead;

  ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderUsername,
    required this.senderProfilePicUrl,
    required this.receiverId,
    required this.receiverUsername,
    required this.receiverProfilePicUrl,
    required this.content,
    required this.createdAt,
    required this.isRead,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      conversationId: json['conversation_id'],
      senderId: json['sender_id'],
      senderUsername: json['sender_username'],
      senderProfilePicUrl: json['sender_profile_pic_url'],
      receiverId: json['receiver_id'],
      receiverUsername: json['receiver_username'],
      receiverProfilePicUrl: json['receiver_profile_pic_url'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
      isRead: json['is_read'] == 'TRUE',
    );
  }
}
