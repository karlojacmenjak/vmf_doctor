import 'dart:collection';
import 'dart:convert';

const structuresKeywords = <String>[
  "versioninfo",
  "visgroups",
  "world",
  "entity",
  "hidden",
  "cameras",
  "cordon"
];

class VMFClass {
  String className = "";
  Map properties = {};

  String get classname {
    return className;
  }

  set classname(String value) {
    className = value;
  }

  void addProperty(String propertyname, dynamic property) {
    properties[propertyname] = property;
  }
}

int bracketPairClosingIndex(String string, int fromIndex,
    [String bracket = '{}']) {
  Queue brackets = Queue();
  int closingPosition = fromIndex;
  for (int i = fromIndex; i < string.length; i++) {
    //stdout.write(string[i]);
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

Map findStructures(String structure) {
  Map keywordIndexes = {};

  for (var keyword in structuresKeywords) {
    int keyLength = keyword.length;
    List<int> indexList = List.empty(growable: true);
    int lastIndex = 0;

    //find the next index after the last index was one
    //stop when indexOf returns -1 (no match is found)
    while ((lastIndex = structure.indexOf(keyword, lastIndex)) > -1) {
      indexList.add(lastIndex);

      lastIndex = indexList.last + keyLength;
    }
    keywordIndexes[keyword] = indexList;
  }
  return keywordIndexes;
}

VMFClass stringToClass(String string) {
  VMFClass newClass = VMFClass();

  for (var className in structuresKeywords) {
    if (string.contains(className)) {
      newClass.classname = className;
      int bracketStart = string.indexOf('{');
      String substring = string.substring(
          bracketStart + 1, bracketPairClosingIndex(string, bracketStart) - 1);
      print(substring);
      substring = substring.replaceAll('\t', '').replaceAll('"', '');
      print(substring);
      List<String> keyValueList = LineSplitter().convert(substring);
      for (var entry in keyValueList) {
        List keyAndValue = entry.split(' ');
        if (keyAndValue.first.length > 0 && keyAndValue.last.length > 0) {
          newClass.addProperty(keyAndValue.first, keyAndValue.last);
        }
      }
    }
  }
  return newClass;
}
