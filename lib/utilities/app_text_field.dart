import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.controller,
    required this.label,
    required this.validator,
    this.style,
    this.enabledBorder,
    this.focusedBorder,
    this.border,
    this.keyboardType,
    this.inputFormatters,
    this.suffixIcon,
    this.obscureText = false,
    super.key,
  });
  final TextEditingController controller;
  final String label;
  final TextStyle? style;
  final InputBorder? enabledBorder;
  final InputBorder? focusedBorder;
  final InputBorder? border;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? suffixIcon;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          suffixIcon: suffixIcon,
          label: Text(
            label,
            style: const TextStyle(color: Colors.white),
          ),
          enabledBorder: enabledBorder,
          focusedBorder: focusedBorder,
          border: border,
        ),
        style: style,
        validator: validator,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        obscureText: obscureText,
      ),
    );
  }
}
