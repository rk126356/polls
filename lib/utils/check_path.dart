String checkImageType(String filePath) {
  // Split the filePath using '/'
  List<String> parts = filePath.split('/');
  // Get the last part which should be the filename
  String fileName = parts.last;
  // Check if the filename contains "right" or "wrong"
  if (fileName.contains("right")) {
    return "right";
  } else if (fileName.contains("wrong")) {
    return "wrong";
  } else {
    return "unknown"; // If neither "right" nor "wrong" is found
  }
}
