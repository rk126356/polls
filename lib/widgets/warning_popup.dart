import 'package:flutter/material.dart';
import 'package:polls/const/colors.dart';
import 'package:polls/const/fonts.dart';
import 'package:provider/provider.dart';

import '../provider/user_provider.dart';

class WarningPopup extends StatelessWidget {
  final VoidCallback onOkPressed;
  final VoidCallback onNoPressed;

  const WarningPopup({
    Key? key,
    required this.onOkPressed,
    required this.onNoPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  Widget contentBox(BuildContext context) {
    final provider = Provider.of<UserProvider>(context);
    return Stack(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.only(
            top: 40,
            bottom: 16,
            left: 16,
            right: 16,
          ),
          margin: const EdgeInsets.only(top: 16),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: AppColors.fourthColor,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(
              color: Colors.blue, // Change border color here
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text(
                'warning!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'are you sure you want to proceed?',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              provider.isButtonLoading
                  ? const CircularProgressIndicator()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        ElevatedButton(
                          onPressed: onNoPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          child: Text(
                            'no',
                            style: AppFonts.buttonTextStyle
                                .copyWith(color: Colors.white),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: onOkPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          child: Text(
                            'yes',
                            style: AppFonts.buttonTextStyle
                                .copyWith(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ],
    );
  }
}
