// ignore_for_file: file_names

import 'package:client/core/themes/pallete.dart';
import 'package:client/features/auth/view/pages/login_page.dart';
import 'package:client/features/auth/view/pages/forgot_password_page.dart';
import 'package:client/features/auth/view/widgets/custom_button.dart';
import 'package:client/features/auth/view/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:client/features/auth/bloc/auth_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is PasswordChangeSuccess) {
            Fluttertoast.showToast(
              msg: "Password changed successfully!",
              backgroundColor: Colors.green,
              textColor: Colors.white,
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
            );
          } else if (state is AuthFailure) {
            Fluttertoast.showToast(
              msg: state.message.replaceAll('Exception:', '').trim(),
              backgroundColor: Colors.red,
              textColor: Colors.white,
            );
          }
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            final content = ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 24.0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/images/logo2.png",
                      width: 300,
                      height: 300,
                    ),
                    Text(
                      "Where Your Vibe Finds Its Tribe!",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 3,
                        color: Pallete.blackColor,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Change Your Password",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 3,
                        color: Pallete.blackColor,
                      ),
                    ),
                    const SizedBox(height: 15),
                    CustomTextfield(
                      hint: "xyz@mail.com",
                      label: "Email",
                      controller: _emailController,
                    ),
                    const SizedBox(height: 15),
                    CustomTextfield(
                      hint: "",
                      label: "Current Password",
                      controller: _currentPasswordController,
                      obscure: true,
                    ),
                    const SizedBox(height: 9),
                    CustomTextfield(
                      hint: "",
                      label: "New Password",
                      controller: _newPasswordController,
                      obscure: true,
                    ),
                    const SizedBox(height: 16),

                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        return CustomButton(
                          text:
                              state is AuthLoading
                                  ? "Processing..."
                                  : "Change Password",
                          onTap:
                              state is AuthLoading
                                  ? null
                                  : () {
                                    final email = _emailController.text.trim();
                                    final currentPassword =
                                        _currentPasswordController.text.trim();
                                    final newPassword =
                                        _newPasswordController.text.trim();

                                    if (email.isNotEmpty &&
                                        currentPassword.isNotEmpty &&
                                        newPassword.isNotEmpty) {
                                      context.read<AuthBloc>().add(
                                        ChangePasswordEvent(
                                          email,
                                          currentPassword,
                                          newPassword,
                                        ),
                                      );
                                    } else {
                                      Fluttertoast.showToast(
                                        msg: "Please fill all fields!",
                                        backgroundColor: Colors.orange,
                                        textColor: Colors.white,
                                      );
                                    }
                                  },
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ForgotPasswordPage(),
                          ),
                        );
                      },
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 35.0),
                          child: Text(
                            "Forgot Password?",
                            style: TextStyle(
                              color: Pallete.gradient3,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                        );
                      },
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "Did you Remember? ",
                              style: TextStyle(
                                color: Pallete.blackColor,
                                fontSize: 16,
                              ),
                            ),
                            TextSpan(
                              text: "Login",
                              style: TextStyle(
                                color: Pallete.gradient3,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
            if (constraints.maxHeight > 700) {
              return Center(child: SingleChildScrollView(child: content));
            } else {
              return SingleChildScrollView(child: Center(child: content));
            }
          },
        ),
      ),
    );
  }
}
