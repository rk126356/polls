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
          .collection('allVotes')
          .where('userId', isEqualTo: uid)
          .where('pollId', isEqualTo: poll.id)
          .get();

      if (pollRef.docs.isNotEmpty) {
        final data = pollRef.docs.first.data();

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
          .collection('allViews')
          .where('userId', isEqualTo: uid)
          .where('pollId', isEqualTo: poll.id)
          .get();

      if (pollRef.docs.isNotEmpty) {
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

Future<bool> checkIfShared(PollModel poll) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final uid = user.uid;

    try {
      final pollRef = await FirebaseFirestore.instance
          .collection('allShares')
          .where('userId', isEqualTo: uid)
          .where('pollId', isEqualTo: poll.id)
          .get();

      if (pollRef.docs.isNotEmpty) {
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

Future<bool> checkIfSeen(PollModel poll) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final uid = user.uid;

    try {
      final pollRef = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('mySeenPolls')
          .where('userId', isEqualTo: uid)
          .where('pollId', isEqualTo: poll.id)
          .get();

      if (pollRef.docs.isNotEmpty) {
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
