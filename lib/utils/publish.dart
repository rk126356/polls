// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/polls_model.dart';

Future<String?> getPostIdFromUrl(PollModel poll, String postUrl) async {
  String username = 'rk126356';
  String password = 'Rahul@786*';
  // Endpoint for retrieving post by slug
  String baseUrl = 'https://poll.raihansk.com/wp-json/wp/v2/posts';
  String getUrl =
      '$baseUrl?slug=${poll.question.toLowerCase().replaceAll(' ', '-').replaceAll(RegExp(r'[^a-z0-9\-]'), '')}-id-${poll.id}';

  // Encode credentials for basic authentication
  String basicAuth =
      'Basic ${base64Encode(utf8.encode('$username:$password'))}';

  try {
    final response = await http.get(
      Uri.parse(getUrl),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': basicAuth,
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      if (data.isNotEmpty) {
        return data.first['id'].toString();
      } else {
        print('Post not found with URL: $postUrl');
        return null;
      }
    } else {
      print('Failed to fetch post ID: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('Error: $e');
    return null;
  }
}

Future<void> publishPost(String title, String content, PollModel poll) async {
  String username = 'rk126356';
  String password = 'Rahul@786*';
  // Set your WordPress website URL
  String baseUrl = 'https://poll.raihansk.com/wp-json/wp/v2';

  // Endpoint for creating a post
  String postEndpoint = '$baseUrl/posts';

  List<int> tags = [];

  for (final tag in poll.tags) {
    try {
      final id = await getTagId(tag.replaceAll('#', ''), username, password);
      tags.add(id);
    } catch (e) {
      print(e);
    }
  }

  // Encode post data
  final postData = {
    'title': title,
    'content': content,
    'status': "publish",
    'tags': tags,
    'category': 1,
    // Add any other fields you want to update
  };

  // Encode credentials for basic authentication
  String basicAuth =
      'Basic ${base64Encode(utf8.encode('$username:$password'))}';

  try {
    final response = await http.post(
      Uri.parse(postEndpoint),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': basicAuth,
      },
      body: jsonEncode(postData),
    );

    if (response.statusCode == 201) {
      print('Post published successfully');
    } else {
      print('Failed to publish post: ${response.statusCode}');
      print(response.body);
    }
  } catch (e) {
    print('Error: $e');
  }
}

Future<void> updatePost(
    String postUrl, String title, String content, PollModel poll) async {
  String? postId = await getPostIdFromUrl(poll, postUrl);

  String username = 'rk126356';
  String password = 'Rahul@786*';
  if (postId != null) {
    // Endpoint for updating a post
    String baseUrl = 'https://poll.raihansk.com/wp-json/wp/v2/posts/$postId';

    // Encode credentials for basic authentication
    String basicAuth =
        'Basic ${base64Encode(utf8.encode('$username:$password'))}';

    List<int> tags = [];

    for (final tag in poll.tags) {
      try {
        final id = await getTagId(tag.replaceAll('#', ''), username, password);
        tags.add(id);
      } catch (e) {
        print(e);
      }
    }

    // Encode post data
    final postData = {
      'title': title,
      'content': content,
      'status': "publish",
      'tags': tags,
      // Add any other fields you want to update
    };

    try {
      final response = await http.put(
        Uri.parse(baseUrl),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': basicAuth,
        },
        body: jsonEncode(postData),
      );

      if (response.statusCode == 200) {
        print('Post updated successfully');
      } else {
        print('Failed to update post: ${response.statusCode}');
        print(response.body);
      }
    } catch (e) {
      print('Error: $e');
    }
  } else {
    publishPost(title, content, poll);
  }
}

Future<void> deletePost(PollModel poll) async {
  String username = 'rk126356';
  String password = 'Rahul@786*';
  // Set your WordPress website URL
  String baseUrl = 'https://poll.raihansk.com/wp-json/wp/v2';

  final postId =
      await getPostIdFromUrl(poll, '${poll.question} - ID: ${poll.id}');

  // Endpoint for deleting a post
  String postEndpoint = '$baseUrl/posts/$postId';

  // Encode credentials for basic authentication
  String basicAuth =
      'Basic ${base64Encode(utf8.encode('$username:$password'))}';

  try {
    final response = await http.delete(
      Uri.parse(postEndpoint),
      headers: <String, String>{
        'Authorization': basicAuth,
      },
    );

    if (response.statusCode == 200) {
      print('Post deleted successfully');
    } else {
      print('Failed to delete post: ${response.statusCode}');
      print(response.body);
    }
  } catch (e) {
    print('Error: $e');
  }
}

