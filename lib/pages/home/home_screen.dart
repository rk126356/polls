// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:polls/pages/polls/create_poll_screen.dart';
import 'package:polls/utils/check_and_return_polls.dart';

import '../../const/colors.dart';
import '../../const/fonts.dart';
import '../../models/polls_model.dart';
import '../../navigation/side_menu_navbar.dart';
import '../../widgets/loading_polls_shimmer_widget.dart';
import '../../widgets/poll_item_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<PollModel> polls = [];

  ScrollController forYouScrollController = ScrollController();
  ScrollController followingsScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchPolls();
  }

  @override
  void dispose() {
    forYouScrollController.dispose();
    followingsScrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchPolls() async {
    QuerySnapshot snapshot = await _firestore
        .collection('allPolls')
        .orderBy('timestamp', descending: true)
        .get();

    polls = snapshot.docs
        .map((doc) => PollModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();

    polls = await checkAndReturnPolls(polls);

    setState(() {});
  }

  Future<void> _refreshPolls() async {
    await _fetchPolls();
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
            RefreshIndicator(
              onRefresh: _refreshPolls,
              child: PageStorage(
                key: const PageStorageKey('ForYouTab'),
                bucket: PageStorageBucket(),
                child: SingleChildScrollView(
                  controller: forYouScrollController,
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
                          controller: forYouScrollController,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: polls.length,
                          itemBuilder: (context, index) {
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
