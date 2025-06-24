import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserSearchResult {
  final String username;
  final String profilePicUrl;

  UserSearchResult({required this.username, required this.profilePicUrl});

  factory UserSearchResult.fromJson(Map<String, dynamic> json) {
    return UserSearchResult(
      username: json['username'],
      profilePicUrl: json['profile_pic_url'] ?? '',
    );
  }
}

class UserSearchRepository {
  final String baseUrl;
  UserSearchRepository({required this.baseUrl});

  Future<List<UserSearchResult>> searchUsers(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    final response = await http.get(
      Uri.parse('$baseUrl/auth/search/users?q=$query'),
      headers: {'x-auth-token': token, 'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => UserSearchResult.fromJson(e)).toList();
    } else {
      throw Exception('Failed to search users');
    }
  }
}
