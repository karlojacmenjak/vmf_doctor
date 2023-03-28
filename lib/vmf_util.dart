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
    int keyLength = keyword.length;
    List<int> indexList = List.empty(growable: true);
    int lastIndex = 0;

    while ((lastIndex = structure.indexOf(keyword, lastIndex)) > -1) {
      indexList.add(lastIndex);

      lastIndex = indexList.last + keyLength;
    }
    keywordIndexes[keyword] = indexList;
  }
  return keywordIndexes;
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
      File("lib/structure_classes_subclasses.json").readAsStringSync());
  return structureJson;
}

VMFClass stringToClass(String string) {
  VMFClass newClass = VMFClass();

  var fileStructure = readStructure();

  fileStructure.forEach((className, subclassList) {
    if (string.contains(RegExp(r"$className\s+"))) {
      newClass.classname = className;

      int bracketStart = string.indexOf('{');
      String substring = string.substring(
          bracketStart + 1, bracketPairClosingIndex(string, bracketStart) - 1);

      List<int> sortIndexList = List.empty(growable: true);
      for (var subclass in subclassList) {
        var index = -1;
        index = substring.indexOf(subclass);
        if (index > -1) {
          sortIndexList.add(index);
        }
      }
      sortIndexList.sort();
      int subclassStart = sortIndexList.first;
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
    }
  });
  return newClass;
}
