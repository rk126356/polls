import 'package:flutter/material.dart';

class AllTagsBox extends StatelessWidget {
  final String title;
  final Color backgroundColor;
  final VoidCallback onTap;

  const AllTagsBox({
    super.key,
    required this.title,
    required this.backgroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: backgroundColor,
        child: SizedBox(
          width: 105,
          height: 105,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
