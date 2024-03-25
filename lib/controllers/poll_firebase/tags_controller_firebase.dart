import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:polls/utils/get_search_terms.dart';

Future<void> saveTag(String tag) async {
  final isAlreadyAdded = await checkTag(tag);
  try {
    if (!isAlreadyAdded) {
      final pollRef = FirebaseFirestore.instance.collection('allTags');

      pollRef.doc(tag).set({
        'tag': tag,
        'searchFields': parseSearchTerms(tag),
        'createdAt': Timestamp.now(),
      });
    }
  } catch (error) {
    if (kDebugMode) {
      print('Error adding tags to Firestore: $error');
    }
  }
}

Future<bool> checkTag(String tag) async {
  try {
    final pollRef = await FirebaseFirestore.instance
        .collection('allTags')
        .where('tag', isEqualTo: tag)
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
}

Future<List<String>> getTags(String serach) async {
  try {
    final pollRef = await FirebaseFirestore.instance
        .collection('allTags')
        .where('searchFields', arrayContainsAny: [serach])
        .limit(10)
        .get();
    List<String> lists = [];

    if (pollRef.docs.isNotEmpty) {
      for (var doc in pollRef.docs) {
        lists.add(doc['tag']);
      }
    }

    return lists;
  } catch (error) {
    if (kDebugMode) {
      print('Error retrieving lists from Firestore: $error');
    }
    return []; // Return an empty list in case of error
  }
}
