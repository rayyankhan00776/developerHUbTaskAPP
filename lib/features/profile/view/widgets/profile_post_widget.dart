// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:client/core/themes/pallete.dart';
import 'package:client/features/profile/bloc/profile_bloc.dart';
import 'package:client/features/profile/models/profile_model.dart';
import 'package:client/features/profile/view/widgets/post_comment_widget.dart';
import 'package:client/features/profile/view/widgets/profile_header_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timeago/timeago.dart' as timeago;

class ProfilePostWidget extends StatelessWidget {
  final Post post;
  final String currentUserName;

  const ProfilePostWidget({
    super.key,
    required this.post,
    required this.currentUserName,
  });

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
        }

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
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.grey[300],
                      backgroundImage:
                          currentPost.profilePicUrl != null &&
                                  currentPost.profilePicUrl!.isNotEmpty
                              ? NetworkImage(currentPost.profilePicUrl!)
                              : null,
                      child:
                          (currentPost.profilePicUrl == null ||
                                  currentPost.profilePicUrl!.isEmpty)
                              ? const Icon(
                                Icons.person,
                                size: 20,
                                color: Colors.white,
                              )
                              : null,
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
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder:
                              (_) => FullScreenImagePage(
                                imageUrl: currentPost.mediaUrl!,
                              ),
                        ),
                      );
                    },
                    child: Hero(
                      tag: currentPost.mediaUrl!,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          currentPost.mediaUrl!,
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
                    const Spacer(),
                    // Update Button
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      tooltip: 'Edit Post',
                      onPressed: () async {
                        final controller = TextEditingController(
                          text: currentPost.content,
                        );
                        final result = await showDialog<String>(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: const Text('Edit Post'),
                                content: TextField(
                                  controller: controller,
                                  maxLines: 4,
                                  decoration: const InputDecoration(
                                    labelText: 'Content',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed:
                                        () => Navigator.pop(
                                          context,
                                          controller.text,
                                        ),
                                    child: const Text('Update'),
                                  ),
                                ],
                              ),
                        );
                        if (result != null &&
                            result.trim().isNotEmpty &&
                            result != currentPost.content) {
                          context.read<ProfileBloc>().add(
                            UpdatePostEvent(
                              postId: currentPost.id,
                              content: result.trim(),
                            ),
                          );
                        }
                      },
                    ),
                    // Delete Button
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      tooltip: 'Delete Post',
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: const Text('Delete Post'),
                                content: const Text(
                                  'Are you sure you want to delete this post?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed:
                                        () => Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed:
                                        () => Navigator.pop(context, true),
                                    child: const Text('Delete'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                        );
                        if (confirm == true) {
                          context.read<ProfileBloc>().add(
                            DeletePostEvent(currentPost.id),
                          );
                        }
                      },
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
