import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:polls/models/lists_model.dart';
import 'package:polls/models/polls_model.dart';
import 'package:polls/models/user_model.dart';
import 'package:polls/widgets/list_box_widget.dart';
import 'package:polls/widgets/loading_polls_shimmer_widget.dart';
import 'package:polls/widgets/loading_user_box_widget.dart';
import 'package:polls/widgets/tags_box_widget.dart';
import 'package:polls/widgets/user_box_widget.dart';
import '../../const/colors.dart';
import '../../const/fonts.dart';
import '../../utils/check_and_return_polls.dart';
import '../../widgets/poll_item_widget.dart';

class InsdieSearchScreen extends StatefulWidget {
  const InsdieSearchScreen({Key? key}) : super(key: key);

  @override
  State<InsdieSearchScreen> createState() => _InsdieSearchScreenState();
}

class _InsdieSearchScreenState extends State<InsdieSearchScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController _searchController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _selectedIndex = 0;
  List<PollModel> _polls = [];
  List<UserModel> _users = [];
  final List<String> _allTags = [];
  List<ListsModel> _allLists = [];
  bool _isLoading = false;

  Future<void> _searchPolls(String searchText) async {
    if (searchText.isEmpty) {
      setState(() {
        _polls.clear();
      });
      return;
    }

    QuerySnapshot snapshot = await _firestore
        .collection('allPolls')
        .orderBy('timestamp', descending: true)
        .where('searchFields', arrayContainsAny: [searchText])
        .limit(10)
        .get();

    _polls = snapshot.docs
        .map((doc) => PollModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();

    if (_polls.isNotEmpty) {
      _polls = await checkAndReturnPolls(_polls);
    }
    print('polls');
    setState(() {});
  }

  Future<void> _searchUsers(String searchText) async {
    if (searchText.isEmpty) {
      setState(() {
        _users.clear();
      });
      return;
    }

    QuerySnapshot snapshot = await _firestore
        .collection('users')
        .where('searchFields', arrayContainsAny: [searchText])
        .limit(10)
        .get();

    _users = snapshot.docs
        .map((doc) => UserModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
    print('users');
    setState(() {});
  }

  Future<void> _searchTags(String searchText) async {
    if (searchText.isEmpty) {
      setState(() {
        _allTags.clear();
      });
      return;
    }

    final snapshot = await _firestore
        .collection('allTags')
        .where('searchFields', arrayContainsAny: [searchText])
        .limit(10)
        .get();

    for (final tagDoc in snapshot.docs) {
      final tagData = tagDoc.data();
      final tag = tagData['tag'];
      print(tag);
      if (!_allTags.contains(tag)) {
        _allTags.add(tag);
      }
    }

    print('tags');
    setState(() {});
  }

  Future<void> _searchLists(String searchText) async {
    if (searchText.isEmpty) {
      setState(() {
        _allLists.clear();
      });
      return;
    }

    final snapshot = await _firestore
        .collection('allLists')
        .where('searchFields', arrayContainsAny: [searchText])
        .limit(10)
        .get();

    _allLists =
        snapshot.docs.map((doc) => ListsModel.fromJson(doc.data())).toList();

    print('list');
    setState(() {});
  }

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabIndexChanged);
  }

  void _onTabIndexChanged() {
    _selectedIndex = _tabController.index;
    _search(_searchController.text);
  }

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
    _tabController.dispose();
  }

  void _search(String text) async {
    setState(() {
      _isLoading = true;
    });
    if (_selectedIndex == 0) {
      await _searchPolls(text);
    }
    if (_selectedIndex == 1) {
      await _searchUsers(text);
    }
    if (_selectedIndex == 2) {
      await _searchTags(text);
    }
    if (_selectedIndex == 3) {
      await _searchLists(text);
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fourthColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        iconTheme: const IconThemeData(color: AppColors.headingText),
        backgroundColor: AppColors.primaryColor,
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'type...',
            hintStyle: const TextStyle(color: AppColors.headingText),
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
            prefixIcon: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear, color: AppColors.headingText),
              onPressed: () {
                _searchController.clear();
              },
            ),
          ),
          style:
              AppFonts.headingTextStyle.copyWith(fontWeight: FontWeight.normal),
          onChanged: (value) {
            _search(value);
          },
        ),
      ),
      body: DefaultTabController(
        initialIndex: _selectedIndex,
        length: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              color: Colors.blueGrey[800],
              child: TabBar(
                controller: _tabController,
                // onTap: (index) {
                //   setState(() {
                //     _selectedIndex = index;
                //   });
                //   _search(_searchController.text);
                // },
                tabs: const [
                  Tab(text: 'polls'),
                  Tab(text: 'users'),
                  Tab(text: 'tags'),
                  Tab(text: 'lists'),
                ],
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey[400],
                indicatorColor: Colors.transparent,
              ),
            ),
            Expanded(
              child: TabBarView(
                // physics: const NeverScrollableScrollPhysics(),
                controller: _tabController,
                children: [
                  _isLoading
                      ? const SingleChildScrollView(
                          child: LoadingPollsShimmer())
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: _polls.length,
                          itemBuilder: (context, index) {
                            final poll = _polls[index];
                            return PollCard(
                              key: PageStorageKey(poll.id),
                              poll: poll,
                              isInsideList: false,
                              deleteTap: () {
                                setState(() {
                                  _polls.removeAt(index);
                                });
                              },
                            );
                          },
                        ),
                  // Contents for New tab
                  _isLoading
                      ? const SingleChildScrollView(
                          child: Column(
                          children: [
                            LoadingUserBoxShimmer(),
                          ],
                        ))
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: _users.length,
                          itemBuilder: (context, index) {
                            final user = _users[index];
                            return UserBoxLoop(user: user);
                          },
                        ),
                  // Contents for Views tab
                  _isLoading
                      ? const SingleChildScrollView(
                          child: Column(
                          children: [
                            LoadingUserBoxShimmer(),
                          ],
                        ))
                      : ListView.builder(
                          itemCount: _allTags.length,
                          itemBuilder: (context, index) {
                            return TagsBox(
                              title: _allTags[index],
                            );
                          },
                        ),
                  // Contents for Random tab
                  _isLoading
                      ? const SingleChildScrollView(
                          child: Column(
                          children: [
                            LoadingUserBoxShimmer(),
                          ],
                        ))
                      : ListView.builder(
                          itemCount: _allLists.length,
                          itemBuilder: (context, index) {
                            return ListBox(
                              list: _allLists[index],
                              shouldTap: true,
                            );
                          },
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
