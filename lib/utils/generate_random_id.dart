import 'dart:math';

import 'package:uuid/uuid.dart';

String generateRandomId(int length) {
  var uuid = const Uuid();
  return Random().nextInt(10).toString() +
      uuid.v4().substring(0, length) +
      Random().nextInt(10).toString();
}
