// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:polls/const/fonts.dart';
import 'package:polls/pages/profile/inside/my_activity_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../const/colors.dart';
import '../pages/extra/settings_screen.dart';
import '../pages/profile/inside/inside_user_lists_screen.dart';
import '../pages/profile/inside/inside_user_polls_screen.dart';
import '../pages/profile/my_bookmarks_screen.dart';
import '../provider/user_provider.dart';
import '../utils/url_launcher.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  String version = '1.0.0';

  void checkVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    setState(() {
      version = packageInfo.version;
    });
  }

  @override
  void initState() {
    super.initState();
    checkVersion();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<UserProvider>(context, listen: false);
    return Drawer(
      child: ListView(
        // Remove padding
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              provider.userData.name,
              style: AppFonts.bodyTextStyle
                  .copyWith(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            accountEmail: Text(
              provider.userData.email ?? '',
              style: AppFonts.bodyTextStyle,
            ),
            currentAccountPicture: CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(provider.userData.avatarUrl),
            ),
            decoration: const BoxDecoration(
              color: AppColors.secondaryColor,
            ),
          ),
          ListTile(
            leading: const Icon(
              Icons.remove_red_eye_outlined,
              color: AppColors.secondaryColor,
            ),
            title: Text(
              'just viewed',
              style: AppFonts.bodyTextStyle,
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => InsideUserPollsScreen(
                    uid: provider.userData.userId,
                    username: provider.userData.userName,
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.list,
              color: AppColors.secondaryColor,
            ),
            title: Text(
              'my lists',
              style: AppFonts.bodyTextStyle,
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => InsideUserListsScreen(
                    uid: provider.userData.userId,
                    username: provider.userData.userName,
                    count: provider.userData.noOfLists,
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.history,
              color: AppColors.secondaryColor,
            ),
            title: Text(
              'my activity',
              style: AppFonts.bodyTextStyle,
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const MyActivityScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.help,
              color: AppColors.secondaryColor,
            ),
            title: Text(
              'help & support',
              style: AppFonts.bodyTextStyle,
            ),
            onTap: () => open('https://raihansk.com/contact/'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(
              Icons.star,
              color: AppColors.secondaryColor,
            ),
            title: Text(
              'give rating',
              style: AppFonts.bodyTextStyle,
            ),
            onTap: () {
              // Navigator.of(context).push(
              //   MaterialPageRoute(
              //     builder: (context) => const GiveRatingScreen(),
              //   ),
              // );
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.settings,
              color: AppColors.secondaryColor,
            ),
            title: Text(
              'settings',
              style: AppFonts.bodyTextStyle,
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            title: Text(
              'exit',
              style: AppFonts.bodyTextStyle,
            ),
            leading:
                const Icon(Icons.exit_to_app, color: AppColors.secondaryColor),
            onTap: () async {
              SystemNavigator.pop();
            },
          ),
          ListTile(
            leading: const Icon(Icons.info, color: AppColors.secondaryColor),
            title: Text(
              "logout",
              style: AppFonts.bodyTextStyle,
            ),
            onTap: () async {
              SharedPreferences preferences =
                  await SharedPreferences.getInstance();
              await preferences.clear();
              await GoogleSignIn().signOut();
              await FirebaseAuth.instance.signOut();

              context.pushReplacement('/');
            },
          ),
        ],
      ),
    );
  }
}
