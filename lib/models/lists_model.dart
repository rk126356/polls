import 'package:cloud_firestore/cloud_firestore.dart';

class ListsModel {
  final String id;
  final String name;
  final String userId;
  final List<String> lists;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  ListsModel({
    required this.id,
    required this.name,
    required this.userId,
    required this.lists,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ListsModel.fromJson(Map<String, dynamic> json) {
    return ListsModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      userId: json['userId'] ?? '',
      lists: List<String>.from(json['lists'] ?? []),
      createdAt: json['created_at'] ?? Timestamp.now(),
      updatedAt: json['updated_at'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'userId': userId,
      'lists': lists,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