String generatePostContent(PollModel poll) {
  String question = poll.question;
  String creatorName = poll.creatorName;
  List<PollOptionModel> options = poll.options;
  int totalVotes = poll.totalVotes;
  DateTime createdAt = poll.timestamp.toDate();
  String questionImageUrl =
      poll.image ?? ''; // If question image is null, use empty string

  // Generate HTML body content
  String content = '''
  <div style="max-width: 800px; margin: 0 auto;">
    <div style="border: 2px solid #007bff; border-radius: 15px; padding: 20px; margin-bottom: 20px; position: relative;">
''';

  // Add question image if available
  if (questionImageUrl.isNotEmpty) {
    content += '''
      <img src="$questionImageUrl" alt="Question Image" style="width: 100%; border-radius: 15px 15px 0 0; margin-bottom: 20px;">
  ''';
  }

  content += '''
      <h1 style="font-size: 24px; font-weight: bold; margin-bottom: 10px;">$question</h1>
      <p style="font-size: 16px; margin-bottom: 10px;"><b>ID:</b> ${poll.id}</p>
      <p style="font-size: 16px; margin-bottom: 10px;"><b>Creator:</b> $creatorName</p>
      <p style="font-size: 16px; margin-bottom: 10px;"><b>Created At:</b> ${formattedDate(createdAt)}</p>
      <p style="font-size: 16px; margin-bottom: 10px;"><b>Total Votes:</b> $totalVotes</p>
      <h2 style="font-size: 20px; font-weight: bold; color: #fff; background: linear-gradient(135deg, #007bff, #00bfff); padding: 8px 12px; border-radius: 5px; margin: 0 auto 10px; text-align: center; max-width: 200px; margin-top: 30px;">
    Options
  </h2>
''';

  // Add options with sleek progress bars
  for (PollOptionModel option in options) {
    double percentage = totalVotes != 0 ? (option.votes / totalVotes) * 100 : 0;
    String progressBarStyle = '''
    background-color: #f5f5f5;
    border-radius: 3px;
    margin-bottom: 5px;
    height: 10px;
    width: 100%;
  ''';
    String progressBarFillStyle = '''
    background-color: #007bff;
    height: 100%;
    width: ${percentage.toStringAsFixed(2)}%;
  ''';
    String optionContent = '''
    <div style="border: 1px solid #ccc; border-radius: 5px; padding: 10px; margin-bottom: 10px; display: flex; align-items: center;">
      <!-- Option Image -->
 ${option.imageUrl != null && option.imageUrl!.isNotEmpty ? '<div style="width: 50px; height: 50px; border-radius: 50%; margin-right: 10px; background-color: transparent; overflow: hidden;"><img src="${option.imageUrl}" alt="${option.text}" style="width: 100%; height: 100%; object-fit: cover;"></div>' : ''}   
      
      <!-- Option Text and Progress Bar -->
      <div style="flex-grow: 1;">
        <p style="font-size: 18px;">${option.text}</p>
        <div style="$progressBarStyle">
          <div style="$progressBarFillStyle"></div>
           <div style="display: flex; justify-content: space-between; width: 100%;  margin-top: 5px;">
          <span style="">${percentage.toStringAsFixed(1)}%</span>
          <span style="">Votes: ${option.votes}</span>
        </div>
        </div>
      </div>
    </div>
  ''';

    content += optionContent;
  }

  // Add Vote Now button with modern styling and open in new tab
  content += '''
  <div style="text-align: center; margin-top: 30px;">
    <a href="https://poll.raihansk.com/id/${poll.id}" target="_blank" rel="noopener noreferrer" style="background-color: #007bff; color: #fff; text-decoration: none; padding: 12px 24px; border-radius: 25px; border: 2px solid #007bff; font-size: 16px; font-weight: bold; cursor: pointer; transition: background-color 0.3s, color 0.3s, border-color 0.3s;">Vote Now</a>
  </div>
''';

  // Close inner box
  content += '''
    </div>
  
  <!-- About section with nice box styling -->
  <div style="border: 2px solid #007bff; border-radius: 15px; padding: 20px; margin-top: 20px;">
    <h3 style="font-size: 24px; font-weight: bold; margin-bottom: 10px;">About PublicPolls</h3>
    <p style="font-size: 16px; margin-bottom: 10px;">PublicPolls is a platform where users can create polls and other users can vote on them. It provides an easy and convenient way to gather opinions and make decisions based on community feedback.</p>
  </div>
</div>
''';

  // Close HTML body content
  content += '';

  return content;
}

String formattedDate(DateTime dateTime) {
  String month = '${dateTime.month}'.padLeft(2, '0');
  String day = '${dateTime.day}'.padLeft(2, '0');
  String year = '${dateTime.year}';
  String hour = '${dateTime.hour}'.padLeft(2, '0');
  String minute = '${dateTime.minute}'.padLeft(2, '0');
  return '$day/$month/$year $hour:$minute';
}

Future<int> getTagId(String tagName, String username, String password) async {
  String baseUrl = 'https://poll.raihansk.com/';
  final response = await http.get(
    Uri.parse('$baseUrl/wp-json/wp/v2/tags?search=$tagName'),
    headers: {
      'Authorization':
          'Basic ${base64Encode(utf8.encode('$username:$password'))}',
    },
  );

  if (response.statusCode == 200) {
    final List<dynamic> tags = jsonDecode(response.body);
    if (tags.isNotEmpty) {
      return tags[0]['id'];
    } else {
      // If tag doesn't exist, add the tag
      final addTagResponse = await http.post(
        Uri.parse('$baseUrl/wp-json/wp/v2/tags'),
        headers: {
          'Authorization':
              'Basic ${base64Encode(utf8.encode('$username:$password'))}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'name': tagName}),
      );

      if (addTagResponse.statusCode == 201) {
        final Map<String, dynamic> newTag = jsonDecode(addTagResponse.body);
        return newTag['id'];
      } else {
        throw Exception('Failed to add tag: ${addTagResponse.statusCode}');
      }
    }
  } else {
    throw Exception('Failed to fetch tags: ${response.statusCode}');
  }
}
