import 'package:flutter/material.dart';
import 'package:polls/const/fonts.dart';
import 'package:polls/pages/profile/profile_screen.dart';

import '../const/colors.dart';
import '../pages/home/home_screen.dart';
import '../pages/search/search_screen.dart';

class BottomNavScreen extends StatefulWidget {
  const BottomNavScreen({Key? key}) : super(key: key);

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = <Widget>[
    const HomeScreen(key: PageStorageKey('HomeScreen')),
    const SearchScreen(key: PageStorageKey('SearchScreen')),
    const SearchScreen(key: PageStorageKey('TopicsScreen')),
    const ProfileScreen(key: PageStorageKey('ProfileScreen')),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.grey[900],
        unselectedItemColor: Colors.grey[600],
        selectedItemColor: AppColors.headingText,
        selectedLabelStyle: AppFonts.headingTextStyle.copyWith(fontSize: 12),
        unselectedLabelStyle: AppFonts.headingTextStyle.copyWith(fontSize: 12),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            backgroundColor: AppColors.primaryColor,
            icon: Icon(Icons.home_outlined),
            label: 'home',
          ),
          BottomNavigationBarItem(
            backgroundColor: AppColors.primaryColor,
            icon: Icon(Icons.search_outlined),
            label: 'search',
          ),
          BottomNavigationBarItem(
            backgroundColor: AppColors.primaryColor,
            icon: Icon(Icons.topic_outlined),
            label: 'topics',
          ),
          BottomNavigationBarItem(
            backgroundColor: AppColors.primaryColor,
            icon: Icon(Icons.person_outline),
            label: 'profile',
          ),
        ],
      ),
    );
  }
}
