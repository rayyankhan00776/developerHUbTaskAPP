class OtherUserProfileModel {
  final String id;
  final String username;
  final String? profilePicUrl;
  final List<Post> posts;
  final int followersCount;
  final int followingCount;
  final bool isFollowing;

  OtherUserProfileModel({
    required this.id,
    required this.username,
    this.profilePicUrl,
    required this.posts,
    required this.followersCount,
    required this.followingCount,
    required this.isFollowing,
  });

  factory OtherUserProfileModel.fromJson(Map<String, dynamic> json) {
    return OtherUserProfileModel(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      profilePicUrl: json['profile_pic_url'],
      posts:
          (json['posts'] as List<dynamic>? ?? [])
              .map((postJson) => Post.fromJson(postJson))
              .toList(),
      followersCount: json['followers_count'] ?? 0,
      followingCount: json['following_count'] ?? 0,
      isFollowing: json['is_following'] ?? false,
    );
  }
}

class Post {
  final String id;
  final String? content;
  final String? mediaUrl;
  final DateTime createdAt;
  final int totalLikes;
  final String? profilePicUrl;
  final List<Comment> comments;
  final bool likedByUser;

  Post({
    required this.id,
    this.content,
    this.mediaUrl,
    required this.createdAt,
    required this.totalLikes,
    this.profilePicUrl,
    required this.comments,
    required this.likedByUser,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    bool likedByUser = false;
    if (json['liked_by_user'] is bool) {
      likedByUser = json['liked_by_user'] ?? false;
    } else if (json['liked_by_user'] is int) {
      likedByUser = json['liked_by_user'] == 1;
    }
    return Post(
      id: json['id'] ?? '',
      content: json['content'],
      mediaUrl: json['media_url'],
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      totalLikes: json['total_likes'] ?? 0,
      profilePicUrl: json['profile_pic_url'],
      comments:
          (json['comments'] as List<dynamic>? ?? [])
              .map((commentJson) => Comment.fromJson(commentJson))
              .toList(),
      likedByUser: likedByUser,
    );
  }
}

class Comment {
  final String id;
  final String text;
  final String userId;
  final String userName;
  final String? profilePicUrl;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.text,
    required this.userId,
    required this.userName,
    this.profilePicUrl,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      userName: json['user_name']?.toString() ?? 'Unknown User',
      profilePicUrl: json['profile_pic_url']?.toString(),
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'].toString())
              : DateTime.now(),
    );
  }
}
