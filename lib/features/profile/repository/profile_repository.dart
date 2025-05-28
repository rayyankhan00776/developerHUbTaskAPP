import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/profile_model.dart';
import 'package:client/core/constants/api.dart';

class ProfileRepository {
  // Get current user profile data
  Future<ProfileModel> getCurrentUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/auth/'),
        headers: {
          'x-auth-token': token,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return ProfileModel.fromJson(data);
      } else {
        print('Profile response status: ${response.statusCode}');
        print('Profile response body: ${response.body}');
        throw Exception('Failed to load profile: ${response.body}');
      }
    } catch (e) {
      print('Profile error details: $e');
      throw Exception('Error fetching profile: $e');
    }
  }

  // Update profile picture
  Future<String> updateProfilePicture(File imageFile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('No authentication token found');
      }

      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('$baseUrl/media/profile/pic'),
      );

      request.headers.addAll({
        'x-auth-token': token,
        'Accept': 'application/json',
      });

      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(responseBody);
        return data['profile_pic_url'];
      } else {
        print('Update profile pic status: ${response.statusCode}');
        print('Update profile pic body: $responseBody');
        throw Exception('Failed to update profile picture: $responseBody');
      }
    } catch (e) {
      print('Update profile pic error: $e');
      throw Exception('Error updating profile picture: $e');
    }
  }

  // Delete profile picture
  Future<void> deleteProfilePicture() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/media/profile/pic'),
        headers: {
          'x-auth-token': token,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        print('Delete profile pic status: ${response.statusCode}');
        print('Delete profile pic body: ${response.body}');
        throw Exception('Failed to delete profile picture: ${response.body}');
      }
    } catch (e) {
      print('Delete profile pic error: $e');
      throw Exception('Error deleting profile picture: $e');
    }
  }

  // Create a new post
  Future<Post> createPost({String? content, File? mediaFile}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('No authentication token found');
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/media/posts'),
      );

      request.headers.addAll({
        'x-auth-token': token,
        'Accept': 'application/json',
      });

      if (content != null && content.isNotEmpty) {
        request.fields['content'] = content;
      }

      if (mediaFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('file', mediaFile.path),
        );
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(responseBody);
        // Convert the response to match Post model structure
        final postData = {
          'id': data['id'],
          'content': data['content'],
          'media_url': data['media_url'],
          'created_at': data['created_at'],
          'total_likes': 0,
          'liked_by_user': false,
          'comments': [],
        };
        return Post.fromJson(postData);
      } else {
        print('Create post status: ${response.statusCode}');
        print('Create post body: $responseBody');
        throw Exception('Failed to create post: $responseBody');
      }
    } catch (e) {
      print('Create post error: $e');
      throw Exception('Error creating post: $e');
    }
  }

  // Get user's posts
  Future<List<Post>> getUserPosts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/media/posts'),
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
        print('Get posts status: ${response.statusCode}');
        print('Get posts body: ${response.body}');
        throw Exception('Failed to load posts: ${response.body}');
      }
    } catch (e) {
      print('Get posts error: $e');
      throw Exception('Error fetching posts: $e');
    }
  }

  // Like/unlike a post
  Future<bool> likePost(String postId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/media/posts/$postId/like'),
        headers: {
          'x-auth-token': token,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['liked'];
      } else {
        print('Like post status: ${response.statusCode}');
        print('Like post body: ${response.body}');
        throw Exception('Failed to like post: ${response.body}');
      }
    } catch (e) {
      print('Like post error: $e');
      throw Exception('Error liking post: $e');
    }
  }

  // Add comment to a post
  Future<Comment> addComment(String postId, String commentText) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/media/posts/$postId/comments'),
        headers: {
          'x-auth-token': token,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'text': commentText}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        // Add user_name as "You" for current user's comments
        data['user_name'] = 'You';
        return Comment.fromJson(data);
      } else {
        print('Add comment status: ${response.statusCode}');
        print('Add comment body: ${response.body}');
        throw Exception('Failed to add comment: ${response.body}');
      }
    } catch (e) {
      print('Add comment error: $e');
      throw Exception('Error adding comment: $e');
    }
  }

  // Get comments for a post
  Future<List<Comment>> getComments(String postId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/media/posts/$postId/comments'),
        headers: {
          'x-auth-token': token,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Comment.fromJson(json)).toList();
      } else {
        print('Get comments status: ${response.statusCode}');
        print('Get comments body: ${response.body}');
        throw Exception('Failed to load comments: ${response.body}');
      }
    } catch (e) {
      print('Get comments error: $e');
      throw Exception('Error fetching comments: $e');
    }
  }
}