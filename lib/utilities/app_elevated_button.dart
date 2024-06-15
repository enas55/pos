import 'package:flutter/material.dart';
import 'package:pos/utilities/my_palette.dart';

class AppElevatedButton extends StatelessWidget {
  const AppElevatedButton({
    required this.label,
    required this.onPressed,
    super.key,
  });
  final String label;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            fixedSize: const Size(double.maxFinite, 60),
            backgroundColor: primary[400],
            foregroundColor: Colors.white),
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}
