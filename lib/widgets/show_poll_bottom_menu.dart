import 'package:flutter/material.dart';
import 'package:polls/const/colors.dart';
import 'package:polls/const/fonts.dart';

Widget buildListTile({
  required IconData icon,
  required String title,
  required VoidCallback onTap,
}) {
  return ListTile(
    leading: Icon(icon, color: AppColors.secondaryColor),
    title: Text(title, style: AppFonts.bodyTextStyle),
    onTap: onTap,
  );
}
