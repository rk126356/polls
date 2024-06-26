import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../../models/user_model.dart';
import '../../navigation/bottom_nav_screen.dart';
import '../../provider/user_provider.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _fetchAndSetUser() async {
    User? user = _auth.currentUser;

    if (user != null) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      final userDoc =
          FirebaseFirestore.instance.collection('users').doc(user.uid);
      final userDocSnapshot = await userDoc.get();

      if (userDocSnapshot.exists) {
        final user =
            UserModel.fromJson(userDocSnapshot.data() as Map<String, dynamic>);
        userProvider.setUserData(user);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchAndSetUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: _auth.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            User? user = snapshot.data;
            if (user != null) _fetchAndSetUser();
            return const CircularProgressIndicator();
          } else {
            if (snapshot.hasData && snapshot.data != null) {
              // User is signed in, navigate to home screen
              return const BottomNavScreen();
            } else {
              // User is not signed in, navigate to login screen
              return const LoginScreen();
            }
          }
        },
      ),
    );
  }
}
