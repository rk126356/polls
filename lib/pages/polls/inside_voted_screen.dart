import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:polls/const/colors.dart';
import 'package:polls/const/fonts.dart';
import 'package:polls/controllers/fetch_user.dart';
import 'package:polls/models/polls_model.dart';
import 'package:polls/models/user_model.dart';
import 'package:polls/widgets/error_poll_widget.dart';
import 'package:polls/widgets/loading_user_box_widget.dart';

import '../../widgets/user_poll_list_box_widget.dart';

class InsideVotedScreen extends StatefulWidget {
  const InsideVotedScreen({Key? key, required this.poll}) : super(key: key);

  @override
  State<InsideVotedScreen> createState() => _InsideVotedScreenState();

  final PollModel poll;
}

class _InsideVotedScreenState extends State<InsideVotedScreen> {
  final List<UserModel> _users = [];
  bool _isLoading = false;
  bool isSortByNew = true;

  void fetchUsers() async {
    setState(() {
      _isLoading = true;
    });
    try {
      _users.clear();
      final pollRef = await FirebaseFirestore.instance
          .collection('allVotes')
          .where('pollId', isEqualTo: widget.poll.id)
          .orderBy('createdAt', descending: isSortByNew)
          .get();

      for (final data in pollRef.docs) {
        final dCode = data.data();
        final userId = dCode['userId'];
        final user = await fetchUser(userId);
        if (user != null) {
          user.votedTimestamp = dCode['createdAt'];
          user.option = dCode['option'];
          user.why = dCode['why'] ?? '';
          final alreadyAdded =
              _users.any((element) => element.userId == user.userId);
          if (!alreadyAdded) {
            _users.add(user);
          }
        }
      }
    } catch (error) {
      print('Error updating vote: $error');
    }
    setState(() {
      _isLoading = false;
    });
  }

  void switchSortBy() async {
    setState(() {
      _isLoading = true;
    });
    setState(() {
      isSortByNew ? isSortByNew = false : isSortByNew = true;
      _isLoading = false;
    });
    fetchUsers();
  }

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fourthColor,
      appBar: AppBar(
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.headingText),
        backgroundColor: AppColors.primaryColor,
        title: Text('votes (${widget.poll.totalVotes})',
            style: AppFonts.headingTextStyle),
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
                      Expanded(
                        child: Text(
                          widget.poll.question,
                          style: AppFonts.headingTextStyle.copyWith(
                            fontSize: 16,
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
          if (_isLoading)
            Column(
              children: [
                if (widget.poll.totalVotes < 10)
                  for (int i = 0; i < widget.poll.totalVotes; i++)
                    const LoadingUserBoxShimmer()
                else
                  for (int i = 0; i < 10; i++) const LoadingUserBoxShimmer(),
              ],
            ),
          if (_users.isEmpty && !_isLoading)
            const ErrorPollBox()
          else
            Expanded(
              child: ListView.builder(
                itemCount: _users.length,
                itemBuilder: (context, index) {
                  final user = _users[index];
                  return UserPollListBox(user: user);
                },
              ),
            ),
        ],
      ),
    );
  }
}
