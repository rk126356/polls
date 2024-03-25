import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String userId;
  String name;
  String? bio;
  String? email;
  String? mobileNumber;
  String avatarUrl;
  String userName;
  int? noOfFollowers;
  int? noOfFollowings;
  int? noOfPolls;
  Timestamp? votedTimestamp;
  String? option;
  String? why;
  // Other user-related fields

  UserModel({
    required this.userId,
    required this.name,
    this.bio,
    this.email,
    this.mobileNumber,
    required this.avatarUrl,
    required this.userName,
    this.noOfFollowers,
    this.noOfFollowings,
    this.noOfPolls,
    this.votedTimestamp,
    this.option,
    this.why,
    // Add other user-related parameters
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['uid'],
      name: json['name'],
      bio: json['bio'],
      email: json['email'],
      mobileNumber: json['mobileNumber'],
      avatarUrl: json['avatarUrl'],
      userName: json['userName'],
      noOfFollowers: json['noOfFollowers'] ?? 0,
      noOfFollowings: json['noOfFollowings'] ?? 0,
      noOfPolls: json['noOfPolls'] ?? 0,
      // Map other JSON keys to corresponding attributes
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'bio': bio,
      'email': email,
      'mobileNumber': mobileNumber,
      'avatarUrl': avatarUrl,
      'userName': userName,
      'noOfFollowers': noOfFollowers,
      'noOfFollowings': noOfFollowings,
      'noOfPolls': noOfPolls,
      // Add other attributes as needed
    };
  }
}
