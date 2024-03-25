import 'dart:math';

import 'package:flutter/material.dart';
import 'package:polls/const/fonts.dart';

import '../const/colors.dart';

class TagsBox extends StatelessWidget {
  final String title;

  const TagsBox({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: predefinedColors[Random().nextInt(predefinedColors.length)],
        child: SizedBox(
          width: 90,
          height: 90,
          child: Center(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: AppFonts.bodyTextStyle.copyWith(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
