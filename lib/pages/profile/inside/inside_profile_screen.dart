// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:polls/const/fonts.dart';
import 'package:polls/models/polls_model.dart';
import 'package:polls/pages/profile/edit_profile.dart';
import 'package:polls/pages/profile/inside/inside_followers_screen.dart';
import 'package:polls/pages/profile/inside/inside_followings_screen.dart';
import 'package:polls/pages/profile/inside/inside_user_polls_screen.dart';
import 'package:polls/utils/url_launcher.dart';
import 'package:polls/widgets/loading_polls_shimmer_widget.dart';
import 'package:polls/widgets/loading_profile_shimmer_widget.dart';
import 'package:polls/widgets/poll_item_widget.dart';
import 'package:provider/provider.dart';

import '../../../const/colors.dart';
import '../../../controllers/check_if_tasks.dart';
import '../../../controllers/fetch_user.dart';
import '../../../models/user_model.dart';
import '../../../provider/user_provider.dart';

class InsideProfileScreen extends StatefulWidget {
  final String userId;
  const InsideProfileScreen({super.key, required this.userId});

  @override
  State<InsideProfileScreen> createState() => _InsideProfileScreenState();
}

class _InsideProfileScreenState extends State<InsideProfileScreen> {
  bool _isLoading = false;
  bool _isLoadingPolls = false;
  late UserModel user;
  final List<PollModel> _polls = [];

  void _fetchUser(String userId) async {
    setState(() {
      _isLoading = true;
    });
    final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);
    final userDocSnapshot = await userDoc.get();

