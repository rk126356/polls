import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polls/const/fonts.dart';
import 'package:polls/pages/profile/activity/inside_activity_screen.dart';
import 'package:provider/provider.dart';

import '../../../const/colors.dart';
import '../../../provider/user_provider.dart';

class MyActivityScreen extends StatefulWidget {
  const MyActivityScreen({super.key});

  @override
  State<MyActivityScreen> createState() => _MyActivityScreenState();
}

class _MyActivityScreenState extends State<MyActivityScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<UserProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: AppColors.secondaryColor,
        title: Text(
          'my activity',
          style: AppFonts.headingTextStyle.copyWith(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          ListTile(
            leading: const Icon(CupertinoIcons.hand_raised,
                color: AppColors.secondaryColor),
            title: const Text("voted polls"),
            trailing: const Icon(
              CupertinoIcons.forward,
              color: AppColors.secondaryColor,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InsideActivityScreen(
                    uid: provider.userData.userId,
                    title: 'my voted',
                    quary: 'allVotes',
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(CupertinoIcons.share,
                color: AppColors.secondaryColor),
            title: const Text("shared polls"),
            trailing: const Icon(
              CupertinoIcons.forward,
              color: AppColors.secondaryColor,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InsideActivityScreen(
                    uid: provider.userData.userId,
                    title: 'my shared',
                    quary: 'allShares',
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading:
                const Icon(CupertinoIcons.eye, color: AppColors.secondaryColor),
            title: const Text("recently viewed"),
            trailing: const Icon(
              CupertinoIcons.forward,
              color: AppColors.secondaryColor,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InsideActivityScreen(
                    uid: provider.userData.userId,
                    title: 'my viewed',
                    quary: 'allViews',
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
