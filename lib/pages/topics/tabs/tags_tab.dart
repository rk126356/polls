import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:polls/pages/polls/inside/inside_tag_screen.dart';
import 'package:polls/pages/topics/inside/inside_all_tags_screen.dart';
import 'package:polls/utils/snackbar_widget.dart';

import '../../../const/colors.dart';
import '../../../const/fonts.dart';
import '../../../widgets/all_tags_box_widget.dart';

class TagsTab extends StatefulWidget {
  const TagsTab({Key? key}) : super(key: key);

  @override
  State<TagsTab> createState() => _TagsTabState();
}

class _TagsTabState extends State<TagsTab> {
  final List tagItems = [];
  final List topTags = ['#india', '#cricket', '#football'];

  bool _isLoading = false;

  Future<void> _fetchTags(context) async {
    if (tagItems.isEmpty) {
      setState(() {
        _isLoading = true;
      });
    }
    final firestore = FirebaseFirestore.instance;

    final tagsCollection = await firestore
        .collection('allTags')
        .orderBy('createdAt')
        .limit(6)
        .get();

    if (tagsCollection.docs.isEmpty) {
      showCoolErrorSnackbar(context, 'no more tags available.');

      setState(() {
        _isLoading = false;
      });
      return;
    }

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
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchTags(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fourthColor,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: <Widget>[
                    // Top Players This Month leaderboard
                    const SizedBox(height: 18.0),
                    Text("top 3 tags",
                        textAlign: TextAlign.center,
                        style: AppFonts.bodyTextStyle.copyWith(
                          fontSize: 22,
                        )),
                    const SizedBox(height: 12.0),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: List.generate(topTags.length, (index) {
                        return AllTagsBox(
                          title: topTags[index],
                          backgroundColor: predefinedColors[
                              Random().nextInt(predefinedColors.length)],
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => InsideTagScreen(
                                        tag: topTags[index],
                                      )),
                            );
                          },
                        );
                      }),
                    ),
                    const SizedBox(
                      height: 10,
                    ),

                    const SizedBox(
                      height: 22,
                    ),
                    Text("all tags",
                        textAlign: TextAlign.center,
                        style: AppFonts.bodyTextStyle.copyWith(
                          fontSize: 22,
                        )),
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
    return Column(
      children: [
        Center(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  AppColors.secondaryColor, // Set the background color
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const InsideAllTagsScreen()),
              );
            },
            child: Text(
              'all tags',
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
