import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:polls/const/fonts.dart';
import 'package:polls/models/polls_model.dart';
import 'package:polls/widgets/loading_polls_shimmer_widget.dart';
import 'package:polls/widgets/poll_item_widget.dart';

import '../../../const/colors.dart';
import '../../../controllers/check_if_tasks.dart';
import '../../../controllers/fetch_user.dart';

class InsideUserPollsScreen extends StatefulWidget {
  final String uid;
  final String username;
  const InsideUserPollsScreen(
      {super.key, required this.uid, required this.username});

  @override
  State<InsideUserPollsScreen> createState() => _InsideUserPollsScreenState();
}

class _InsideUserPollsScreenState extends State<InsideUserPollsScreen> {
  final List<PollModel> polls = [];

  int listLength = 10;

  DocumentSnapshot? lastDocument;
  bool _isLoading = false;
  bool _isButtonLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchPolls(false, context);
  }

  Future<void> _fetchPolls(bool next, context) async {
    if (polls.isEmpty) {
      setState(() {
        _isLoading = true;
      });
    }
    final firestore = FirebaseFirestore.instance;

    QuerySnapshot<Map<String, dynamic>> quizCollection;

    if (next) {
      setState(() {
        _isButtonLoading = true;
      });
      quizCollection = await firestore
          .collection('allPolls')
          .orderBy('timestamp', descending: true)
          .where('creatorId', isEqualTo: widget.uid)
          .startAfter([lastDocument?['timestamp']])
          .limit(listLength)
          .get();
    } else {
      quizCollection = await firestore
          .collection('allPolls')
          .orderBy('timestamp', descending: true)
          .where('creatorId', isEqualTo: widget.uid)
          .limit(listLength)
          .get();
    }

    if (quizCollection.docs.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('error'),
            content: const Text('no more polls available.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
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

    lastDocument =
        quizCollection.docs.isNotEmpty ? quizCollection.docs.last : null;

    for (final pollDoc in quizCollection.docs) {
      final pollData = pollDoc.data();
      final poll = PollModel.fromJson(pollData);

      polls.add(poll);
    }

    List<Future> futures = [];

    for (final poll in polls) {
      futures.add(checkIfVoted(poll));
      futures.add(fetchUser(poll.creatorId));
    }

    List results = await Future.wait(futures);

    for (int i = 0; i < results.length; i += 2) {
      final voted = results[i].isVoted;
      final option = results[i].option;
      final user = results[i + 1];
      final pollIndex = i ~/ 2;

      polls[pollIndex].isVoted = voted;
      if (option.isNotEmpty) {
        polls[pollIndex].option = option;
      }
      if (user != null) {
        polls[pollIndex].creatorName = user.name;
        polls[pollIndex].creatorUserImageUrl = user.avatarUrl;
        polls[pollIndex].creatorUserName = user.userName;
      }
    }
    setState(() {
      _isLoading = false;
      _isButtonLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fourthColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: AppColors.headingText),
        title: Text(
          '@${widget.username}: polls',
          style: AppFonts.headingTextStyle,
        ),
      ),
      body: _isLoading
          ? const SingleChildScrollView(
              child: Column(
                children: [
                  LoadingPollsShimmer(),
                  LoadingPollsShimmer(),
                  LoadingPollsShimmer()
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: polls.length + 1,
                    itemBuilder: (context, index) {
                      if (index == polls.length) {
                        return Center(
                          child: _isButtonLoading
                              ? const CircularProgressIndicator()
                              : Column(
                                  children: [
                                    if (polls.length > 10)
                                      ElevatedButton(
                                        onPressed: () {
                                          _fetchPolls(true, context);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors
                                              .secondaryColor, // Change the button color
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
                      final poll = polls[index];

                      return PollCard(
                        key: PageStorageKey(poll.id),
                        poll: poll,
                        isInsideList: false,
                        deleteTap: () {
                          setState(() {
                            polls.removeAt(index);
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
