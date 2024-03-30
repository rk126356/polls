import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:polls/pages/polls/inside/inside_tag_screen.dart';
import 'package:polls/pages/search/inside_search_screen.dart';
import 'package:polls/utils/snackbar_widget.dart';

import '../../../const/colors.dart';
import '../../../const/fonts.dart';
import '../../../widgets/all_tags_box_widget.dart';

class InsideAllTagsScreen extends StatefulWidget {
  const InsideAllTagsScreen({Key? key}) : super(key: key);

  @override
  State<InsideAllTagsScreen> createState() => _InsideAllTagsScreenState();
}

class _InsideAllTagsScreenState extends State<InsideAllTagsScreen> {
  final List tagItems = [];
  int listLength = 9;

  DocumentSnapshot? lastDocument;
  bool _isLoading = false;
  bool _isButtonLoading = false;

  Future<void> _fetchTags(bool next, context) async {
    if (tagItems.isEmpty) {
      setState(() {
        _isLoading = true;
      });
    }
    final firestore = FirebaseFirestore.instance;

    QuerySnapshot<Map<String, dynamic>> tagsCollection;

    if (next) {
      setState(() {
        _isButtonLoading = true;
      });
      tagsCollection = await firestore
          .collection('allTags')
          .orderBy('createdAt')
          .startAfter([lastDocument?['createdAt']])
          .limit(listLength)
          .get();
    } else {
      tagsCollection = await firestore
          .collection('allTags')
          .orderBy('createdAt')
          .limit(listLength)
          .get();
    }

    if (tagsCollection.docs.isEmpty) {
      if (next) {
        showCoolErrorSnackbar(context, 'no more tags available.');
      }
      setState(() {
        _isButtonLoading = false;
        _isLoading = false;
      });
      return;
    }

    lastDocument =
        tagsCollection.docs.isNotEmpty ? tagsCollection.docs.last : null;

    for (final tagDoc in tagsCollection.docs) {
      final tagData = tagDoc.data();

      if (!tagItems.contains(tagData['tag'])) {
        tagItems.add(tagData['tag']);
      } else {
        if (kDebugMode) {
          print('${tagData['tag']} already exists');
        }
      }
    }
    setState(() {
      _isLoading = false;
      _isButtonLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchTags(false, context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fourthColor,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: AppColors.headingText),
        centerTitle: true,
        backgroundColor: AppColors.primaryColor,
        title: Text(
          'all tags',
          style: AppFonts.headingTextStyle,
        ),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const InsdieSearchScreen()),
                );
              },
              icon: const Icon(CupertinoIcons.search))
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: <Widget>[
                    const SizedBox(
                      height: 10,
                    ),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: List.generate(tagItems.length, (index) {
                        return AllTagsBox(
                          title: tagItems[index],
                          backgroundColor: predefinedColors[
                              Random().nextInt(predefinedColors.length)],
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => InsideTagScreen(
                                        tag: tagItems[index],
                                      )),
                            );
                          },
                        );
                      }),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    _buildLoadMoreButton(),
                    const SizedBox(
                      height: 25,
                    )
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildLoadMoreButton() {
    return _isButtonLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        AppColors.secondaryColor, // Set the background color
                  ),
                  onPressed: () {
                    _fetchTags(true, context);
                  },
                  child: Text(
                    'load more...',
                    style: AppFonts.buttonTextStyle,
                  ),
                ),
              ),
              const SizedBox(
                height: 30,
              )
            ],
          );
  }
}
