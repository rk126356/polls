import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:polls/models/polls_model.dart';
import 'package:polls/utils/snackbar_widget.dart';
import 'package:polls/widgets/error_poll_widget.dart';
import 'package:polls/widgets/loading_polls_shimmer_widget.dart';
import 'package:polls/widgets/poll_item_widget.dart';

import '../../../const/colors.dart';
import '../../../const/fonts.dart';
import '../../../utils/check_and_return_polls.dart';

class InsideTagScreen extends StatefulWidget {
  const InsideTagScreen({super.key, required this.tag});

  @override
  State<InsideTagScreen> createState() => _InsideTagScreenState();

  final String tag;
}

class _InsideTagScreenState extends State<InsideTagScreen> {
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

    QuerySnapshot<Map<String, dynamic>> pollCollection;

    if (next) {
      setState(() {
        _isButtonLoading = true;
      });
      pollCollection = await firestore
          .collection('allPolls')
          .orderBy('timestamp', descending: true)
          .where('tags', arrayContainsAny: [widget.tag])
          .startAfter([lastDocument?['timestamp']])
          .limit(listLength)
          .get();
    } else {
      pollCollection = await firestore
          .collection('allPolls')
          .orderBy('timestamp', descending: true)
          .where('tags', arrayContainsAny: [widget.tag])
          .limit(listLength)
          .get();
    }

    if (pollCollection.docs.isEmpty) {
      showCoolErrorSnackbar(context, 'no more polls available!');
      setState(() {
        _isButtonLoading = false;
        _isLoading = false;
      });
      return;
    }

    lastDocument =
        pollCollection.docs.isNotEmpty ? pollCollection.docs.last : null;

    polls = pollCollection.docs
        .map((doc) => PollModel.fromJson(doc.data()))
        .toList();

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
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: AppColors.headingText),
        title: Text(
          widget.tag,
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
