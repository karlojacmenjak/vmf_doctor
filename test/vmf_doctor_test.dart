import 'package:duplicate_solids/vmf_util.dart';
import 'package:test/test.dart';

const structureTest =
    r"""
versioninfo{}
visgroups{}
world{}
entity{}
hidden{}
cameras{}
cordon{}
versioninfo{}
""";

const classTest =
    r"""
      versioninfo
{
	"editorversion" "400"
	"editorbuild" "8864"
	"mapversion" "10"
	"formatversion" "100"
	"prefab" "0"
  visgroup
      {
            "name" "Tree_1"
            "visgroupid" "5"
            "color" "65 45 0"
      }
}
      """;

void main() {
  test('findStructures', () {
    Map result = findStructures(structureTest);
    expect(result.entries.toString(),
        '(MapEntry(versioninfo: [0, 71]), MapEntry(visgroups: [14]), MapEntry(world: [26]), ..., MapEntry(cameras: [52]), MapEntry(cordon: [62]))');
  });
  test('stringToClass', () {
    VMFClass vmf = stringToClass(classTest);
    expect(vmf.properties.toString(),
        '{editorversion: 400, editorbuild: 8864, mapversion: 10, formatversion: 100, prefab: 0}');
  });
}
