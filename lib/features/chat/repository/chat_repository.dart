import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_message.dart';

class ChatRepository {
  final String baseUrl;

  ChatRepository({required this.baseUrl});

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    if (token.isEmpty) throw Exception('No authentication token found');
    return token;
  }

  Future<List<ChatMessage>> getMessagesWithUser(
    String userId, {
    int limit = 50,
    int offset = 0,
  }) async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse(
        '$baseUrl/auth/messages/conversation/$userId?limit=$limit&offset=$offset',
      ),
      headers: {'x-auth-token': token},
    );
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => ChatMessage.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load messages');
    }
  }

  Future<void> sendMessage(String receiverId, String content) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/auth/messages/send'),
      headers: {'Content-Type': 'application/json', 'x-auth-token': token},
      body: json.encode({'receiver_id': receiverId, 'content': content}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to send message');
    }
  }

  Future<void> markMessagesRead(List<String> messageIds) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/auth/messages/mark-read'),
      headers: {'Content-Type': 'application/json', 'x-auth-token': token},
      body: json.encode({'message_ids': messageIds}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to mark messages as read');
    }
  }
}
