import 'package:collection/collection.dart';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

class VMFClass {
  String className = "";
  Map properties = {};
  List<VMFClass> subclasses = List.empty(growable: true);

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

int pairClosingIndex(String string, int fromIndex, [String bracket = '{}']) {
  Queue brackets = Queue();
  int closingPosition = fromIndex;
  for (int i = fromIndex; i < string.length; i++) {
    if (string[i] == bracket[0]) {
      brackets.addLast('+');
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

List<int> substringPositions(String structure, Pattern substring) {
  List<int> indexList = List.empty(growable: true);
  int lastIndex = 0;
  while ((lastIndex = structure.indexOf(substring, lastIndex)) > -1) {
    indexList.add(lastIndex);

    lastIndex += 1;
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

  int bracketStart = string.indexOf('{');

  newClass.className = string.substring(0, bracketStart).trim();

  //Serialize file
  String substring = string
      .substring(bracketStart + 1, pairClosingIndex(string, bracketStart) - 1)
      //Replaces whitespaces with ' '
      .replaceAll(RegExp('[^\\S\\r]+'), ' ');

  //print(substring);
  List<int> verticesPlusList = substringPositions(substring, 'vertices_plus {');
  verticesPlusList.sort();

  //Fix vertices_plus to be a property
  int verticesStart = 0;
  do {
    verticesStart = substring.indexOf('vertices_plus {');

    if (verticesStart > -1) {
      int verticesEnd = pairClosingIndex(substring, verticesStart);

      String newVertices = substring.substring(
          substring.indexOf('vertices_plus {'), verticesEnd);
      newVertices = newVertices
          .replaceAll(' "v" ', '')
          .replaceAll('""', ') (')
          .replaceAll('{"', '"(')
          .replaceAll('" }', ')"')
          .replaceAll('vertices_plus', '"vertices_plus"');
      substring = substring.replaceRange(
          substring.indexOf('vertices_plus {'), verticesEnd, newVertices);
    }
  } while (verticesStart > -1);

  //Fix spaces that mess with properties
  substring = substring
      .replaceAll(') (', ')(')
      //Replaces '(-64 -64 320)' with '(-64,-64,320)'
      .replaceAll(RegExp(r'(?<=-?\d) (?=-?\d)'), ',');

  List<int> sortIndexList = List.empty(growable: true);

  //Match anything like 'word {'
  sortIndexList = substringPositions(substring, RegExp(' (?=[a-z]+ {)'));

  sortIndexList.sort();

  int? subclassStart = sortIndexList.firstOrNull;

  subclassStart ??= substring.length;
  String valueParameters =
      substring.substring(0, subclassStart).trim().replaceAll('"', '');

  List<String> keyValueList = valueParameters.split(' ');

  for (int start = 0; start < keyValueList.length; start += 2) {
    if (keyValueList[start].isNotEmpty && keyValueList[start + 1].isNotEmpty) {
      newClass.addProperty(keyValueList[start], keyValueList[start + 1]);
    }
  }

  if (substring.length - subclassStart <= 0) {
    return newClass;
  }

  print(newClass);
  for (var subclass in sortIndexList) {
    VMFClass test = stringToClass(substring.substring(subclass,
        pairClosingIndex(substring, substring.indexOf('{', subclass))));
    print(test);
  }

  return newClass;
}
