import 'package:flutter/material.dart';
import 'package:polls/const/fonts.dart';

class ErrorPollBox extends StatelessWidget {
  const ErrorPollBox({super.key});

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
          'poll is deleted or someting went wrong!',
          style: AppFonts.bodyTextStyle,
        )),
      ),
    );
  }
}
