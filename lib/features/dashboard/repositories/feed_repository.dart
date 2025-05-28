import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/post.dart';
import 'package:client/core/constants/api.dart';

class FeedRepository {
  Future<List<Post>> getFeedPosts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('No authentication token found');
      }
      final response = await http.get(
        Uri.parse('$baseUrl/media/feed'),
        headers: {
          'x-auth-token': token,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Post.fromJson(json)).toList();
      } else {
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
        if (response.statusCode == 422) {
          throw Exception('Invalid request format: ${response.body}');
        } else {
          throw Exception('Failed to load feed posts: ${response.body}');
        }
      }
    } catch (e) {
      print('Error details: $e');
      throw Exception('Error fetching feed posts: $e');
    }
  }

  Future<bool> likePost(String postId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('No authentication token found');
      }
      print('Attempting to like post with ID: $postId');
      final response = await http.post(
        Uri.parse(
          '$baseUrl/media/posts/$postId/like',
        ), // Changed to /media/ to match working feed endpoint
        headers: {
          'x-auth-token': token,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode != 200) {
        print('Like response status: ${response.statusCode}');
        print('Like response body: ${response.body}');
        throw Exception('Failed to like post: ${response.body}');
      }

      final responseData = json.decode(response.body);
      return responseData['liked']; // Returns true if liked, false if unliked
    } catch (e) {
      print('Like error details: $e');
      throw Exception('Error liking post: $e');
    }
  }

  Future<Map<String, dynamic>> addComment(String postId, String comment) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('No authentication token found');
      }
      print('Attempting to add comment to post with ID: $postId');
      final response = await http.post(
        Uri.parse('$baseUrl/media/posts/$postId/comments'),
        headers: {
          'x-auth-token': token,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'text': comment}),
      );
      if (response.statusCode != 200) {
        print('Comment response status: ${response.statusCode}');
        print('Comment response body: ${response.body}');
        throw Exception('Failed to add comment: ${response.body}');
      }
      final responseData = json.decode(response.body) as Map<String, dynamic>;

      // Since the API doesn't return user_name, we'll create a modified response
      // that includes userName from the existing data
      final modifiedResponse = {
        ...responseData,
        'user_name':
            'You', // We'll show "You" for comments made by the current user
      };

      return modifiedResponse;
    } catch (e) {
      print('Comment error details: $e');
      throw Exception('Failed to add comment');
    }
  }
}
