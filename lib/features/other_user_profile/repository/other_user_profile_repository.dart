import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/other_user_profile_model.dart';
import 'package:client/core/constants/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OtherUserProfileRepository {
  Future<OtherUserProfileModel> getOtherUserProfile(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    final response = await http.get(
      Uri.parse('$baseUrl/auth/user/$userId'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'x-auth-token': token,
      },
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      print(
        'OtherUserProfile response: ' + response.body,
      ); // DEBUG: log backend response
      return OtherUserProfileModel.fromJson(data);
    } else if (response.statusCode == 404) {
      throw Exception('User not found');
    } else {
      print(response.body);
      // Optionally, check for {"detail":"Not Found"} in the body
      try {
        final Map<String, dynamic> error = json.decode(response.body);
        if (error['detail'] == 'Not Found') {
          throw Exception('User not found');
        }
      } catch (_) {}
      throw Exception('Failed to load other user profile: ${response.body}');
    }
  }

  Future<bool> followOrUnfollowUser(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    final response = await http.post(
      Uri.parse('$baseUrl/auth/follow/$userId'),
      headers: {'x-auth-token': token},
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['following'] ?? false;
    } else {
      throw Exception('Failed to follow/unfollow user: ${response.body}');
    }
  }

  Future<bool> likeOrUnlikePost(String postId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    final response = await http.post(
      Uri.parse('$baseUrl/media/posts/$postId/like'),
      headers: {
        'x-auth-token': token,
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to like post: ${response.body}');
    }
    final responseData = json.decode(response.body);
    return responseData['liked']; // Returns true if liked, false if unliked
  }
}
