List<String> parseSearchTerms(String input) {
  List<String> terms = [];
  for (int i = 0; i < input.length; i++) {
    for (int j = i + 1; j <= input.length; j++) {
      terms.add(input.substring(i, j).toLowerCase());
    }
  }

  return terms;
}
