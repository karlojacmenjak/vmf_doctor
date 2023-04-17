import 'package:collection/collection.dart';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

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

  @override
  String toString() {
    String string = '';
    properties.forEach((propertyname, property) {
      string += '"${propertyname.toString()}": ${property.toString()}\n';
    });
    return 'Class: "$className"\n$string';
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
  List<String> structuresKeywords = structureKeywords();

  Map keywordIndexes = {};

  for (var keyword in structuresKeywords) {
    List<int> indexList = substringPositions(structure, keyword);
    keywordIndexes[keyword] = indexList;
  }
  return keywordIndexes;
}

List<int> substringPositions(String structure, String substring) {
  List<int> indexList = List.empty(growable: true);
  int lastIndex = 0;
  int keyLength = substring.length;
  while ((lastIndex =
          structure.indexOf(RegExp("\\b$substring\\b"), lastIndex)) >
      -1) {
    indexList.add(lastIndex);

    lastIndex = indexList.last + keyLength;
  }
  return indexList;
}

List<String> structureKeywords() {
  Map<String, dynamic> structureJson = readStructure();

  var structuresKeywords = <String>[];

  structureJson.forEach((key, value) {
    structuresKeywords.add(key);
  });
  return structuresKeywords;
}

Map<String, dynamic> readStructure() {
  Map<String, dynamic> structureJson = {};
  structureJson = jsonDecode(
      //TODO: MAKE READ FILE FROM CURRENT DIR!
      File("lib/vmf_structure.json").readAsStringSync());
  return structureJson;
}

VMFClass stringToClass(String string) {
  VMFClass newClass = VMFClass();
  List<int> sortIndexList = List.empty(growable: true);

  var fileStructure = readStructure();
  int bracketStart = string.indexOf('{');
  String substring = string.substring(
      bracketStart + 1, bracketPairClosingIndex(string, bracketStart) - 1);

  //find subclasses inside this structure
  fileStructure.forEach((className, subclassList) {
    if (string.contains(RegExp("\\b$className\\b"))) {
      newClass.classname = className;

      for (var subclass in subclassList) {
        List<int> subclassPositions =
            substringPositions(substring, subclass['id']);
        sortIndexList += subclassPositions;
      }
    }
  });

  sortIndexList.sort();
  int? subclassStart = sortIndexList.firstOrNull;

  subclassStart ??= substring.length;
  String valueParameters = substring
      .substring(0, subclassStart)
      .replaceAll('\t', '')
      .replaceAll('"', '');

  List<String> keyValueList = LineSplitter().convert(valueParameters);
  for (var entry in keyValueList) {
    List keyAndValue = entry.split(' ');
    if (keyAndValue.first.length > 0 && keyAndValue.last.length > 0) {
      newClass.addProperty(keyAndValue.first, keyAndValue.last);
    }
  }
  // fileStructure.forEach((key, value) {
  //   print('$key -> $value');
  // });
  // print(
  //     '${substring.length - subclassStart} -> ${substring.substring(subclassStart)}');
  return newClass;
}
