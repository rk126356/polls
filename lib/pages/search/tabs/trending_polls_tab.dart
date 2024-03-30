import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:polls/const/fonts.dart';
import 'package:polls/models/polls_model.dart';
import 'package:polls/utils/check_and_return_polls.dart';
import 'package:polls/utils/snackbar_widget.dart';
import 'package:polls/widgets/poll_item_widget.dart';

import '../../../const/colors.dart';
import '../../../widgets/custom_error_box_wdiget.dart';

class TrendingPollsTab extends StatefulWidget {
  const TrendingPollsTab({super.key});

  @override
  State<TrendingPollsTab> createState() => _TrendingPollsTabState();
}

class _TrendingPollsTabState extends State<TrendingPollsTab> {
  List<PollModel> polls = [];

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
          // .where('timestamp', isGreaterThanOrEqualTo: startTimestamp)
          // .where('timestamp', isLessThan: endTimestamp)
          .orderBy('views', descending: true)
          .startAfterDocument(lastDocument!)
          .limit(listLength)
          .get();
    } else {
      // Calculate start and end timestamps for this week
      final now = DateTime.now();
      final startOfWeek = DateTime(now.year, now.month, now.day - now.weekday);
      final endOfWeek = startOfWeek.add(const Duration(days: 7));

      final startTimestamp = Timestamp.fromDate(startOfWeek);
      final endTimestamp = Timestamp.fromDate(endOfWeek);

      quizCollection = await firestore
          .collection('allPolls')
          .where('timestamp', isGreaterThanOrEqualTo: startTimestamp)
          .where('timestamp', isLessThan: endTimestamp)
          .orderBy('timestamp')
          .orderBy('views', descending: true)
          .limit(listLength)
          .get();
    }

    if (quizCollection.docs.isEmpty) {
      if (next) {
        showCoolErrorSnackbar(context, 'no more polls available.');
      }
      setState(() {
        _isButtonLoading = false;
        _isLoading = false;
      });
      return;
    }

    lastDocument =
        quizCollection.docs.isNotEmpty ? quizCollection.docs.last : null;

    for (final pollDoc in quizCollection.docs) {
      try {
        final pollData = pollDoc.data();
        final poll = PollModel.fromJson(pollData);

        polls.add(poll);
      } catch (e) {
        print(e);
      }
    }

    polls = await checkAndReturnPolls(polls);
    setState(() {
      _isLoading = false;
      _isButtonLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fourthColor,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : polls.isEmpty && !_isLoading
              ? const CustomErrorBox(text: 'nothing available!')
              : Expanded(
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
                                    if (polls.length >= 10)
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
    );
  }
}
