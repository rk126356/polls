import 'package:polls/utils/format_options.dart';
import 'package:share_plus/share_plus.dart';

import '../models/polls_model.dart';

void sharePoll(PollModel poll) {
  final options = formatOptions(poll.options);
  Share.share(
      'poll: \n${poll.question}\n\n'
      'options: \n$options\n\n'
      'id: ${poll.id}\n\n'
      'vote: https://poll.raihansk.com/id/${poll.id}',
      subject: 'check out this awesome poll and share your opinion now!');
}
