import 'package:client/core/themes/pallete.dart';
import 'package:client/features/profile/bloc/profile_bloc.dart';
import 'package:client/features/profile/models/profile_model.dart';
import 'package:client/features/profile/view/widgets/post_comment_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timeago/timeago.dart' as timeago;

class ProfilePostWidget extends StatelessWidget {
  final Post post;
  final String currentUserName;

  const ProfilePostWidget({
    Key? key,
    required this.post,
    required this.currentUserName,
  }) : super(key: key);

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
              comments: post.comments,
              postId: post.id,
              onAddComment: (commentText) {
                context.read<ProfileBloc>().add(
                  AddCommentEvent(post.id, commentText),
                );
              },
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      buildWhen: (previous, current) {
        // Only rebuild for PostLiked events for this post or ProfileLoaded state
        if (current is PostLiked) {
          return current.postId == post.id;
        }
        return current is ProfileLoaded;
      },
      builder: (context, state) {
        // Get the current post state
        Post currentPost = post;
        if (state is ProfileLoaded) {
          // Find the updated post in the loaded profile
          currentPost = state.profile.posts.firstWhere(
            (p) => p.id == post.id,
            orElse: () => post,
          );
        } else if (state is PostLiked && state.postId == post.id) {
          // Update only when it's a like event for this post
          currentPost = post.copyWith(
            likedByUser: state.isLiked,
            totalLikes:
                state.isLiked ? post.totalLikes + 1 : post.totalLikes - 1,
          );
        }

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
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
                    const CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.person, size: 20, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentUserName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Pallete.blackColor,
                            ),
                          ),
                          Text(
                            timeago.format(currentPost.createdAt),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Post Content
              if (currentPost.content != null &&
                  currentPost.content!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    currentPost.content!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Pallete.blackColor,
                    ),
                  ),
                ),

              // Post Image
              if (currentPost.mediaUrl != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: ClipRRect(
                    child: Image.network(
                      currentPost.mediaUrl!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) => Container(
                            height: 200,
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
                          height: 200,
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

              // Actions Section
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Like Button with debounce
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            // Don't allow rapid clicking
                            if (state is! ProfileLoading) {
                              context.read<ProfileBloc>().add(
                                LikePostEvent(currentPost.id),
                              );
                            }
                          },
                          icon: Icon(
                            currentPost.likedByUser
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color:
                                currentPost.likedByUser
                                    ? Colors.red
                                    : Colors.grey[600],
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          currentPost.totalLikes.toString(),
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    // Comment Button
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => _showComments(context),
                          icon: Icon(
                            Icons.comment_outlined,
                            color: Colors.grey[600],
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          currentPost.comments.length.toString(),
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
