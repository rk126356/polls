import 'package:cloud_firestore/cloud_firestore.dart';

class PollModel {
  final String id;
  final String question;
  final String? image;
  final String? list;
  String? listId;
  final List<String> tags;
  final List<PollOptionModel> options;
  int totalVotes;
  int views;
  int shares;
  final Timestamp timestamp;
  final String creatorId;
  String creatorUserName;
  String creatorUserImageUrl;
  String creatorName;
  bool isVoted;
  String? option;
  final bool isAskWhy;
  List<String>? searchFields;

  PollModel({
    required this.id,
    this.image,
    required this.question,
    this.list = '',
    this.listId = '',
    required this.tags,
    required this.options,
    this.totalVotes = 0,
    this.views = 0,
    this.shares = 0,
    required this.creatorUserName,
    required this.creatorUserImageUrl,
    required this.creatorId,
    required this.creatorName,
    required this.timestamp,
    this.isVoted = false,
    this.option,
    required this.isAskWhy,
    this.searchFields,
  });

  factory PollModel.fromJson(Map<String, dynamic> json) {
    List<PollOptionModel> options = [];
    if (json['options'] != null) {
      options = json['options']
          .values
          .map<PollOptionModel>((option) => PollOptionModel.fromJson(option))
          .toList();
    }

    return PollModel(
      id: json['id'],
      question: json['question'],
      image: json['image'] ?? '',
      tags: List<String>.from(json['tags']),
      list: json['list'] ?? '',
      listId: json['listId'] ?? '',
      options: options,
      totalVotes: json['totalVotes'] ?? 0,
      creatorUserName: json['creatorUserName'],
      creatorUserImageUrl: json['creatorUserImageUrl'],
      creatorId: json['creatorId'],
      creatorName: json['creatorName'],
      timestamp: json['timestamp'],
      isAskWhy: json['isAskWhy'] ?? false,
      views: json['views'] ?? 0,
      shares: json['shares'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> optionsJson =
        options.map((option) => option.toJson()).toList();

    return {
      'id': id,
      'question': question,
      'image': image,
      'list': list,
      'listId': listId,
      'tags': tags,
      'options': {for (var option in optionsJson) option['id']: option},
      'totalVotes': totalVotes,
      'creatorUserName': creatorUserName,
      'creatorUserImageUrl': creatorUserImageUrl,
      'creatorId': creatorId,
      'creatorName': creatorName,
      'timestamp': timestamp,
      'isAskWhy': isAskWhy,
      'searchFields': searchFields,
      'views': views,
      'shares': shares,
    };
  }
}

class PollOptionModel {
  final String id;
  String text;
  String? imageUrl;
  int votes;

  PollOptionModel({
    required this.id,
    required this.text,
    this.imageUrl,
    this.votes = 0,
  });

  factory PollOptionModel.fromJson(Map<String, dynamic> json) {
    return PollOptionModel(
      id: json['id'],
      text: json['text'],
      imageUrl: json['imageUrl'] ?? '',
      votes: json['votes'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'imageUrl': imageUrl,
      'votes': votes,
    };
  }
}
