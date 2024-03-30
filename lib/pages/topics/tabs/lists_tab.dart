import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:polls/pages/topics/inside/inside_all_lists_screen.dart';

import '../../../const/colors.dart';
import '../../../const/fonts.dart';
import '../../../controllers/fetch_user.dart';
import '../../../models/lists_model.dart';
import '../../../widgets/custom_error_box_wdiget.dart';
import '../../../widgets/list_box_widget.dart';

class ListsTab extends StatefulWidget {
  const ListsTab({Key? key}) : super(key: key);

  @override
  State<ListsTab> createState() => _ListsTabState();
}

class _ListsTabState extends State<ListsTab> {
  final List<ListsModel> _lists = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchLists();
  }

  Future<void> _fetchLists() async {
    _lists.clear();
    setState(() {
      _isLoading = true;
    });

    final firestore = FirebaseFirestore.instance;

    final quizCollection = await firestore
        .collection('allLists')
        .orderBy('createdAt', descending: true)
        .limit(10)
        .get();

    if (quizCollection.docs.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    for (final listDoc in quizCollection.docs) {
      final pollData = listDoc.data();
      final list = ListsModel.fromJson(pollData);
      list.user = await fetchUser(list.userId);
      _lists.add(list);
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fourthColor,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _lists.isEmpty && !_isLoading
              ? const CustomErrorBox(text: 'nothing available!')
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: _lists.length,
                        itemBuilder: (context, index) {
                          final list = _lists[index];

                          return Padding(
                            padding: const EdgeInsets.only(
                                left: 8, right: 8, top: 4),
                            child: ListBox(list: list, shouldTap: true),
                          );
                        },
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const InsideALlListsScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            AppColors.secondaryColor, // Change the button color
                      ),
                      child: Text('all lists', style: AppFonts.buttonTextStyle),
                    ),
                  ],
                ),
    );
  }
}
