import 'package:flutter/material.dart';

class DrawerTextButton extends StatelessWidget {
  const DrawerTextButton(
      {required this.onPressed,
      required this.icon,
      required this.data,
      super.key});
  final void Function()? onPressed;
  final IconData? icon;
  final String data;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            Icon(
              icon,
              size: 25,
            ),
            const SizedBox(
              width: 15,
            ),
            Text(
              data,
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
