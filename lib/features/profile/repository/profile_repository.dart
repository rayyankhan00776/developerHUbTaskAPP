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
        throw Exception('Failed to load profile: ${response.body}');
      }
    } catch (e) {
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
        throw Exception('Failed to update profile picture: $responseBody');
      }
    } catch (e) {
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
        throw Exception('Failed to delete profile picture: ${response.body}');
      }
    } catch (e) {
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
        throw Exception('Failed to create post: $responseBody');
      }
    } catch (e) {
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
        throw Exception('Failed to load posts: ${response.body}');
      }
    } catch (e) {
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
        throw Exception('Failed to like post: ${response.body}');
      }
    } catch (e) {
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
        // Use the user_name from backend response, do not override
        return Comment.fromJson(data);
      } else {
        throw Exception('Failed to add comment: ${response.body}');
      }
    } catch (e) {
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
        throw Exception('Failed to load comments: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching comments: $e');
    }
  }

  // Get current user's followers
  Future<List<Map<String, dynamic>>> getFollowers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) throw Exception('No authentication token found');
    final response = await http.get(
      Uri.parse('$baseUrl/auth/followers'),
      headers: {
        'x-auth-token': token,
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to load followers: ${response.body}');
    }
  }

  // Get current user's following
  Future<List<Map<String, dynamic>>> getFollowing() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) throw Exception('No authentication token found');
    final response = await http.get(
      Uri.parse('$baseUrl/auth/following'),
      headers: {
        'x-auth-token': token,
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to load following: ${response.body}');
    }
  }

  // Follow/unfollow a user
  Future<bool> followUser(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) throw Exception('No authentication token found');
    final response = await http.post(
      Uri.parse('$baseUrl/auth/follow/$userId'),
      headers: {
        'x-auth-token': token,
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['following'] == true;
    } else {
      throw Exception('Failed to follow/unfollow user: ${response.body}');
    }
  }

  // Delete a post
  Future<void> deletePost(String postId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) {
        throw Exception('No authentication token found');
      }
      final response = await http.delete(
        Uri.parse('$baseUrl/media/posts/$postId'),
        headers: {'x-auth-token': token},
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to delete post: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error deleting post: $e');
    }
  }

  // Update a post
  Future<Post> updatePost({
    required String postId,
    String? content,
    String? mediaUrl,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) {
        throw Exception('No authentication token found');
      }
      final response = await http.put(
        Uri.parse('$baseUrl/media/posts/$postId'),
        headers: {'x-auth-token': token, 'Content-Type': 'application/json'},
        body: json.encode({
          if (content != null) 'content': content,
          if (mediaUrl != null) 'media_url': mediaUrl,
        }),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // The updated post is in data['post']
        return Post.fromJson(data['post']);
      } else {
        throw Exception('Failed to update post: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error updating post: $e');
    }
  }
}
