// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../models/profile_model.dart';

class FollowersFollowingListPage extends StatelessWidget {
  final String title;
  final List<ProfileModel> users;

  const FollowersFollowingListPage({
    super.key,
    required this.title,
    required this.users,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(title, style: const TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body:
          users.isEmpty
              ? const Center(child: Text('No users found'))
              : ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.black.withOpacity(0.12),
                        width: 0.6,
                      ),
                    ),
                    child: ListTile(
                      leading:
                          user.profilePicUrl != null
                              ? CircleAvatar(
                                backgroundImage: NetworkImage(
                                  user.profilePicUrl!,
                                ),
                                backgroundColor: Colors.white,
                              )
                              : CircleAvatar(
                                backgroundColor: Colors.white,
                                radius: 24,
                                child: Icon(Icons.person, color: Colors.black),
                                // Add border
                              ),
                      title: Text(
                        user.name,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Optionally, add subtitle: Text(user.email),
                    ),
                  );
                },
              ),
    );
  }
}
