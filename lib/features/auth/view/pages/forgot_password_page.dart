import 'package:client/core/themes/pallete.dart';
import 'package:client/features/auth/view/widgets/custom_button.dart';
import 'package:client/features/auth/view/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:client/features/auth/bloc/auth_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:client/features/auth/view/pages/login_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  bool codeSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is ForgotPasswordCodeSent) {
            setState(() => codeSent = true);
            Fluttertoast.showToast(
              msg: "Reset code sent to email!",
              backgroundColor: Colors.green,
              textColor: Colors.white,
            );
          } else if (state is ForgotPasswordSuccess) {
            Fluttertoast.showToast(
              msg: "Password reset successful!",
              backgroundColor: Colors.green,
              textColor: Colors.white,
            );
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
              (route) => false,
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
                      "Forgot Password",
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
                    if (codeSent) ...[
                      const SizedBox(height: 15),
                      CustomTextfield(
                        hint: "6 digit code",
                        label: "Code",
                        controller: _codeController,
                      ),
                      const SizedBox(height: 15),
                      CustomTextfield(
                        hint: "",
                        label: "New Password",
                        controller: _newPasswordController,
                        obscure: true,
                      ),
                    ],
                    const SizedBox(height: 16),
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        return CustomButton(
                          text:
                              state is AuthLoading
                                  ? "Processing..."
                                  : codeSent
                                  ? "Reset Password"
                                  : "Send Code",
                          onTap:
                              state is AuthLoading
                                  ? null
                                  : () {
                                    final email = _emailController.text.trim();
                                    if (!codeSent) {
                                      if (email.isNotEmpty) {
                                        context.read<AuthBloc>().add(
                                          ForgotPasswordSendCodeEvent(email),
                                        );
                                      } else {
                                        Fluttertoast.showToast(
                                          msg: "Please enter your email!",
                                          backgroundColor: Colors.orange,
                                          textColor: Colors.white,
                                        );
                                      }
                                    } else {
                                      final code = _codeController.text.trim();
                                      final newPassword =
                                          _newPasswordController.text.trim();
                                      if (email.isNotEmpty &&
                                          code.isNotEmpty &&
                                          newPassword.isNotEmpty) {
                                        context.read<AuthBloc>().add(
                                          ForgotPasswordVerifyCodeEvent(
                                            email,
                                            code,
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
                                    }
                                  },
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "Remembered password? ",
                              style: TextStyle(
                                color: Pallete.blackColor,
                                fontSize: 16,
                              ),
                            ),
                            TextSpan(
                              text: "Back",
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
            // If content fits, center it. If not, scroll.
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
