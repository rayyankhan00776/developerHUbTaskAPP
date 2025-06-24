// ignore_for_file: deprecated_member_use

import 'package:client/features/auth/view/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/themes/pallete.dart';
import '../../models/profile_model.dart';
import '../../bloc/profile_bloc.dart';
import '../widgets/create_post.widget.dart';
import '../widgets/profile_header_widget.dart';
import '../widgets/profile_post_widget.dart';
import 'followers_following_list_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  ProfileModel? _cachedProfile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    context.read<ProfileBloc>().add(LoadProfileEvent());
  }

  void _showCreatePost() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const CreatePostWidget(),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Your Profile',
          style: TextStyle(
            color: Pallete.blackColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Pallete.blackColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Pallete.blackColor),
            tooltip: 'Logout',
            onPressed: () async {
              // Clear shared preferences
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              // Navigate to LoginPage and remove all previous routes
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreatePost,
        backgroundColor: Pallete.greenColor,
        child: const Icon(Icons.add),
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoaded) {
            _cachedProfile = state.profile;
          }
        },
        builder: (context, state) {
          // Show loading indicator only on initial load
          if (state is ProfileLoading && _cachedProfile == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProfileError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${state.message}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadProfile,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Use cached profile data while loading to prevent blank screen
          final profile =
              state is ProfileLoaded ? state.profile : _cachedProfile;

          if (profile == null) {
            return const Center(child: Text('No profile data available'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<ProfileBloc>().add(RefreshProfileEvent());
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Header with loading overlay if needed
                  Stack(
                    children: [
                      ProfileHeaderWidget(
                        profile: profile,
                        onFollowersTap: () async {
                          context.read<ProfileBloc>().add(LoadFollowersEvent());
                          final state = await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder:
                                  (
                                    context,
                                  ) => BlocBuilder<ProfileBloc, ProfileState>(
                                    builder: (context, state) {
                                      if (state is FollowersLoaded) {
                                        final users =
                                            state.followers
                                                .map(
                                                  (e) =>
                                                      ProfileModel.fromJson(e),
                                                )
                                                .toList();
                                        return FollowersFollowingListPage(
                                          title: 'Followers',
                                          users: users,
                                        );
                                      } else if (state is ProfileLoading) {
                                        return const Scaffold(
                                          body: Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        );
                                      } else if (state is ProfileError) {
                                        return Scaffold(
                                          body: Center(
                                            child: Text(
                                              'Error: \\${state.message}',
                                            ),
                                          ),
                                        );
                                      }
                                      return const Scaffold(
                                        body: Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      );
                                    },
                                  ),
                            ),
                          );
                        },
                        onFollowingTap: () async {
                          context.read<ProfileBloc>().add(LoadFollowingEvent());
                          final state = await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder:
                                  (
                                    context,
                                  ) => BlocBuilder<ProfileBloc, ProfileState>(
                                    builder: (context, state) {
                                      if (state is FollowingLoaded) {
                                        final users =
                                            state.following
                                                .map(
                                                  (e) =>
                                                      ProfileModel.fromJson(e),
                                                )
                                                .toList();
                                        return FollowersFollowingListPage(
                                          title: 'Following',
                                          users: users,
                                        );
                                      } else if (state is ProfileLoading) {
                                        return const Scaffold(
                                          body: Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        );
                                      } else if (state is ProfileError) {
                                        return Scaffold(
                                          body: Center(
                                            child: Text(
                                              'Error: \\${state.message}',
                                            ),
                                          ),
                                        );
                                      }
                                      return const Scaffold(
                                        body: Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      );
                                    },
                                  ),
                            ),
                          );
                        },
                      ),
                      if (state is ProfileLoading)
                        Positioned.fill(
                          child: Container(
                            color: Colors.white.withOpacity(0.5),
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Your Posts',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Pallete.blackColor,
                      ),
                    ),
                  ),
                  if (profile.posts.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.post_add,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No posts yet',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Create your first post by tapping the + button',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...profile.posts.map(
                      (post) => ProfilePostWidget(
                        post: post,
                        currentUserName: profile.name,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
