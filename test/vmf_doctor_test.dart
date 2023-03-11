import 'package:duplicate_solids/vmf_util.dart';
import 'package:test/test.dart';

void main() {
  test('findDuplicateSolids', () {
    expect(
        bracketPairClosingIndex(
            "there is a { and the result should be the index of this bracket ->}",
            0,
            "{}"),
        67);
  });
  test('indexOfChar', () {
    expect(
        indexOfChar("Find \n after 12 indexes of text so this ->\n", 13, "\n"),
        43);
  });
  test('stringToClass', () {
    const testString = r"""
versioninfo
{
	"editorversion" "400"
	"editorbuild" "8864"
	"mapversion" "10"
	"formatversion" "100"
	"prefab" "0"
}
""";
    print(
      stringToClass(
          testString, 0, bracketPairClosingIndex(testString, 0, "{}")),
    );
  });
  test('returnStringBetweenChars', () {
    expect(removeWrapChars("\"string\""), "string");
  });
}
