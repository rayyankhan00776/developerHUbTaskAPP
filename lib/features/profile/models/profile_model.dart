class ProfileModel {
  final String id;
  final String name;
  final String email;
  final String? profilePicUrl;
  final List<Post> posts;
  final int followersCount;
  final int followingCount;

  ProfileModel({
    required this.id,
    required this.name,
    required this.email,
    this.profilePicUrl,
    required this.posts,
    required this.followersCount,
    required this.followingCount,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      profilePicUrl: json['profile_pic_url'],
      posts:
          (json['posts'] as List<dynamic>?)
              ?.map((postJson) => Post.fromJson(postJson))
              .toList() ??
          [],
      followersCount: json['followers_count'] ?? 0,
      followingCount: json['following_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profile_pic_url': profilePicUrl,
      'posts': posts.map((post) => post.toJson()).toList(),
      'followers_count': followersCount,
      'following_count': followingCount,
    };
  }

  ProfileModel copyWith({
    String? id,
    String? name,
    String? email,
    String? profilePicUrl,
    List<Post>? posts,
    int? followersCount,
    int? followingCount,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profilePicUrl: profilePicUrl ?? this.profilePicUrl,
      posts: posts ?? this.posts,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
    );
  }
}

class Post {
  final String id;
  final String? content;
  final String? mediaUrl;
  final DateTime createdAt;
  final int totalLikes;
  final bool likedByUser;
  final List<Comment> comments;
  final String? profilePicUrl;

  Post({
    required this.id,
    this.content,
    this.mediaUrl,
    required this.createdAt,
    required this.totalLikes,
    required this.likedByUser,
    required this.comments,
    this.profilePicUrl,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    // Debug print to see what backend returns
    return Post(
      id: json['id'] ?? '',
      content: json['content'],
      mediaUrl: json['media_url'],
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      totalLikes: json['total_likes'] ?? 0,
      likedByUser: json['liked_by_user'] ?? json['likedByUser'] ?? false,
      comments:
          (json['comments'] as List<dynamic>?)
              ?.map((commentJson) => Comment.fromJson(commentJson))
              .toList() ??
          [],
      profilePicUrl: json['profile_pic_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'media_url': mediaUrl,
      'created_at': createdAt.toIso8601String(),
      'total_likes': totalLikes,
      'liked_by_user': likedByUser,
      'comments': comments.map((comment) => comment.toJson()).toList(),
      'profile_pic_url': profilePicUrl,
    };
  }

  Post copyWith({
    String? id,
    String? content,
    String? mediaUrl,
    DateTime? createdAt,
    int? totalLikes,
    bool? likedByUser,
    List<Comment>? comments,
    String? profilePicUrl,
  }) {
    return Post(
      id: id ?? this.id,
      content: content ?? this.content,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      createdAt: createdAt ?? this.createdAt,
      totalLikes: totalLikes ?? this.totalLikes,
      likedByUser: likedByUser ?? this.likedByUser,
      comments: comments ?? this.comments,
      profilePicUrl: profilePicUrl ?? this.profilePicUrl,
    );
  }
}

class Comment {
  final String id;
  final String text;
  final String userId;
  final String? userName;
  final String? profilePicUrl;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.text,
    required this.userId,
    this.userName,
    this.profilePicUrl,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] ?? '',
      text: json['text'] ?? '',
      userId: json['user_id'] ?? '',
      userName: json['user_name'],
      profilePicUrl: json['profile_pic_url'],
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'user_id': userId,
      'user_name': userName,
      'profile_pic_url': profilePicUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
