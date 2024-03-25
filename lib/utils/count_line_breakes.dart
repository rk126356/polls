int countLineBreaks(String text) {
  // Count the occurrences of line break characters (\n)
  int count = RegExp(r'\n').allMatches(text).length;
  return count;
}
