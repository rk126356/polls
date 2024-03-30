// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:polls/controllers/check_if_tasks.dart';
import 'package:polls/controllers/vote_controller.dart';
import 'package:polls/pages/polls/create_poll_screen.dart';
import 'package:polls/utils/check_and_return_polls.dart';
import 'package:polls/widgets/custom_error_box_wdiget.dart';

import '../../const/colors.dart';
import '../../const/fonts.dart';
import '../../models/polls_model.dart';
import '../../navigation/side_menu_navbar.dart';
import '../../utils/snackbar_widget.dart';
import '../../widgets/loading_polls_shimmer_widget.dart';
import '../../widgets/poll_item_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ScrollController forYouScrollController = ScrollController();
  ScrollController followingsScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchPolls(false);
  }

  @override
  void dispose() {
    forYouScrollController.dispose();
    followingsScrollController.dispose();
    super.dispose();
  }

  List<PollModel> polls = [];

  int listLength = 10;

  DocumentSnapshot? lastDocument;
  bool _isLoading = false;
  bool _isButtonLoading = false;

  Future<void> _fetchPolls(bool next) async {
    if (!next) {
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
          .startAfterDocument(lastDocument!)
          .limit(listLength)
          .get();
    } else {
      pollCollection =
          await firestore.collection('allPolls').limit(listLength).get();
    }

    if (pollCollection.docs.isEmpty) {
      polls.clear();
      await deleteSeenData(context: context);
      _refreshPolls();
      return;
    }

    lastDocument =
        pollCollection.docs.isNotEmpty ? pollCollection.docs.last : null;

    for (final pollDoc in pollCollection.docs) {
      try {
        final pollData = pollDoc.data();
        final poll = PollModel.fromJson(pollData);
        // final isSeen = await checkIfSeen(poll);
        // if (!isSeen) {
        //   final poll0 = await checkAndReturnPoll(poll);
        //   polls.add(poll0);
        // }
        polls.add(poll);
      } catch (e) {
        print('error');
        print(e);
      }
    }

    if (polls.isEmpty) {
      polls.clear();
      final deleted = await deleteSeenData(context: context);
      if (deleted) {
        _refreshPolls();
        return;
      }
    }

    setState(() {
      _isLoading = false;
      _isButtonLoading = false;
    });
  }

  Future<void> _refreshPolls() async {
    print('refresh');
    _fetchPolls(false);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const CreatePollScreen(),
              ),
            );
          },
          child: const Icon(Icons.post_add),
        ),
        backgroundColor: AppColors.fourthColor,
        drawer: const NavBar(),
        appBar: AppBar(
          actions: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.notifications))
          ],
          iconTheme: const IconThemeData(color: AppColors.headingText),
          centerTitle: true,
          backgroundColor: AppColors.primaryColor,
          title: Text(
            'publicpolls',
            style: AppFonts.headingTextStyle,
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: Container(
              color: Colors.blueGrey[800],
              child: TabBar(
                tabs: const [
                  Tab(
                    text: 'for you',
                  ),
                  Tab(
                    text: 'followings',
                  ),
                ],
                indicatorColor: AppColors.fourthColor,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey,
                labelStyle: AppFonts.bodyTextStyle,
                unselectedLabelStyle: AppFonts.bodyTextStyle,
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            // Content for 'You' tab
            PageStorage(
              key: const PageStorageKey('ForYouTab'),
              bucket: PageStorageBucket(),
              child: SingleChildScrollView(
                controller: forYouScrollController,
                child: Column(
                  children: [
                    if (polls.isEmpty && !_isLoading)
                      const CustomErrorBox(text: 'something wend wrong!'),
                    if (_isLoading)
                      const Column(
                        children: [
                          LoadingPollsShimmer(),
                          LoadingPollsShimmer(),
                          LoadingPollsShimmer(),
                          LoadingPollsShimmer()
                        ],
                      ),
                    if (!_isLoading && polls.isNotEmpty)
                      ListView.builder(
                        controller: forYouScrollController,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: polls.length + 1,
                        itemBuilder: (context, index) {
                          if (index == polls.length) {
                            return Center(
                              child: _isButtonLoading
                                  ? const CircularProgressIndicator()
                                  : Column(
                                      children: [
                                        if (polls.length >= polls.length)
                                          ElevatedButton(
                                            onPressed: () {
                                              _fetchPolls(true);
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
                    const SizedBox(
                      height: 180,
                    )
                  ],
                ),
              ),
            ),
            // Content for 'Followings' tab
            RefreshIndicator(
              onRefresh: _refreshPolls,
              child: PageStorage(
                bucket: PageStorageBucket(),
                key: const PageStorageKey('FollowingsTab'),
                child: SingleChildScrollView(
                  controller: followingsScrollController,
                  child: Column(
                    children: [
                      if (polls.isEmpty)
                        const Column(
                          children: [
                            LoadingPollsShimmer(),
                            LoadingPollsShimmer(),
                            LoadingPollsShimmer(),
                            LoadingPollsShimmer()
                          ],
                        )
                      else
                        ListView.builder(
                          controller: followingsScrollController,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: polls.length,
                          itemBuilder: (context, index) {
                            return PollCard(
                              poll: polls[index],
                              isInsideList: false,
                              deleteTap: () {
                                setState(() {
                                  polls.remove(polls[index]);
                                });
                              },
                            );
                          },
                        ),
                      const SizedBox(
                        height: 180,
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
