import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:polls/models/lists_model.dart';
import 'package:polls/provider/user_provider.dart';
import 'package:polls/utils/generate_random_id.dart';
import 'package:polls/utils/get_search_terms.dart';
import 'package:polls/utils/snackbar_widget.dart';
import 'package:provider/provider.dart';

Future<String> saveListName(
    context, String pollId, String name, bool isShowPopup) async {
  final provider = Provider.of<UserProvider>(context, listen: false);
  final isAlreadyAdded = await checkList(context, name);
  final isPollAdded = await checkListPoll(context, name, pollId);
  if (isPollAdded) {
    if (isShowPopup) {
      showCoolErrorSnackbar(context, 'poll is already added to $name');
    }

    return '';
  }
  try {
    if (isAlreadyAdded.isNotEmpty) {
      final pollRef = await FirebaseFirestore.instance
          .collection('allLists')
          .where('userId', isEqualTo: provider.userData.userId)
          .where('name', isEqualTo: name)
          .get();

      pollRef.docs.first.reference.update({
        'lists': FieldValue.arrayUnion([pollId]),
        'createdAt': Timestamp.now(),
      });
      if (isShowPopup) {
        showCoolSuccessSnackbar(context, 'poll is added to $name');
      }
      return isAlreadyAdded;
    } else {
      final pollRef = FirebaseFirestore.instance.collection('allLists');
      final userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(provider.userData.userId);
      final id = generateRandomId(6);
      List<String> searchFields = parseSearchTerms(name);
      searchFields.add(id);
      await pollRef.add({
        'id': id,
        'name': name,
        'lists': [pollId],
        'userId': provider.userData.userId,
        'searchFields': searchFields,
        'createdAt': Timestamp.now(),
      });

      await userRef.update({
        'noOfLists': FieldValue.increment(1),
      });

      if (isShowPopup) {
        showCoolSuccessSnackbar(context, 'poll is added to $name');
      }
      return id;
    }
  } catch (error) {
    if (kDebugMode) {
      print('Error adding poll played to Firestore: $error');
    }
    showCoolErrorSnackbar(context, 'something went wrong!');
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

Future<bool> checkListPoll(context, String name, String pollId) async {
  final provider = Provider.of<UserProvider>(context, listen: false);
  try {
    final pollRef = await FirebaseFirestore.instance
        .collection('allLists')
        .where('userId', isEqualTo: provider.userData.userId)
        .where('name', isEqualTo: name)
        .where('lists', arrayContainsAny: [pollId]).get();
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

Future<bool> deleteList(context, String id) async {
  final provider = Provider.of<UserProvider>(context, listen: false);
  try {
    final pollRef = await FirebaseFirestore.instance
        .collection('allLists')
        .where('userId', isEqualTo: provider.userData.userId)
        .where('id', isEqualTo: id)
        .get();
    if (pollRef.docs.isNotEmpty) {
      await pollRef.docs.first.reference.delete();
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

Future<bool> deleteListPoll(context, String name, String pollId) async {
  final provider = Provider.of<UserProvider>(context, listen: false);
  try {
    final listRef = await FirebaseFirestore.instance
        .collection('allLists')
        .where('userId', isEqualTo: provider.userData.userId)
        .where('lists', arrayContainsAny: [pollId]).get();

    final batch = FirebaseFirestore.instance.batch();

    for (final listDoc in listRef.docs) {
      final lists = List<String>.from(listDoc.data()['lists']);
      lists.remove(pollId);

      batch.update(listDoc.reference, {'lists': lists});
    }
    await batch.commit();

    return true;
  } catch (error) {
    if (kDebugMode) {
      print('Error deleting poll from list on Firestore: $error');
    }
    return false;
  }
}
