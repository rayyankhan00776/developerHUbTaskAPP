import 'package:client/features/auth/gate/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:client/core/themes/theme.dart';
import 'package:client/features/auth/bloc/auth_bloc.dart';
import 'package:client/features/auth/repository/auth_repository.dart';
import 'package:client/features/dashboard/repositories/feed_repository.dart';
import 'package:client/features/dashboard/bloc/feed_bloc.dart';
import 'package:client/features/profile/repository/profile_repository.dart';
import 'package:client/features/profile/bloc/profile_bloc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize repositories
  final authRepository = AuthRepository();
  final feedRepository = FeedRepository();
  final profileRepository = ProfileRepository();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc(authRepository)),
        BlocProvider(create: (_) => FeedBloc(repository: feedRepository)),
        BlocProvider(create: (_) => ProfileBloc(repository: profileRepository)),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkThemeMode,
      home: const AuthGate(),
    );
  }
}
