// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:polls/utils/check_and_return_polls.dart';
import 'package:polls/widgets/custom_error_box_wdiget.dart';
import 'package:polls/widgets/list_box_widget.dart';
import 'package:polls/widgets/loading_polls_shimmer_widget.dart';
import 'package:polls/widgets/loading_user_box_widget.dart';

import '../../../const/colors.dart';
import '../../../const/fonts.dart';
import '../../../models/lists_model.dart';
import '../../../models/polls_model.dart';
import '../../../widgets/poll_item_widget.dart';

class InsideListsScreen extends StatefulWidget {
  const InsideListsScreen({super.key, required this.id, required this.name});

  @override
  State<InsideListsScreen> createState() => _InsideListsScreenState();

  final String id;
  final String name;
}

class _InsideListsScreenState extends State<InsideListsScreen> {
  List<PollModel> polls = [];
  List<String> lists = [];
  ListsModel? _list;
  bool isSortByNew = true;
  bool _isLoading = false;

  void fetchList() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final pollRef = await FirebaseFirestore.instance
          .collection('allLists')
          .where('id', isEqualTo: widget.id)
          .get();

      if (pollRef.docs.isNotEmpty) {
        for (var doc in pollRef.docs) {
          ListsModel list = ListsModel.fromJson(doc.data());
          _list = list;
          setState(() {
            lists.addAll(list.lists);
          });

          fetchPolls();
        }
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (error) {
      print('Error retrieving lists from Firestore: $error');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> fetchPolls() async {
    setState(() {
      _isLoading = true;
    });
    polls.clear();
    List<PollModel> allPolls = [];
    for (final pollId in isSortByNew ? lists.reversed : lists) {
      final snapshot = await FirebaseFirestore.instance
          .collection('allPolls')
          .where('id', isEqualTo: pollId)
          .get();

      final poll = PollModel.fromJson(snapshot.docs.first.data());

      allPolls.add(poll);
    }

    polls = await checkAndReturnPolls(allPolls);

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
    await fetchPolls();
  }

  @override
  void initState() {
    super.initState();
    fetchList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fourthColor,
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.bookmark_add_outlined),
          )
        ],
        iconTheme: const IconThemeData(color: AppColors.headingText),
        centerTitle: true,
        backgroundColor: AppColors.primaryColor,
        title: Text(
          'list (${lists.length})',
          style: AppFonts.headingTextStyle,
        ),
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
                          widget.name,
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
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  if (_isLoading)
                    const Column(
                      children: [
                        LoadingPollsShimmer(),
                        LoadingPollsShimmer(),
                      ],
                    ),
                  if (polls.isEmpty && !_isLoading)
                    const Column(
                      children: [
                        CustomErrorBox(
                          text: 'list is deleted or something went wrong!',
                        ),
                      ],
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: polls.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return _list == null
                              ? const LoadingUserBoxShimmer()
                              : Padding(
                                  padding: const EdgeInsets.only(
                                      top: 8, left: 8, right: 8),
                                  child: ListBox(
                                    list: _list!,
                                    shouldTap: false,
                                  ),
                                );
                        } else {
                          return PollCard(
                            poll: polls[index - 1],
                            isInsideList: true,
                          );
                        }
                      },
                    ),
                  const SizedBox(
                    height: 180,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
