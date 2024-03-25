import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/user_model.dart';

Future<UserModel?> fetchUser(String uid) async {
  final userDoc = FirebaseFirestore.instance.collection('users').doc(uid);
  final userDocSnapshot = await userDoc.get();

  if (userDocSnapshot.exists) {
    final userData = userDocSnapshot.data();
    try {
      if (userData != null) {
        return UserModel.fromJson(userData);
      } else {
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    }
  } else {
    if (kDebugMode) {
      print('User not found');
    }
    return null;
  }
}
