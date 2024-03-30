import '../models/polls_model.dart';

String formatOptions(List<PollOptionModel> options) {
  String formattedOptions = '';
  int totalVotes =
      options.map((option) => option.votes).reduce((a, b) => a + b);
  for (int i = 0; i < options.length; i++) {
    double percentage =
        totalVotes != 0 ? (options[i].votes / totalVotes) * 100 : 0;
    formattedOptions +=
        '${i + 1}: ${options[i].text} (${percentage.toStringAsFixed(2)}%)';
    if (i < options.length - 1) {
      formattedOptions += ', ';
    }
    formattedOptions += '\n';
  }
  return formattedOptions;
}