    if (userDocSnapshot.exists) {
      try {
        final userData = userDocSnapshot.data();
        if (userData != null) {
          user = UserModel.fromJson(userData);
        }
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }
    } else {
      if (kDebugMode) {
        print('User not found');
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _fetchPolls(String userId) async {
    final firestore = FirebaseFirestore.instance;
    setState(() {
      _isLoadingPolls = true;
    });

    _polls.clear();

    final pollCollection = await firestore
        .collection('allPolls')
        .where('creatorId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(10)
        .get();

    for (final pollDoc in pollCollection.docs) {
      final pollData = pollDoc.data();

      final poll = PollModel.fromJson(pollData);

      _polls.add(poll);
    }

    List<Future> futures = [];

    for (final poll in _polls) {
      futures.add(checkIfVoted(poll));
      futures.add(fetchUser(poll.creatorId));
    }

    List results = await Future.wait(futures);

    for (int i = 0; i < results.length; i += 2) {
      final voted = results[i].isVoted;
      final option = results[i].option;
      final user = results[i + 1];
      final pollIndex = i ~/ 2;

      _polls[pollIndex].isVoted = voted;
      if (option.isNotEmpty) {
        _polls[pollIndex].option = option;
      }
      if (user != null) {
        _polls[pollIndex].creatorName = user.name;
        _polls[pollIndex].creatorUserImageUrl = user.avatarUrl;
        _polls[pollIndex].creatorUserName = user.userName;
      }
    }
    setState(() {
      _isLoadingPolls = false;
    });
  }

  bool isAppBarExpanded = false;
  late ScrollController _scrollController;

  void _updateScrollPosition() {
    setState(() {
      isAppBarExpanded =
          _scrollController.hasClients && _scrollController.offset > 250;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchUser(widget.userId);
    _fetchPolls(widget.userId);
    _scrollController = ScrollController()..addListener(_updateScrollPosition);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var data = Provider.of<UserProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: AppColors.fourthColor,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: <Widget>[
          SliverAppBar(
            backgroundColor: AppColors.primaryColor,
            iconTheme: const IconThemeData(
              color: AppColors.headingText,
            ),
            expandedHeight: 400,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: isAppBarExpanded
                  ? Text(
                      _isLoading ? 'loading...' : '@${user.userName}',
                      style: AppFonts.bodyTextStyle,
                    )
                  : null,
              background: _isLoading
                  ? const LoadingProfileShimmer()
                  : _ProfileAvatar(
                      user: user,
                    ),
            ),
            actions: [
              _isLoading
                  ? Container()
                  : data.userData.userId == user.userId
                      ? IconButton(
                          icon: const Icon(
                            Icons.edit_outlined,
                            color: AppColors.headingText,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const EditProfileScreen()),
                            );
                          },
                        )
                      : IconButton(
                          icon: const Icon(
                            CupertinoIcons.info,
                            color: AppColors.headingText,
                          ),
                          onPressed: () {
                            open('https://sharequiz.in/contact-us/');
                          },
                        ),
            ],
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                if (_polls.isEmpty && !_isLoadingPolls) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("no polls found"),
                    ),
                  );
                }

                if (_isLoadingPolls) {
                  return const LoadingPollsShimmer();
                } else {
                  final poll = _polls[index];
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      PollCard(
                        key: PageStorageKey(poll.id),
                        poll: poll,
                        isInsideList: false,
                        deleteTap: () {
                          setState(() {
                            _polls.removeAt(index);
                          });
                        },
                      ),
                      if (index + 1 == _polls.length)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 30.0),
                          child: Center(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => InsideUserPollsScreen(
                                      uid: user.userId,
                                      username: user.userName,
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors
                                    .secondaryColor, // Change the button color
                              ),
                              child: Text('see all polls',
                                  style: AppFonts.buttonTextStyle),
                            ),
                          ),
                        )
                    ],
                  );
                }
              },
              childCount: _polls.isEmpty ? 1 : _polls.length,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatefulWidget {
  final UserModel user;

  const _ProfileAvatar({required this.user});
  @override
  State<_ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<_ProfileAvatar> {
  bool _isFollowing = false;
  bool _isChecking = false;

  Future<void> checkIfFollowing() async {
    setState(() {
      _isChecking = true;
    });
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final uid = user.uid;

      final firestore = FirebaseFirestore.instance;
      final followingQuizRef = firestore.collection('users/$uid/myFollowings');

      final followingQuizSnapshot = await followingQuizRef
          .where('userId', isEqualTo: widget.user.userId)
          .get();

      setState(() {
        _isFollowing = followingQuizSnapshot.docs.isNotEmpty;
        _isChecking = false;
      });
    }
  }

  void addFollowing() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final uid = user.uid;

      final firestore = FirebaseFirestore.instance;
      final followingRef = firestore.collection('users/$uid/myFollowings');
      final otherUserRef =
          firestore.collection('users/${widget.user.userId}/myFollowers');

      if (!_isFollowing) {
        setState(() {
          widget.user.noOfFollowers = widget.user.noOfFollowers! + 1;
          _isFollowing = true;
        });

        await firestore
            .collection('users')
            .doc(widget.user.userId)
            .update({'noOfFollowers': FieldValue.increment(1)});
        await firestore
            .collection('users')
            .doc(user.uid)
            .update({'noOfFollowings': FieldValue.increment(1)});

        await followingRef.add({
          'userId': widget.user.userId,
          'myUserId': user.uid,
          'createdAt': Timestamp.now(),
        });
        await otherUserRef.add({
          'userId': user.uid,
          'myUserId': widget.user.userId,
          'createdAt': Timestamp.now(),
        });
      } else {
        setState(() {
          widget.user.noOfFollowers = widget.user.noOfFollowers! - 1;
          _isFollowing = false;
        });

        await firestore
            .collection('users')
            .doc(widget.user.userId)
            .update({'noOfFollowers': FieldValue.increment(-1)});
        await firestore
            .collection('users')
            .doc(user.uid)
            .update({'noOfFollowings': FieldValue.increment(-1)});

        final followingSnapshot = await followingRef
            .where('userId', isEqualTo: widget.user.userId)
            .get();
        final followersRefSnapshot =
            await otherUserRef.where('userId', isEqualTo: user.uid).get();

        for (final doc in followingSnapshot.docs) {
          await doc.reference.delete();
        }
        for (final doc in followersRefSnapshot.docs) {
          await doc.reference.delete();
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    checkIfFollowing();
  }

  @override
  Widget build(BuildContext context) {
    var data = Provider.of<UserProvider>(context, listen: false);
    if (_isChecking) {
      return const LoadingProfileShimmer();
    }
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.fourthColor, AppColors.primaryColor],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
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
                  imageUrl: widget.user.avatarUrl,
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      CircularProgressIndicator(
                          value: downloadProgress.progress),
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
              ],
            ),
            _ProfileInfo(
              user: widget.user,
            ),
            data.userData.userId == widget.user.userId
                ? OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => InsideUserPollsScreen(
                            uid: widget.user.userId,
                            username: widget.user.userName,
                          ),
                        ),
                      );
                    },
                    label: Text("my polls", style: AppFonts.buttonTextStyle),
                    icon: const Icon(
                      Icons.poll_outlined,
                    ),
                  )
                : Container(
                    width: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                          20), // Make it round by adjusting the borderRadius
                      color: _isFollowing
                          ? Colors.red.shade500
                          : CupertinoColors
                              .activeBlue, // Set the background color based on _isFollowing
                    ),
                    child: TextButton(
                      onPressed: addFollowing,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isFollowing
                                ? Icons.person_remove_alt_1
                                : Icons.person_add_alt_1,
                            color: Colors.white, // Set the icon color to white
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            _isFollowing ? "unfollow" : "follow",
                            style: const TextStyle(
                                color: Colors
                                    .white), // Set the text color to white
                          ),
                        ],
                      ),
                    ),
                  ),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileInfo extends StatelessWidget {
  final UserModel user;

  const _ProfileInfo({required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            user.name,
            style: AppFonts.bodyTextStyle
                .copyWith(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            '@${user.userName}',
            style: AppFonts.bodyTextStyle.copyWith(fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            user.bio ?? 'no bio',
            style: AppFonts.bodyTextStyle.copyWith(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          _ProfileStats(
            user: user,
          ),
        ],
      ),
    );
  }
}

class _ProfileStats extends StatelessWidget {
  final UserModel user;

  const _ProfileStats({required this.user});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _StatItem("polls", '${user.noOfPolls ?? 0}', () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => InsideUserPollsScreen(
                uid: user.userId,
                username: user.userName,
              ),
            ),
          );
        }),
        _StatItem("followers", '${user.noOfFollowers ?? 0}', () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => InsideFollowersScreen(
                userID: user.userId,
                username: user.userName,
                noOfFollowers: user.noOfFollowers ?? 0,
                name: user.name,
              ),
            ),
          );
        }),
        _StatItem("following", '${user.noOfFollowings ?? 0}', () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => InsideFollowingsScreen(
                userID: user.userId,
                username: user.userName,
                noOfFollowers: user.noOfFollowers ?? 0,
                name: user.name,
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _StatItem(this.label, this.value, this.onTap);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            value,
            style: AppFonts.bodyTextStyle,
          ),
          Text(
            label,
            style: AppFonts.bodyTextStyle,
          ),
        ],
      ),
    );
  }
}
