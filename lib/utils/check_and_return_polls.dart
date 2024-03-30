import 'package:polls/models/polls_model.dart';

import '../controllers/check_if_tasks.dart';
import '../controllers/fetch_user.dart';

Future<List<PollModel>> checkAndReturnPolls(List<PollModel> polls) async {
  List<Future> futures = [];

  final polls0 = polls;

  for (final poll in polls0) {
    futures.add(checkIfVoted(poll));
    futures.add(fetchUser(poll.creatorId));
  }

  List results = await Future.wait(futures);

  for (int i = 0; i < results.length; i += 2) {
    final voted = results[i].isVoted;
    final option = results[i].option;
    final user = results[i + 1];
    final pollIndex = i ~/ 2;

    polls0[pollIndex].isVoted = voted;
    if (option.isNotEmpty) {
      polls0[pollIndex].option = option;
    }
    if (user != null) {
      polls0[pollIndex].creatorName = user.name;
      polls0[pollIndex].creatorUserImageUrl = user.avatarUrl;
      polls0[pollIndex].creatorUserName = user.userName;
    }
  }

  return polls0;
}

Future<PollModel> checkAndReturnPoll(PollModel poll) async {
  List<Future> futures = [];

  futures.add(checkIfVoted(poll));
  futures.add(fetchUser(poll.creatorId));

  List results = await Future.wait(futures);

  for (int i = 0; i < results.length; i += 2) {
    final voted = results[i].isVoted;
    final option = results[i].option;
    final user = results[i + 1];
    poll.isVoted = voted;
    if (option.isNotEmpty) {
      poll.option = option;
    }
    if (user != null) {
      poll.creatorName = user.name;
      poll.creatorUserImageUrl = user.avatarUrl;
      poll.creatorUserName = user.userName;
    }
  }

  return poll;
}

Future<List<PollModel>> checkAndReturnNewPolls(List<PollModel> polls) async {
  final List<PollModel> newPolls = [];
  for (final poll in polls) {
    final isViewed = await checkIfSeen(poll);
    if (!isViewed) {
      newPolls.add(poll);
    }
  }
  return newPolls;
}
