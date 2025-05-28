import 'comment.dart';

class Post {
  final String postId;
  final String userId;
  final String userName;
  final String? profilePicUrl;
  final String? content;
  final String? mediaUrl;
  final DateTime createdAt;
  final int totalLikes;
  final bool likedByUser;
  final List<Comment> comments;

  Post({
    required this.postId,
    required this.userId,
    required this.userName,
    this.profilePicUrl,
    this.content,
    this.mediaUrl,
    required this.createdAt,
    required this.totalLikes,
    required this.likedByUser,
    required this.comments,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      postId: json['post_id'] as String,
      userId: json['user_id'] as String,
      userName: json['user_name'] as String,
      profilePicUrl: json['profile_pic_url'] as String?,
      content: json['content'] as String?,
      mediaUrl: json['media_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      totalLikes: json['total_likes'] as int,
      likedByUser: json['liked_by_user'] as bool,
      comments:
          (json['comments'] as List)
              .map((comment) => Comment.fromJson(comment))
              .toList(),
    );
  }
}
