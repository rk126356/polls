// Function to add a poll to Firestore
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:polls/models/voted_model.dart';

import '../models/polls_model.dart';

Future<VotedModel> checkIfVoted(PollModel poll) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final uid = user.uid;

    try {
      final pollRef = await FirebaseFirestore.instance
          .collection('allPolls')
          .doc(poll.id)
          .collection('votes')
          .doc(uid)
          .get();

      if (pollRef.exists) {
        final data = pollRef.data();

        if (data != null) {
          final voted = VotedModel(
              isVoted: true,
              option: data['option'],
              userId: data['userId'],
              pollId: data['pollId']);
          return voted;
        } else {
          final voted = VotedModel(
            isVoted: false,
          );
          return voted;
        }
      } else {
        final voted = VotedModel(
          isVoted: false,
        );
        return voted;
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error adding poll played to Firestore: $error');
      }
      final voted = VotedModel(
        isVoted: false,
      );
      return voted;
    }
  } else {
    final voted = VotedModel(
      isVoted: false,
    );
    return voted;
  }
}

Future<bool> checkIfViewed(PollModel poll) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final uid = user.uid;

    try {
      final pollRef = await FirebaseFirestore.instance
          .collection('allPolls')
          .doc(poll.id)
          .collection('views')
          .doc(uid)
          .get();

      if (pollRef.exists) {
        return true;
      } else {
        return false;
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error adding poll played to Firestore: $error');
      }

      return false;
    }
  } else {
    return false;
  }
}
