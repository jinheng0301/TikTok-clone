import 'package:flutter/material.dart';
import 'package:tiktokerrr/constants.dart';

class TextInputFields extends StatelessWidget {
  late final TextEditingController controller;
  late final String labelText;
  late final IconData icon;
  late final bool isObscure;

  TextInputFields({
    required this.controller,
    required this.icon,
    this.isObscure = false,
    required this.labelText,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon),
        labelStyle: TextStyle(
          fontSize: 20,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide(color: borderColor),
        ),
      ),
    );
  }
}
