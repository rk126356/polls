String removeExtraLineBreaks(String input) {
  // Split the input string by line breaks
  List<String> lines = input.split('\n');

  // Remove empty lines and trim leading/trailing spaces from each line
  List<String> filteredLines = lines
      .where((line) => line.trim().isNotEmpty)
      .map((line) => line.trim())
      .toList();

  // Join the filtered lines back together with single line breaks
  String result = filteredLines.join('\n');

  return result;
}
