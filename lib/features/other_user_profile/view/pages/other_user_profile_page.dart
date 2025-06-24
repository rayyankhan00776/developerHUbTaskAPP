import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../chat/view/pages/chat_page.dart';
import '../../bloc/other_user_profile_bloc.dart';
import '../../repository/other_user_profile_repository.dart';
import '../widgets/other_user_profile_header_widget.dart';
import '../widgets/other_user_profile_post_widget.dart';
import '../../models/other_user_profile_model.dart';
import 'package:client/core/constants/api.dart';

class OtherUserProfilePage extends StatelessWidget {
  final String userId;
  const OtherUserProfilePage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) =>
              OtherUserProfileBloc(OtherUserProfileRepository())
                ..add(LoadOtherUserProfileEvent(userId)),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Profile', style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.black),
          elevation: 0,
        ),
        body: BlocBuilder<OtherUserProfileBloc, OtherUserProfileState>(
          builder: (context, state) {
            if (state is OtherUserProfileLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is OtherUserProfileLoaded) {
              final profile = state.profile;
              return Stack(
                children: [
                  Column(
                    children: [
                      OtherUserProfileHeaderWidget(profile: profile),
                      const SizedBox(height: 10),
                      Expanded(
                        child: ListView.builder(
                          itemCount: profile.posts.length,
                          itemBuilder: (context, index) {
                            final post = profile.posts[index];
                            return OtherUserProfilePostWidget(
                              post: post,
                              userName: profile.username,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    bottom: 24,
                    right: 24,
                    child: FloatingActionButton(
                      backgroundColor: Colors.green,
                      child: const Icon(Icons.message),
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        // Optionally, you can get current user id if needed
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder:
                                (_) => ChatPage(
                                  otherUser: profile,
                                  authToken:
                                      prefs.getString('auth_token') ?? '',
                                  baseUrl: baseUrl,
                                ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            } else if (state is OtherUserProfileError) {
              return Center(child: Text(state.message));
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}
