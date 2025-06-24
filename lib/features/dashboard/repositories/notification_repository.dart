import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationModel {
  final int id;
  final String type;
  final String message;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.type,
    required this.message,
    this.data,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      type: json['type'],
      message: json['message'],
      data: json['data'],
      isRead: json['is_read'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class NotificationRepository {
  final String baseUrl;
  NotificationRepository({required this.baseUrl});

  Future<List<NotificationModel>> fetchNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    final response = await http.get(
      Uri.parse('$baseUrl/auth/notifications'),
      headers: {'x-auth-token': token},
    );
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => NotificationModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch notifications');
    }
  }

  Future<void> markNotificationsRead(List<int> ids) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    final response = await http.post(
      Uri.parse('$baseUrl/auth/notifications/mark-read'),
      headers: {'x-auth-token': token, 'Content-Type': 'application/json'},
      body: json.encode(ids),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to mark notifications as read');
    }
  }
}
