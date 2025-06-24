import 'package:client/core/themes/pallete.dart';
import 'package:client/features/dashboard/models/comment.dart' as dash;
import 'package:client/features/other_user_profile/bloc/other_user_profile_bloc.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../models/other_user_profile_model.dart';
import 'package:client/features/dashboard/view/widgets/post_comments_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OtherUserProfilePostWidget extends StatelessWidget {
  final Post post;
  final String userName;
  const OtherUserProfilePostWidget({
    super.key,
    required this.post,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    // No local BlocProvider, just use parent bloc
    return _PostContent(post: post, userName: userName);
  }
}

class _PostContent extends StatelessWidget {
  final Post post;
  final String userName;
  const _PostContent({required this.post, required this.userName});

  void _showComments(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: PostCommentsWidget(
              comments:
                  post.comments
                      .map(
                        (c) => dash.Comment(
                          id: c.id,
                          text: c.text,
                          userId: c.userId,
                          userName: c.userName,
                          profilePicUrl: c.profilePicUrl,
                          createdAt: c.createdAt,
                        ),
                      )
                      .toList(),
              postId: post.id,
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.13),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                GestureDetector(
                  onTap:
                      post.profilePicUrl != null &&
                              post.profilePicUrl!.isNotEmpty
                          ? () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder:
                                    (_) => Scaffold(
                                      backgroundColor: Colors.black,
                                      body: GestureDetector(
                                        onTap:
                                            () => Navigator.of(context).pop(),
                                        child: Center(
                                          child: Hero(
                                            tag: post.profilePicUrl!,
                                            child: Image.network(
                                              post.profilePicUrl!,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                              ),
                            );
                          }
                          : null,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.grey[300],
                    backgroundImage:
                        (post.profilePicUrl != null &&
                                post.profilePicUrl!.isNotEmpty)
                            ? NetworkImage(post.profilePicUrl!)
                            : null,
                    child:
                        (post.profilePicUrl == null ||
                                post.profilePicUrl!.isEmpty)
                            ? const Icon(
                              Icons.person,
                              size: 20,
                              color: Colors.white,
                            )
                            : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Pallete.blackColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      Text(
                        timeago.format(post.createdAt),
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Post Content
          if (post.content != null && post.content!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                post.content!,
                style: const TextStyle(fontSize: 14, color: Pallete.blackColor),
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                maxLines: 5,
              ),
            ),
          // Post Image
          if (post.mediaUrl != null && post.mediaUrl!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder:
                          (_) => Scaffold(
                            backgroundColor: Colors.black,
                            body: GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              child: Center(
                                child: Hero(
                                  tag: post.mediaUrl!,
                                  child: Image.network(
                                    post.mediaUrl!,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          ),
                    ),
                  );
                },
                child: Hero(
                  tag: post.mediaUrl!,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      post.mediaUrl!,
                      width: double.infinity,
                      fit: BoxFit.contain,
                      errorBuilder:
                          (context, error, stackTrace) => Container(
                            width: double.infinity,
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.error,
                              size: 50,
                              color: Colors.grey,
                            ),
                          ),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: double.infinity,
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          // Actions Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Like Button
                IconButton(
                  onPressed: () {
                    context.read<OtherUserProfileBloc>().add(
                      LikeOtherUserProfilePostEvent(post.id),
                    );
                  },
                  icon: Icon(
                    post.likedByUser ? Icons.favorite : Icons.favorite_border,
                    color: post.likedByUser ? Colors.red : Colors.grey[600],
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 4),
                Text(
                  post.totalLikes.toString(),
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(width: 20),
                // Comment Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () => _showComments(context),
                      icon: const Icon(Icons.comment, color: Colors.grey),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      post.comments.length.toString(),
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
