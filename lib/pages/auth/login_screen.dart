// ignore_for_file: use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:polls/utils/generate_random_id.dart';
import 'package:polls/utils/get_search_terms.dart';
import 'package:polls/utils/snackbar_widget.dart';
import 'package:provider/provider.dart';
import '../../const/colors.dart';
import '../../const/fonts.dart';
import '../../models/user_model.dart';
import '../../provider/user_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLoading = false;

  Future<void> signInWithGoogle(BuildContext context) async {
    var data = Provider.of<UserProvider>(context, listen: false);
    setState(() {
      isLoading = true;
    });
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    try {
      UserCredential authResult =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = authResult.user;

      if (user != null) {
        // Check if the user data already exists in Firestore
        final userDoc =
            FirebaseFirestore.instance.collection('users').doc(user.uid);
        final userDocSnapshot = await userDoc.get();

        if (userDocSnapshot.exists) {
          data.setUserData(UserModel(
            userId: userDocSnapshot['uid'],
            email: userDocSnapshot['email'] ?? '',
            bio: userDocSnapshot['bio'] ?? '',
            name: userDocSnapshot['name'] ?? '',
            avatarUrl: userDocSnapshot['avatarUrl'] ?? '',
            mobileNumber: userDocSnapshot['mobileNumber'] ?? '',
            userName: userDocSnapshot['userName'] ?? '',
          ));
        } else {
          final username = generateRandomId(8);

          await userDoc.set({
            'name': user.displayName,
            'userName': username,
            'searchFields': parseSearchTerms(username) +
                parseSearchTerms(user.displayName!),
            'email': user.email,
            'uid': user.uid,
            'bio': 'no bio available',
            'avatarUrl': user.photoURL,
            'mobileNumber': '',
            'plan': 'free',
            'noOfFollowers': 0,
            'noOfPolls': 0,
            'noOfFollowings': 0,
          });

          data.setUserData(UserModel(
            userId: user.uid,
            email: user.email ?? '',
            bio: 'no bio available',
            name: user.displayName ?? '',
            avatarUrl: user.photoURL ?? '',
            mobileNumber: '',
            userName: username,
          ));
        }

        if (kDebugMode) {
          print('User data stored in Firestore');
        }
      } else {
        showCoolErrorSnackbar(context, 'something went wrong!');
      }

      setState(() {
        isLoading = false;
      });
    } catch (error) {
      if (kDebugMode) {
        print('Error signing in with Google: $error');
      }

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  colors: [AppColors.primaryColor, AppColors.secondaryColor],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/logo_no_bg.png',
                      height: 300,
                      width: 300,
                    ),
                    Text(
                      'publicpolls',
                      style: AppFonts.headingTextStyle
                          .copyWith(fontSize: 36, color: Colors.white),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {
                        signInWithGoogle(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/images/google-logo.png',
                            height: 30,
                            width: 30,
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            "Sign in with Google",
                            style: TextStyle(
                              fontSize: 22,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
