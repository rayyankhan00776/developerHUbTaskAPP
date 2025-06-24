// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:client/features/other_user_profile/bloc/other_user_profile_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/other_user_profile_model.dart';

class OtherUserProfileHeaderWidget extends StatelessWidget {
  final OtherUserProfileModel profile;
  const OtherUserProfileHeaderWidget({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, // Ensure header is white
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.grey[300],
            backgroundImage:
                profile.profilePicUrl != null &&
                        profile.profilePicUrl!.isNotEmpty
                    ? NetworkImage(profile.profilePicUrl!)
                    : null,
            child:
                (profile.profilePicUrl == null ||
                        profile.profilePicUrl!.isEmpty)
                    ? const Icon(Icons.person, size: 40, color: Colors.white)
                    : null,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        profile.username,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black, // Force black heading
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Builder(
                      builder: (context) {
                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                profile.isFollowing
                                    ? Colors.grey[300]
                                    : Colors.green,
                            foregroundColor:
                                profile.isFollowing
                                    ? Colors.black
                                    : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 8,
                            ),
                          ),
                          onPressed: () {
                            context.read<OtherUserProfileBloc>().add(
                              FollowOrUnfollowOtherUserEvent(profile.id),
                            );
                          },
                          child: Text(
                            profile.isFollowing ? 'Unfollow' : 'Follow',
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        '${profile.posts.length} Posts',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Flexible(
                      child: Text(
                        '${profile.followersCount} Followers',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[400],
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Flexible(
                      child: Text(
                        '${profile.followingCount} Following',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[400],
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
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
  }
}
