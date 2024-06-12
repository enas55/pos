import 'package:flutter/material.dart';

class GridViewItems extends StatelessWidget {
  const GridViewItems({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    super.key,
  });
  final String label;
  final IconData icon;
  final Color color;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 40,
        height: 70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.3),
              radius: 30,
              child: Icon(
                icon,
                size: 35,
                color: color,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
