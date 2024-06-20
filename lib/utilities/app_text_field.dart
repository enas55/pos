import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.controller,
    required this.label,
    required this.validator,
    this.enabledBorder,
    this.focusedBorder,
    this.border,
    this.keyboardType,
    this.inputFormatters,
    this.suffixIcon,
    this.obscureText = false,
    this.color,
    super.key,
  });
  final TextEditingController controller;
  final String label;
  final InputBorder? enabledBorder;
  final InputBorder? focusedBorder;
  final InputBorder? border;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? suffixIcon;
  final bool obscureText;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          suffixIcon: suffixIcon,
          label: Text(
            label,
            style: TextStyle(color: color),
          ),
          enabledBorder: enabledBorder,
          focusedBorder: focusedBorder,
          border: border,
        ),
        style: TextStyle(
          color: color,
          fontSize: 16,
        ),
        validator: validator,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        obscureText: obscureText,
      ),
    );
  }
}
