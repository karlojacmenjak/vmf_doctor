import 'dart:collection';

List classTypes = [
  "versioninfo",
  "visgroups",
  "world",
  "entity",
  "hidden",
  "cameras",
  "cordon"
];

class VMFClass {
  late String classname;
  late Map properties;

  void addProperty(String propertyname, dynamic property) {
    properties[propertyname] = property;
  }
}

String removeWrapChars(String string, [String chars = "\"\""]) {
  if (chars.length < 2) throw (ArgumentError("'chars' is needs 2 characters!"));
  int firstIndex = string.indexOf(chars[0]) + 1;
  String returnString = '';
  for (var i = firstIndex; i < string.length; i++) {
    if (string[i] != chars[1]) {
      returnString += string[i];
    }
  }
  return returnString;
}

int indexOfChar(String string, int start, String character) {
  while (string[start++] != character) {}

  return start;
}

int bracketPairClosingIndex(String string, int fromIndex,
    [String bracket = '{}']) {
  Queue brackets = Queue();
  int closingPosition = fromIndex;
  for (int i = fromIndex; i < string.length; i++) {
    if (string[i] == bracket[0]) {
      brackets.addLast(string[i]);
    }
    if (string[i] == bracket[1]) {
      brackets.removeLast();
      if (brackets.isEmpty) {
        closingPosition = i + 1;
        break;
      }
    }
  }
  return closingPosition;
}

VMFClass stringToClass(String string, int startIndex, int endIndex) {
  for (var className in classTypes) {
    if (string.contains(className)) {
      print("String has $className");

      VMFClass newClass = VMFClass();
      newClass.classname = className;
      int bracketStart = string.indexOf('{');
      int bracketEnd = bracketPairClosingIndex(string, bracketStart);
    }
  }
  return VMFClass();
}
