import 'package:flutter/material.dart';

class MenuCard extends StatelessWidget {
  final String title;
  final IconData iconData;

  MenuCard({
    required this.title,
    required this.iconData,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(
              iconData,
              size: 24,
            ),
            SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 4),

          ],
        ),
      ),
    );
  }
}