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
