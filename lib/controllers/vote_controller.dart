import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:polls/controllers/check_if_tasks.dart';
import 'package:polls/utils/snackbar_widget.dart';
import 'package:provider/provider.dart';

import '../models/polls_model.dart';
import '../provider/user_provider.dart';
import '../utils/publish.dart';

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

    updatePost('${poll.question} - id: ${poll.id}',
        '${poll.question} - id: ${poll.id}', generatePostContent(poll), poll);

    await FirebaseFirestore.instance.collection('allVotes').doc().set({
      'userId': provider.userData.userId,
      'option': option,
      'why': why ?? '',
      'createdAt': Timestamp.now(),
      'pollId': poll.id,
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
  required PollModel poll,
  required String userId,
}) async {
  try {
    final pollId = poll.id;
    final listRef = await FirebaseFirestore.instance
        .collection('allLists')
        .where('lists', arrayContainsAny: [pollId]).get();

    final batch = FirebaseFirestore.instance.batch();

    await deletePost(poll);

    for (final listDoc in listRef.docs) {
      final lists = List<String>.from(listDoc.data()['lists']);
      lists.remove(pollId);

      batch.update(listDoc.reference, {'lists': lists});
    }

    final votesRef = await FirebaseFirestore.instance
        .collection('allVotes')
        .where('pollId', isEqualTo: pollId)
        .get();

    for (final doc in votesRef.docs) {
      batch.delete(doc.reference);
    }

    final shareRef = await FirebaseFirestore.instance
        .collection('allShares')
        .where('pollId', isEqualTo: pollId)
        .get();

    for (final doc in shareRef.docs) {
      batch.delete(doc.reference);
    }

    final viewRef = await FirebaseFirestore.instance
        .collection('allViews')
        .where('pollId', isEqualTo: pollId)
        .get();

    for (final doc in viewRef.docs) {
      batch.delete(doc.reference);
    }

    final pollRef = await FirebaseFirestore.instance
        .collection('allPolls')
        .doc(pollId)
        .get();

    batch.delete(pollRef.reference);

    await batch.commit();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update({'noOfPolls': FieldValue.increment(-1)});

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

    await Future.wait([
      FirebaseFirestore.instance.collection('allViews').doc().set({
        'userId': provider.userData.userId,
        'createdAt': Timestamp.now(),
        'pollId': poll.id,
      }),
      pollRef.update({
        'views': FieldValue.increment(1),
      }),
    ]);

    return false;
  } catch (error) {
    if (kDebugMode) {
      print('Error updating views: $error');
    }
    return false;
  }
}

Future<bool> saveShares({
  required context,
  required PollModel poll,
}) async {
  final provider = Provider.of<UserProvider>(context, listen: false);

  try {
    final pollRef =
        FirebaseFirestore.instance.collection('allPolls').doc(poll.id);

    final pollData = await pollRef.get();

    final isShared = await checkIfShared(poll);

    if (isShared) {
      return true;
    }

    if (!pollData.exists) {
      return false;
    }

    await FirebaseFirestore.instance.collection('allShares').doc().set({
      'userId': provider.userData.userId,
      'createdAt': Timestamp.now(),
      'pollId': poll.id,
    });

    await pollRef.update({
      'shares': FieldValue.increment(1),
    });

    return false;
  } catch (error) {
    if (kDebugMode) {
      print('Error updating views: $error');
    }
    return false;
  }
}

Future<bool> saveSeen({
  required context,
  required PollModel poll,
}) async {
  final provider = Provider.of<UserProvider>(context, listen: false);

  try {
    final isSeen = await checkIfSeen(poll);

    if (isSeen) {
      return false;
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(provider.userData.userId)
        .collection('mySeenPolls')
        .doc()
        .set({
      'userId': provider.userData.userId,
      'createdAt': Timestamp.now(),
      'pollId': poll.id,
    });

    return true;
  } catch (error) {
    if (kDebugMode) {
      print('Error updating views: $error');
    }
    return false;
  }
}

Future<bool> deleteSeenData({
  required context,
}) async {
  final provider = Provider.of<UserProvider>(context, listen: false);

  try {
    final seenRef = FirebaseFirestore.instance
        .collection('users')
        .doc(provider.userData.userId)
        .collection('mySeenPolls');

    final querySnapshot = await seenRef.get();

    final batch = FirebaseFirestore.instance.batch();
    for (var doc in querySnapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();

    return true;
  } catch (error) {
    if (kDebugMode) {
      print('Error updating views: $error');
    }
    return false;
  }
}
