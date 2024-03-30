import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:polls/const/fonts.dart';
import 'package:polls/controllers/poll_firebase/get_poll_controller.dart';
import 'package:polls/models/polls_model.dart';
import 'package:polls/pages/search/inside_search_screen.dart';
import 'package:polls/utils/check_and_return_polls.dart';
import 'package:polls/utils/snackbar_widget.dart';
import 'package:polls/widgets/custom_error_box_wdiget.dart';
import 'package:polls/widgets/loading_polls_shimmer_widget.dart';
import 'package:polls/widgets/poll_item_widget.dart';

import '../../../const/colors.dart';

class InsideActivityScreen extends StatefulWidget {
  final String uid;
  final String title;
  final String quary;
  const InsideActivityScreen(
      {super.key, required this.uid, required this.title, required this.quary});

  @override
  State<InsideActivityScreen> createState() => _InsideActivityScreenState();
}

class _InsideActivityScreenState extends State<InsideActivityScreen> {
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

    QuerySnapshot<Map<String, dynamic>> voteCollection;
    ;

    if (next) {
      setState(() {
        _isButtonLoading = true;
      });
      voteCollection = await firestore
          .collection(widget.quary)
          .orderBy('createdAt', descending: true)
          .where('userId', isEqualTo: widget.uid)
          .startAfter([lastDocument?['createdAt']])
          .limit(listLength)
          .get();
    } else {
      voteCollection = await firestore
          .collection(widget.quary)
          .orderBy('createdAt', descending: true)
          .where('userId', isEqualTo: widget.uid)
          .limit(listLength)
          .get();
    }

    if (voteCollection.docs.isEmpty) {
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
        voteCollection.docs.isNotEmpty ? voteCollection.docs.last : null;

    for (final voteDoc in voteCollection.docs) {
      try {
        final voteData = voteDoc.data();
        final pollId = voteData['pollId'];

        final poll = await getPoll(pollId);
        if (poll != null) {
          polls.add(poll);
        }
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
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
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: AppColors.headingText),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const InsdieSearchScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.search))
        ],
        centerTitle: true,
        title: Text(
          '${widget.title} polls',
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
          : polls.isEmpty && !_isLoading
              ? const CustomErrorBox(text: 'no polls found!')
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
                                                style:
                                                    AppFonts.buttonTextStyle),
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
