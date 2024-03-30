import 'package:flutter/material.dart';
import 'package:polls/navigation/side_menu_navbar.dart';
import 'package:polls/pages/topics/tabs/tags_tab.dart';
import 'package:polls/pages/topics/tabs/topic_list_tab.dart';

import '../../const/colors.dart';
import '../../const/fonts.dart';
import 'tabs/lists_tab.dart';

class TopicsScreen extends StatefulWidget {
  const TopicsScreen({
    super.key,
  });

  @override
  State<TopicsScreen> createState() => _TopicsScreenState();
}

class _TopicsScreenState extends State<TopicsScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fourthColor,
      drawer: const NavBar(),
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings),
          )
        ],
        iconTheme: const IconThemeData(color: AppColors.headingText),
        centerTitle: true,
        backgroundColor: AppColors.primaryColor,
        title: Text(
          'topics',
          style: AppFonts.headingTextStyle,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DefaultTabController(
              length: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                    color: Colors.blueGrey[800],
                    child: TabBar(
                      onTap: (index) {
                        setState(() {
                          _selectedIndex = index;
                        });
                      },
                      tabs: const [
                        Tab(text: 'trending'),
                        Tab(text: 'popular'),
                        Tab(text: 'lists'),
                        Tab(text: 'tags'),
                      ],
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.grey[400],
                      indicatorColor: Colors.transparent,
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.75,
                    child: const TabBarView(
                      physics: ScrollPhysics(),
                      children: [
                        TopicListTab(
                          userId: 'ZjaTCKmmjgQ46TVlKo6BXTpBXi92',
                        ),
                        TopicListTab(
                          userId: 'MnlmSbGA39ResrwqWjkv5yHeADw2',
                        ),
                        ListsTab(),
                        TagsTab(),
                      ],
                    ),
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
