import 'package:client/core/themes/pallete.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;

  const CustomButton({super.key, required this.text, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width - 60,
        height: 66,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Pallete.blackColor,
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: Pallete.whiteColor,
              fontSize: 21,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
