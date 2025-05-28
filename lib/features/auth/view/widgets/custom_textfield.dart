import 'package:client/core/themes/pallete.dart';
import 'package:flutter/material.dart';

class CustomTextfield extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback? ontap;

  const CustomTextfield({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.obscure = false,
    this.ontap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width - 50,
        height: 77,
        child: TextFormField(
          controller: controller,
          obscureText: obscure,
          style: TextStyle(color: Pallete.blackColor),
          decoration: InputDecoration(
            labelText: label,

            hintText: hint,
            labelStyle: TextStyle(color: Pallete.blackColor),
            hintStyle: TextStyle(color: Pallete.blackColor),
          ),
        ),
      ),
    );
  }
}
