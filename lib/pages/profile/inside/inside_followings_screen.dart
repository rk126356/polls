import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:polls/widgets/loading_user_box_widget.dart';
import 'package:polls/widgets/user_box_widget.dart';

import '../../../const/colors.dart';
import '../../../const/fonts.dart';
import '../../../models/user_model.dart';

class InsideFollowingsScreen extends StatefulWidget {
  final String userID;
  final String username;
  final int noOfFollowers;
  final String name;
  const InsideFollowingsScreen(
      {super.key,
      required this.userID,
      required this.username,
      required this.noOfFollowers,
      required this.name});

  @override
  State<InsideFollowingsScreen> createState() => _InsideFollowingsScreenState();
}

class _InsideFollowingsScreenState extends State<InsideFollowingsScreen> {
  List<UserModel> users = [];
  bool _isLoading = false;
  bool _isButtonLoading = false;

  DocumentSnapshot? lastDocument;
  int listLength = 10;

  void fetchFollowings(bool next, context) async {
    if (!next) {
      setState(() {
        _isLoading = true;
      });
    }

    final firestore = FirebaseFirestore.instance;

    QuerySnapshot<Map<String, dynamic>> followingRef;

    if (next) {
      setState(() {
        _isButtonLoading = true;
      });
      followingRef = await firestore
          .collection('users/${widget.userID}/myFollowings')
          .orderBy('createdAt', descending: isSortByNew)
          .startAfter([lastDocument?['createdAt']])
          .limit(listLength)
          .get();
    } else {
      users.clear();

      followingRef = await firestore
          .collection('users/${widget.userID}/myFollowings')
          .orderBy('createdAt', descending: isSortByNew)
          .limit(listLength)
          .get();
    }

    lastDocument = followingRef.docs.isNotEmpty ? followingRef.docs.last : null;

    if (followingRef.docs.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('error'),
            content: const Text('no more followings available.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('ok'),
              ),
            ],
          );
        },
      );
      setState(() {
        _isButtonLoading = false;
        _isLoading = false;
      });
      return;
    }

    for (final docs in followingRef.docs) {
      final userData = docs.data();

      final userRef =
          await firestore.collection('users').doc(userData['userId']).get();
      final user = userRef.data();

      if (user != null) {
        final newUser = UserModel.fromJson(user);

        users.add(newUser);
      } else {
        if (kDebugMode) {
          print('Null user');
        }
      }
    }
    setState(() {
      _isLoading = false;
      _isButtonLoading = false;
    });
  }

  bool isSortByNew = true;

  void switchSortBy() async {
    setState(() {
      _isLoading = true;
    });
    setState(() {
      isSortByNew ? isSortByNew = false : isSortByNew = true;
      _isLoading = false;
    });
    fetchFollowings(false, context);
  }

  @override
  void initState() {
    super.initState();
    fetchFollowings(false, context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fourthColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: AppColors.headingText),
        title: Text(
          'folllowings',
          style: AppFonts.headingTextStyle,
        ),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.search))],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 3,
                  blurRadius: 7,
                  offset: const Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: switchSortBy,
                // borderRadius: BorderRadius.circular(8.0),
                child: Ink(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.thirdColor, AppColors.secondaryColor],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    // borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.name,
                        style: AppFonts.headingTextStyle.copyWith(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Expanded(
                        child: Text(
                          '@${widget.username}',
                          style: AppFonts.headingTextStyle.copyWith(
                            fontSize: 12,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: isSortByNew
                            ? const Icon(Icons.arrow_upward,
                                color: Colors.black)
                            : const Icon(Icons.arrow_downward,
                                color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          _isLoading
              ? Column(
                  children: [
                    if (widget.noOfFollowers < 10)
                      for (int i = 0; i < widget.noOfFollowers; i++)
                        const LoadingUserBoxShimmer()
                    else
                      for (int i = 0; i < 10; i++)
                        const LoadingUserBoxShimmer(),
                  ],
                )
              : users.isEmpty
                  ? Center(
                      child: Text('@${widget.username} have no followers'),
                    )
                  : Expanded(
                      child: ListView.builder(
                        itemCount: users.length + 1,
                        itemBuilder: (context, index) {
                          if (index == users.length) {
                            return Center(
                              child: _isButtonLoading
                                  ? const CircularProgressIndicator()
                                  : Column(
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {
                                            fetchFollowings(true, context);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                AppColors.secondaryColor,
                                          ),
                                          child: Text('load more...',
                                              style: AppFonts.buttonTextStyle),
                                        ),
                                        const SizedBox(
                                          height: 25,
                                        )
                                      ],
                                    ),
                            );
                          }
                          return UserBoxLoop(user: users[index]);
                        },
                      ),
                    ),
        ],
      ),
    );
  }
}
