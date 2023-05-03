import 'package:collection/collection.dart';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

class VMFClass {
  String className = "";
  Map properties = {};
  List<VMFClass> subclassList = List.empty(growable: true);

  String get classname {
    return className;
  }

  set classname(String value) {
    className = value;
  }

  set appendSubclass(VMFClass newSubclass) {
    subclassList.add(newSubclass);
  }

  get subclasses {
    return subclassList;
  }

  void addProperty(String propertyname, dynamic property) {
    properties[propertyname] = property;
  }

  void replaceSubclassList(List<VMFClass> newSubclassList) {
    subclassList = newSubclassList;
  }

  @override
  String toString() {
    String string = '';
    properties.forEach((propertyname, property) {
      string += '"${propertyname.toString()}": ${property.toString()}\n';
    });
    string += 'Children: ';
    for (var subclass in subclassList) {
      string += '${subclass.className} ';
    }
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

List<int> substringPositions(String structure, RegExp substring) {
  List<int> indexList = List.empty(growable: true);
  int lastIndex = 0;
  while ((lastIndex = structure.indexOf(substring, lastIndex)) > -1) {
    indexList.add(lastIndex);

    lastIndex += 1;
  }
  return indexList;
}

VMFClass stringToClass(String string) {
  VMFClass newClass = VMFClass();

  int bracketStart = string.indexOf('{');

  newClass.className = string.substring(0, bracketStart).trim();

  //Serialize file
  String substring = string
      .substring(bracketStart + 1, pairClosingIndex(string, bracketStart) - 1)
      //Replaces whitespaces with ' '
      .replaceAll(RegExp(r'\s+|\s'), ' ')
      .trim();

  List<int> verticesPlusList =
      substringPositions(substring, RegExp('vertices_plus {'));
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

  //if the class doesn't have subclasses
  if (substring.length - subclassStart <= 0) return newClass;

  for (var subclass in sortIndexList) {
    VMFClass test = stringToClass(substring.substring(subclass,
        pairClosingIndex(substring, substring.indexOf('{', subclass))));
    newClass.appendSubclass = test;
  }

  return newClass;
}
