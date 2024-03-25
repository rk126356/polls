import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:polls/controllers/check_if_tasks.dart';
import 'package:polls/utils/snackbar_widget.dart';
import 'package:provider/provider.dart';

import '../models/polls_model.dart';
import '../provider/user_provider.dart';

Future<void> vote({
  context,
  required PollModel poll,
  required String optionId,
  required String option,
  String? why,
}) async {
  final provider = Provider.of<UserProvider>(context, listen: false);

  try {
    final pollRef =
        FirebaseFirestore.instance.collection('allPolls').doc(poll.id);

    final pollData = await pollRef.get();

    final isVoted = await checkIfVoted(poll);

    if (isVoted.isVoted) {
      showCoolErrorSnackbar(context, 'already voted');
      return;
    }

    if (!pollData.exists) {
      showCoolErrorSnackbar(context, 'poll is not found!');
      return;
    }

    await pollRef.collection('votes').doc(provider.userData.userId).set({
      'userId': provider.userData.userId,
      'option': option,
      'why': why ?? '',
      'createdAt': Timestamp.now(),
      'pollId': poll.id,
    });

    CollectionReference userRef = FirebaseFirestore.instance
        .collection('users/${provider.userData.userId}/myVotedPolls');

    await userRef.doc(poll.id).set({
      'pollId': poll.id,
      'option': option,
      'why': why ?? '',
      'userId': provider.userData.userId,
      'createdAt': Timestamp.now(),
    });

    await pollRef.update({
      'options.$optionId.votes': FieldValue.increment(1),
      'totalVotes': FieldValue.increment(1),
    });
  } catch (error) {
    if (kDebugMode) {
      print('Error updating vote: $error');
    }
  }
}

Future<bool> deletePoll({
  context,
  required String pollId,
}) async {
  try {
    final pollRef =
        FirebaseFirestore.instance.collection('allPolls').doc(pollId);

    final votesRef = await pollRef.collection('votes').get();

    await pollRef.delete();

    for (final element in votesRef.docs) {
      await element.reference.delete();
    }

    return true;
  } catch (error) {
    if (kDebugMode) {
      print('Error deleting poll: $error');
    }
    return false;
  }
}

Future<bool> pollFound({
  context,
  required String pollId,
}) async {
  try {
    final pollRef =
        FirebaseFirestore.instance.collection('allPolls').doc(pollId);
    final pollData = await pollRef.get();

    if (pollData.exists) {
      return true;
    } else {
      return false;
    }
  } catch (error) {
    if (kDebugMode) {
      print('Error deleting poll: $error');
    }
    return false;
  }
}

Future<bool> saveViews({
  required context,
  required PollModel poll,
}) async {
  final provider = Provider.of<UserProvider>(context, listen: false);

  try {
    final pollRef =
        FirebaseFirestore.instance.collection('allPolls').doc(poll.id);

    final pollData = await pollRef.get();

    final isViewed = await checkIfViewed(poll);

    if (isViewed) {
      return true;
    }

    if (!pollData.exists) {
      return false;
    }

    print('Views increased');

    await pollRef.collection('views').doc(provider.userData.userId).set({
      'userId': provider.userData.userId,
      'createdAt': Timestamp.now(),
      'pollId': poll.id,
    });

    CollectionReference userRef = FirebaseFirestore.instance
        .collection('users/${provider.userData.userId}/myViewedPolls');

    await userRef.doc(poll.id).set({
      'pollId': poll.id,
      'userId': provider.userData.userId,
      'createdAt': Timestamp.now(),
    });

    await pollRef.update({
      'views': FieldValue.increment(1),
    });

    return false;
  } catch (error) {
    if (kDebugMode) {
      print('Error updating views: $error');
    }
    return false;
  }
}
