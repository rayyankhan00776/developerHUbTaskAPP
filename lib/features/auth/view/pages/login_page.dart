import 'package:client/core/themes/pallete.dart';
import 'package:client/features/auth/view/pages/Change_password_page.dart';
import 'package:client/features/auth/view/pages/signUp_page.dart';
import 'package:client/features/auth/view/widgets/custom_button.dart';
import 'package:client/features/auth/view/widgets/custom_textfield.dart';
import 'package:client/features/dashboard/view/pages/feed_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:client/features/auth/bloc/auth_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
export 'package:client/features/auth/view/pages/forgot_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            Fluttertoast.cancel();
            Fluttertoast.showToast(
              msg: "Login successful!",
              backgroundColor: Colors.green,
              textColor: Colors.white,
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const FeedPage()),
            );
          } else if (state is AuthFailure) {
            Fluttertoast.cancel();
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
                      "Login Here",
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
                    const SizedBox(height: 9),
                    CustomTextfield(
                      hint: "",
                      label: "Password",
                      controller: _passwordController,
                      obscure: true,
                    ),
                    const SizedBox(height: 16),

                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        return CustomButton(
                          text:
                              state is AuthLoading ? "Logging in..." : "Login",
                          onTap:
                              state is AuthLoading
                                  ? null
                                  : () {
                                    final email = _emailController.text.trim();
                                    final password =
                                        _passwordController.text.trim();
                                    if (email.isNotEmpty &&
                                        password.isNotEmpty) {
                                      context.read<AuthBloc>().add(
                                        LoginEvent(email, password),
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
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 35.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ChangePasswordPage(),
                                ),
                              );
                            },
                            child: Text(
                              "Change Password?",
                              style: TextStyle(
                                color: Pallete.blackColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SignUpPage()),
                        );
                      },
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "Doesn't Have an Account? ",
                              style: TextStyle(
                                color: Pallete.blackColor,
                                fontSize: 16,
                              ),
                            ),
                            TextSpan(
                              text: "Register",
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
