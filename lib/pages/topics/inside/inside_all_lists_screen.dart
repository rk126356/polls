// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:polls/const/fonts.dart';
import 'package:polls/controllers/fetch_user.dart';
import 'package:polls/models/lists_model.dart';
import 'package:polls/pages/search/inside_search_screen.dart';
import 'package:polls/utils/snackbar_widget.dart';
import 'package:polls/widgets/custom_error_box_wdiget.dart';
import 'package:polls/widgets/list_box_widget.dart';

import '../../../const/colors.dart';

class InsideALlListsScreen extends StatefulWidget {
  const InsideALlListsScreen({super.key});

  @override
  State<InsideALlListsScreen> createState() => _InsideALlListsScreenState();
}

class _InsideALlListsScreenState extends State<InsideALlListsScreen> {
  final List<ListsModel> _lists = [];

  int listLength = 10;

  DocumentSnapshot? lastDocument;
  bool _isLoading = false;
  bool _isButtonLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchLists(false, context);
  }

  Future<void> _fetchLists(bool next, context) async {
    if (!next) {
      _lists.clear();
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
          .collection('allLists')
          .orderBy('createdAt', descending: true)
          .startAfter([lastDocument?['createdAt']])
          .limit(listLength)
          .get();
    } else {
      quizCollection = await firestore
          .collection('allLists')
          .orderBy('createdAt', descending: true)
          .limit(listLength)
          .get();
    }

    if (quizCollection.docs.isEmpty) {
      if (next) {
        showCoolErrorSnackbar(context, 'no more lists available.');
      }
      setState(() {
        _isButtonLoading = false;
        _isLoading = false;
      });
      return;
    }

    lastDocument =
        quizCollection.docs.isNotEmpty ? quizCollection.docs.last : null;

    for (final listDoc in quizCollection.docs) {
      final pollData = listDoc.data();
      final list = ListsModel.fromJson(pollData);
      list.user = await fetchUser(list.userId);
      _lists.add(list);
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
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const InsdieSearchScreen()),
                );
              },
              icon: const Icon(Icons.search))
        ],
        title: Text(
          'all lists',
          style: AppFonts.headingTextStyle,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _lists.isEmpty && !_isLoading
              ? const CustomErrorBox(text: 'no lists available!')
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: _lists.length + 1,
                        itemBuilder: (context, index) {
                          if (index == _lists.length) {
                            return Center(
                              child: _isButtonLoading
                                  ? const CircularProgressIndicator()
                                  : Column(
                                      children: [
                                        if (_lists.length >= 10)
                                          ElevatedButton(
                                            onPressed: () {
                                              _fetchLists(true, context);
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
                          final list = _lists[index];

                          return Padding(
                            padding: const EdgeInsets.only(
                                left: 8, right: 8, top: 4),
                            child: ListBox(list: list, shouldTap: true),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}
