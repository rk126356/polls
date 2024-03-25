import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../models/polls_model.dart';
import '../check_if_tasks.dart';

Future<PollModel?> getPoll(String pollId) async {
  try {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('allPolls')
        .where('id', isEqualTo: pollId)
        .get();
    if (snapshot.docs.isEmpty) {
      return null;
    }
    final doc = snapshot.docs.first;

    final poll = PollModel.fromJson(doc.data() as Map<String, dynamic>);

    final data = await checkIfVoted(poll);
    poll.isVoted = data.isVoted;
    poll.option = data.option;

    return poll;
  } catch (e) {
    if (kDebugMode) {
      print(e);
    }
    return null;
  }
}
