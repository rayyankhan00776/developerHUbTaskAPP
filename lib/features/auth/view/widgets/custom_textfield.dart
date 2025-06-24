import 'package:client/core/themes/pallete.dart';
import 'package:flutter/material.dart';

class CustomTextfield extends StatefulWidget {
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
  State<CustomTextfield> createState() => _CustomTextfieldState();
}

class _CustomTextfieldState extends State<CustomTextfield> {
  bool _obscureText = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscure;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width - 50,
        height: 77,
        child: TextFormField(
          controller: widget.controller,
          obscureText: _obscureText,
          style: TextStyle(color: Pallete.blackColor),
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hint,
            labelStyle: TextStyle(color: Pallete.blackColor),
            hintStyle: TextStyle(color: Pallete.blackColor),
            suffixIcon:
                widget.obscure
                    ? IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                        color: Pallete.blackColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    )
                    : null,
          ),
        ),
      ),
    );
  }
}
