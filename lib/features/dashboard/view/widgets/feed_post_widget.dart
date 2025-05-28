import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'post_comments_widget.dart';
import '../../../../core/themes/pallete.dart';
import '../../bloc/feed_bloc.dart';
import '../../models/post.dart';

class FeedPostWidget extends StatelessWidget {
  final Post post;
  const FeedPostWidget({super.key, required this.post});
  void _showComments(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.5,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: PostCommentsWidget(
              comments: post.comments,
              postId: post.postId,
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Info Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey[300],
                  backgroundImage:
                      post.profilePicUrl != null
                          ? NetworkImage(post.profilePicUrl!)
                          : null,
                  child:
                      post.profilePicUrl == null
                          ? const Icon(Icons.person, color: Colors.grey)
                          : null,
                ),
                const SizedBox(width: 10),
                Text(
                  post.userName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Pallete.blackColor,
                  ),
                ),
              ],
            ),
          ), // Post Image
          if (post.mediaUrl != null)
            Image.network(
              post.mediaUrl!,
              height: 300,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder:
                  (context, error, stackTrace) => Container(
                    height: 300,
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
                  height: 300,
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                );
              },
            ), // Actions Section
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            context.read<FeedBloc>().add(
                              LikePostEvent(post.postId),
                            );
                          },
                          icon: Icon(
                            post.likedByUser
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: post.likedByUser ? Colors.red : null,
                          ),
                        ),
                        Text(
                          post.totalLikes.toString(),
                          style: const TextStyle(
                            color: Pallete.blackColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => _showComments(context),
                          icon: const Icon(Icons.comment_outlined),
                        ),
                        Text(
                          post.comments.length.toString(),
                          style: const TextStyle(
                            color: Pallete.blackColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Pallete.blackColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (post.content != null)
                        Text(
                          post.content!,
                          style: const TextStyle(color: Pallete.blackColor),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
