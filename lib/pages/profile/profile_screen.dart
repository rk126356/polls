import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:polls/const/fonts.dart';
import 'package:polls/models/user_model.dart';
import 'package:polls/pages/profile/inside/inside_followers_screen.dart';
import 'package:polls/pages/profile/inside/inside_followings_screen.dart';
import 'package:polls/pages/profile/inside/inside_user_lists_screen.dart';
import 'package:polls/pages/profile/inside/inside_user_polls_screen.dart';
import 'package:polls/pages/profile/inside/my_activity_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../const/colors.dart';
import '../../provider/user_provider.dart';
import '../extra/settings_screen.dart';
import 'edit_profile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                _HeaderBackground(),
                _ProfileAvatar(),
              ],
            ),
            _QuickLinks(),
          ],
        ),
      ),
    );
  }
}

class _HeaderBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 370,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.fourthColor, AppColors.primaryColor],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var user = FirebaseAuth.instance.currentUser;
    var data = Provider.of<UserProvider>(context);

    return Center(
      child: Column(
        children: [
          const SizedBox(
            height: 50,
          ),
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CachedNetworkImage(
                width: 120,
                height: 120,
                imageUrl: data.userData.avatarUrl,
                progressIndicatorBuilder: (context, url, downloadProgress) =>
                    CircularProgressIndicator(value: downloadProgress.progress),
                errorWidget: (context, url, error) => const Icon(Icons.error),
                imageBuilder: (context, imageProvider) => Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2.0,
                    ),
                  ),
                  child: ClipOval(
                    child: Image(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.blue,
                child: IconButton(
                  icon: const Icon(
                    Icons.edit,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const EditProfileScreen()),
                    );
                  },
                ),
              ),
            ],
          ),
          _ProfileInfo(user: user!),
        ],
      ),
    );
  }
}

class _ProfileInfo extends StatelessWidget {
  final User user;

  const _ProfileInfo({required this.user});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        var userData = snapshot.data?.data() as Map<String, dynamic>;

        return Column(
          children: [
            Text(
              userData['name'] ?? '',
              style: AppFonts.headingTextStyle,
            ),
            Text(
              '@${userData['userName']}',
              style: AppFonts.bodyTextStyle,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8),
              child: Text(
                userData['bio'] ?? 'no bio available',
                style: AppFonts.bodyTextStyle.copyWith(fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            _ProfileStats(user: user),
          ],
        );
      },
    );
  }
}

class _ProfileStats extends StatelessWidget {
  final User user;

  const _ProfileStats({required this.user});

  @override
  Widget build(BuildContext context) {
    var data = Provider.of<UserProvider>(context, listen: false);
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        var userData = snapshot.data?.data() as Map<String, dynamic>;
        var followers = userData['noOfFollowers'] ?? 0;
        var polls = userData['noOfPolls'] ?? 0;
        var followings = userData['noOfFollowings'] ?? 0;
        final userNow = UserModel.fromJson(userData);

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => InsideUserPollsScreen(
                      uid: userNow.userId,
                      username: userNow.userName,
                    ),
                  ),
                );
              },
              child: _StatItem("polls", '$polls'),
            ),
            InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => InsideFollowersScreen(
                      userID: user.uid,
                      username: userNow.userName,
                      noOfFollowers: userNow.noOfFollowers ?? 0,
                      name: userNow.name,
                    ),
                  ),
                );
              },
              child: _StatItem("followers", followers.toString()),
            ),
            InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => InsideFollowingsScreen(
                      userID: user.uid,
                      username: userNow.userName,
                      noOfFollowers: userNow.noOfFollowers ?? 0,
                      name: userNow.name,
                    ),
                  ),
                );
              },
              child: _StatItem("following", followings.toString()),
            ),
          ],
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppFonts.bodyTextStyle),
        Text(
          label,
          style: AppFonts.buttonTextStyle,
        ),
      ],
    );
  }
}

class _QuickLinks extends StatefulWidget {
  @override
  State<_QuickLinks> createState() => _QuickLinksState();
}

class _QuickLinksState extends State<_QuickLinks> {
  @override
  Widget build(BuildContext context) {
    var data = Provider.of<UserProvider>(context, listen: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          leading:
              const Icon(Icons.edit_outlined, color: AppColors.secondaryColor),
          title: const Text("edit profile"),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EditProfileScreen(),
              ),
            );
          },
        ),
        ListTile(
          leading:
              const Icon(Icons.poll_outlined, color: AppColors.secondaryColor),
          title: const Text("my polls"),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => InsideUserPollsScreen(
                  uid: data.userData.userId,
                  username: data.userData.userName,
                ),
              ),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.list, color: AppColors.secondaryColor),
          title: const Text("my lists"),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => InsideUserListsScreen(
                  uid: data.userData.userId,
                  username: data.userData.userName,
                  count: data.userData.noOfLists,
                ),
              ),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.history_outlined,
              color: AppColors.secondaryColor),
          title: const Text("my activity"),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MyActivityScreen(),
              ),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.settings_outlined,
              color: AppColors.secondaryColor),
          title: const Text("settings"),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SettingsScreen(),
              ),
            );
          },
        ),
        if (kDebugMode)
          ListTile(
            leading:
                const Icon(Icons.info_outline, color: AppColors.secondaryColor),
            title: const Text("clear data"),
            onTap: () async {
              SharedPreferences preferences =
                  await SharedPreferences.getInstance();
              await preferences.clear();
            },
          ),
        const SizedBox(
          height: 30,
        )
      ],
    );
  }
}
