import 'package:flutter/material.dart';
import 'package:polls/const/fonts.dart';

class CustomErrorBox extends StatelessWidget {
  const CustomErrorBox({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
            child: Text(
          text,
          style: AppFonts.bodyTextStyle,
        )),
      ),
    );
  }
}
