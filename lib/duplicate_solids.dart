import 'dart:io';

import 'package:duplicate_solids/vmf_util.dart';

void duplicateSolids(String contents) {
  Map result = findStructures(contents);
  result.forEach((key, value) {
    print('$key -> $value');
  });
}

void findDuplicateSolids(String arguments) {
  File(arguments).readAsString().then((String contents) {
    int worldIndex = contents.indexOf("world");
    String worldString = contents.substring(
        worldIndex, bracketPairClosingIndex(contents, worldIndex));

    int index = 0;
    List<String> solidList = List.empty(growable: true);
    while (index < worldString.length) {
      index = worldString.indexOf("solid", index);
      if (index == -1) break;
      int newIndex = bracketPairClosingIndex(worldString, index);
      String solidString = worldString.substring(index, newIndex);
      solidList.add(solidString);
      index = newIndex;
    }

    Map solidMap = {};

    for (String solid in solidList) {
      int solidId = solid.indexOf("\"id\"");
      String key = solid
          .substring(solidId, solid.indexOf('\n', solidId))
          .replaceAll('id', '')
          .replaceAll('"', '')
          .replaceAll(' ', '');
      List<int> keyCodes = key.codeUnits;
      String newKey = '';
      for (var element in keyCodes) {
        if (element == 10 || element == 13) continue;
        newKey += String.fromCharCode(element);
      }
      solid = solid.replaceAll(RegExp(r'"id" "\d+"'), '');
      solidMap[int.parse(newKey)] = solid;
    }

    Map duplicatesMap = {};
    Iterable keyIter = solidMap.keys;

    for (final firstKey in keyIter) {
      Set duplicateSet = {};
      for (final secondKey in keyIter) {
        if (firstKey != secondKey &&
            solidMap[firstKey] == solidMap[secondKey]) {
          duplicateSet.add(secondKey);
        }
      }

      bool isDuplicate = false;
      duplicatesMap.forEach((key, value) {
        if (value.contains(firstKey)) {
          isDuplicate = true;
        }
      });
      if (!isDuplicate && duplicateSet.isNotEmpty) {
        duplicatesMap[firstKey] = duplicateSet;
      }
    }

    duplicatesMap.forEach((key, value) {
      print("[Warning] Duplicates of solid with ID $key:");
      for (var element in value) {
        print("$element");
      }
    });
    if (duplicatesMap.isEmpty) {
      print("There are no duplicate solids!");
    }
  });
}
