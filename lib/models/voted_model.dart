class VotedModel {
  final bool isVoted;
  String? pollId;
  String? option;
  String? userId;

  VotedModel({
    required this.isVoted,
    this.pollId = '',
    this.option = '',
    this.userId = '',
  });
}
