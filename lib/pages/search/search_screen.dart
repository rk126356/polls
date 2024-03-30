import 'package:flutter/material.dart';
import 'package:polls/navigation/side_menu_navbar.dart';
import 'package:polls/pages/search/inside_search_screen.dart';

import '../../const/colors.dart';
import '../../const/fonts.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({
    super.key,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
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
          'search',
          style: AppFonts.headingTextStyle,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.blueGrey[800],
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const InsdieSearchScreen(),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.secondaryColor,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(Icons.search, color: Colors.white),
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              'search...',
                              style: AppFonts.bodyTextStyle
                                  .copyWith(color: Colors.white, fontSize: 18),
                            ),
                          ),
                        ),
                        const Icon(Icons.arrow_forward, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ),
            ),
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
                        Tab(text: 'new'),
                        Tab(text: 'views'),
                        Tab(text: 'votes'),
                      ],
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.grey[400],
                      indicatorColor: Colors.transparent,
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.65,
                    child: const TabBarView(
                      physics: ScrollPhysics(),
                      children: [
                        Text('Tab'),
                        Text('Tab'),
                        Text('Tab'),
                        Text('Tab'),
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
