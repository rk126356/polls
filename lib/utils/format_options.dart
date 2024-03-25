import '../models/polls_model.dart';

String formatOptions(List<PollOptionModel> options) {
  String formattedOptions = '';
  for (int i = 0; i < options.length; i++) {
    formattedOptions += '${i + 1}: ${options[i].text}';
    if (i < options.length - 1) {
      formattedOptions += ', ';
    }
    formattedOptions += '\n';
  }
  return formattedOptions;
}
