import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../../const/colors.dart';
import '../../const/fonts.dart';
import '../../utils/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: AppColors.secondaryColor,
        title: Text(
          'settings',
          style: AppFonts.headingTextStyle.copyWith(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          ListTile(
            leading: const Icon(CupertinoIcons.info,
                color: AppColors.secondaryColor),
            title: const Text("About Us"),
            trailing: const Icon(
              CupertinoIcons.forward,
              color: AppColors.secondaryColor,
            ),
            onTap: () {
              open('https://raihansk.com/real-facts/');
            },
          ),
          ListTile(
            leading: const Icon(CupertinoIcons.mail,
                color: AppColors.secondaryColor),
            title: const Text("Contact Us"),
            trailing: const Icon(
              CupertinoIcons.forward,
              color: AppColors.secondaryColor,
            ),
            onTap: () {
              open('https://raihansk.com/contact/');
            },
          ),
          ListTile(
            leading: const Icon(CupertinoIcons.lock,
                color: AppColors.secondaryColor),
            title: const Text("Privacy Policy"),
            trailing: const Icon(
              CupertinoIcons.forward,
              color: AppColors.secondaryColor,
            ),
            onTap: () {
              open(
                  'https://raihansk.com/real-facts/privacy-policy-real-facts/');
            },
          ),
          if (kDebugMode)
            ListTile(
              leading: const Icon(CupertinoIcons.lock,
                  color: AppColors.secondaryColor),
              title: const Text("Clear Data"),
              trailing: const Icon(
                CupertinoIcons.forward,
                color: AppColors.secondaryColor,
              ),
              onTap: () async {
                SharedPreferences preferences =
                    await SharedPreferences.getInstance();
                await preferences.clear();
              },
            ),
        ],
      ),
    );
  }
}
