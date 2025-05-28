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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            Fluttertoast.showToast(
              msg: "Registered successfully!",
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset("assets/images/logo2.png", width: 300, height: 300),
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
                          state is AuthLoading ? "Registering..." : "Register",
                      onTap:
                          state is AuthLoading
                              ? null
                              : () {
                                final name = _nameController.text.trim();
                                final email = _emailController.text.trim();
                                final password =
                                    _passwordController.text.trim();

                                if (name.isNotEmpty &&
                                    email.isNotEmpty &&
                                    password.isNotEmpty) {
                                  final user = UserModel(
                                    name: name,
                                    email: email,
                                    password: password,
                                  );
                                  context.read<AuthBloc>().add(
                                    SignupEvent(user),
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
        ),
      ),
    );
  }
}
