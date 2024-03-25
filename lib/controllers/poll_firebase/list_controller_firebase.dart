import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:polls/models/lists_model.dart';
import 'package:polls/provider/user_provider.dart';
import 'package:polls/utils/generate_random_id.dart';
import 'package:polls/utils/get_search_terms.dart';
import 'package:provider/provider.dart';

import '../../models/polls_model.dart';

Future<String> saveListName(context, PollModel poll, String name) async {
  final provider = Provider.of<UserProvider>(context, listen: false);
  final isAlreadyAdded = await checkList(context, name);
  try {
    if (isAlreadyAdded.isNotEmpty) {
      final pollRef = await FirebaseFirestore.instance
          .collection('allLists')
          .where('userId', isEqualTo: provider.userData.userId)
          .where('name', isEqualTo: name)
          .get();

      pollRef.docs.first.reference.update({
        'lists': FieldValue.arrayUnion([poll.id]),
        'createdAt': Timestamp.now(),
      });
      return isAlreadyAdded;
    } else {
      final pollRef = FirebaseFirestore.instance.collection('allLists');
      final id = generateRandomId(6);
      List<String> searchFields = parseSearchTerms(name);
      searchFields.add(id);
      pollRef.add({
        'id': id,
        'name': name,
        'lists': [poll.id],
        'userId': provider.userData.userId,
        'searchFields': searchFields,
        'createdAt': Timestamp.now(),
      });
      return id;
    }
  } catch (error) {
    if (kDebugMode) {
      print('Error adding poll played to Firestore: $error');
    }
    return '';
  }
}

Future<String> checkList(context, String name) async {
  final provider = Provider.of<UserProvider>(context, listen: false);
  try {
    final pollRef = await FirebaseFirestore.instance
        .collection('allLists')
        .where('userId', isEqualTo: provider.userData.userId)
        .where('name', isEqualTo: name)
        .get();
    if (pollRef.docs.isNotEmpty) {
      final listId = pollRef.docs.first.data()['id'];
      return listId;
    } else {
      return '';
    }
  } catch (error) {
    if (kDebugMode) {
      print('Error adding poll played to Firestore: $error');
    }
    return '';
  }
}

Future<List<String>> getLists(context, String serach) async {
  final provider = Provider.of<UserProvider>(context, listen: false);
  try {
    final pollRef = await FirebaseFirestore.instance
        .collection('allLists')
        .where('userId', isEqualTo: provider.userData.userId)
        .where('searchFields', arrayContainsAny: [serach.trim().toLowerCase()])
        .limit(10)
        .get();
    List<String> lists = [];

    if (pollRef.docs.isNotEmpty) {
      for (var doc in pollRef.docs) {
        ListsModel list = ListsModel.fromJson(doc.data());

        lists.add(list.name);
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
