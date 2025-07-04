// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:client/core/themes/pallete.dart';
import 'package:client/features/auth/view/pages/login_page.dart';
import 'package:client/features/auth/view/widgets/custom_button.dart';
import 'package:client/features/auth/view/widgets/custom_textfield.dart';
import 'package:client/features/auth/bloc/auth_bloc.dart';
import 'package:client/features/auth/models/user_model.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  final RegExp _nameRegExp = RegExp(r'^(?=.*\d)(?=.*_)[a-zA-Z0-9._]+$');

  bool _isValidName(String name) {
    // Must contain at least one number, one underscore, only . and _ as special chars, no spaces
    return _nameRegExp.hasMatch(name) &&
        name.contains(RegExp(r'\d')) &&
        name.contains('_') &&
        !name.contains(' ') &&
        !name.contains(RegExp(r'[^a-zA-Z0-9._]'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            Fluttertoast.showToast(
              msg: "Registered successfully! Please login.",
              backgroundColor: Colors.green,
              textColor: Colors.white,
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
            );
          } else if (state is AuthFailure) {
            String msg = state.message.replaceAll('Exception:', '').trim();
            if (msg.toLowerCase().contains('user already exists') ||
                msg.toLowerCase().contains('name')) {
              msg = "Name already taken, please choose another.";
            }
            Fluttertoast.showToast(
              msg: msg,
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
                      "SignUp Here",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 3,
                        color: Pallete.blackColor,
                      ),
                    ),
                    const SizedBox(height: 15),

                    CustomTextfield(
                      hint: '',
                      label: "Name",
                      controller: _nameController,
                    ),
                    const SizedBox(height: 9),
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
                              state is AuthLoading
                                  ? "Registering..."
                                  : "Register",
                          onTap:
                              state is AuthLoading
                                  ? null
                                  : () {
                                    final name = _nameController.text.trim();
                                    final email = _emailController.text.trim();
                                    final password =
                                        _passwordController.text.trim();
                                    if (name.isEmpty ||
                                        email.isEmpty ||
                                        password.isEmpty) {
                                      Fluttertoast.showToast(
                                        msg: "Please fill all fields!",
                                        backgroundColor: Colors.orange,
                                        textColor: Colors.white,
                                      );
                                      return;
                                    }
                                    if (!_isValidName(name)) {
                                      Fluttertoast.showToast(
                                        msg:
                                            "Name must contain at least one number, one underscore, only . and _ as special chars, and no spaces.",
                                        backgroundColor: Colors.orange,
                                        textColor: Colors.white,
                                      );
                                      return;
                                    }
                                    context.read<AuthBloc>().add(
                                      SignupEvent(
                                        UserModel(
                                          name: name,
                                          email: email,
                                          password: password,
                                        ),
                                      ),
                                    );
                                  },
                        );
                      },
                    ),
                    const SizedBox(height: 10),

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
                              text: "Have an Account? ",
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
