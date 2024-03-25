import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../../models/user_model.dart';
import '../../navigation/bottom_nav_screen.dart';
import '../../provider/user_provider.dart';
import 'login_screen.dart';

class WelcomeDebugScreen extends StatefulWidget {
  const WelcomeDebugScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeDebugScreen> createState() => _WelcomeDebugScreenState();
}

class _WelcomeDebugScreenState extends State<WelcomeDebugScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _fetchAndSetUser();
  }

  Future<void> _fetchAndSetUser() async {
    User? user = _auth.currentUser;

    if (user != null) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      final userDoc =
          FirebaseFirestore.instance.collection('users').doc(user.uid);
      final userDocSnapshot = await userDoc.get();

      if (userDocSnapshot.exists) {
        userProvider.setUserData(UserModel(
          userId: userDocSnapshot['uid'],
          email: userDocSnapshot['email'] ?? '',
          bio: userDocSnapshot['bio'] ?? '',
          name: userDocSnapshot['name'] ?? '',
          avatarUrl: userDocSnapshot['avatarUrl'] ?? '',
          mobileNumber: userDocSnapshot['mobileNumber'] ?? '',
          userName: userDocSnapshot['userName'] ?? '',
        ));

        setState(() {
          _isLoggedIn = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          if (_isLoggedIn) {
            // User is signed in, navigate to home screen
            return const BottomNavScreen();
          } else {
            // User is not signed in, navigate to login screen
            return const LoginScreen();
          }
        },
      ),
    );
  }
}
