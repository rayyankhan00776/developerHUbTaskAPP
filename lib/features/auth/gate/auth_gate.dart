import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:client/features/dashboard/view/pages/feed_page.dart'; // create this
import 'package:client/features/auth/view/pages/login_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('auth_token');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data == true) {
          return const FeedPage();
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
