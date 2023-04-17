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
world
{
	"id" "1"
	"mapversion" "11"
	"classname" "worldspawn"
	"detailmaterial" "detail/detailsprites_2fort"
	"detailvbsp" "detail_2fort.vbsp"
	"maxpropscreenwidth" "-1"
	"skyname" "sky_tf2_04"
	solid
	{
		"id" "41"
		side
		{
			"id" "138"
			"plane" "(-64 -64 320) (128 -64 320) (128 -256 320)"
			vertices_plus
			{
				"v" "-64 -64 320"
				"v" "128 -64 320"
				"v" "128 -256 320"
				"v" "-64 -256 320"
			}
			"material" "DEV/REFLECTIVITY_40"
			"uaxis" "[1 0 0 0] 0.25"
			"vaxis" "[0 -1 0 0] 0.25"
			"rotation" "0"
			"lightmapscale" "16"
			"smoothing_groups" "0"
		}
		side
		{
			"id" "137"
			"plane" "(-64 -256 256) (128 -256 256) (128 -64 256)"
			vertices_plus
			{
				"v" "-64 -256 256"
				"v" "128 -256 256"
				"v" "128 -64 256"
				"v" "-64 -64 256"
			}
			"material" "DEV/REFLECTIVITY_40"
			"uaxis" "[1 0 0 0] 0.25"
			"vaxis" "[0 -1 0 0] 0.25"
			"rotation" "0"
			"lightmapscale" "16"
			"smoothing_groups" "0"
		}
		side
		{
			"id" "136"
			"plane" "(-64 -64 320) (-64 -256 320) (-64 -256 256)"
			vertices_plus
			{
				"v" "-64 -64 320"
				"v" "-64 -256 320"
				"v" "-64 -256 256"
				"v" "-64 -64 256"
			}
			"material" "DEV/REFLECTIVITY_40"
			"uaxis" "[0 1 0 0] 0.25"
			"vaxis" "[0 0 -1 0] 0.25"
			"rotation" "0"
			"lightmapscale" "16"
			"smoothing_groups" "0"
		}
		side
		{
			"id" "135"
			"plane" "(128 -64 256) (128 -256 256) (128 -256 320)"
			vertices_plus
			{
				"v" "128 -64 256"
				"v" "128 -256 256"
				"v" "128 -256 320"
				"v" "128 -64 320"
			}
			"material" "DEV/REFLECTIVITY_40"
			"uaxis" "[0 1 0 0] 0.25"
			"vaxis" "[0 0 -1 0] 0.25"
			"rotation" "0"
			"lightmapscale" "16"
			"smoothing_groups" "0"
		}
		side
		{
			"id" "134"
			"plane" "(128 -64 320) (-64 -64 320) (-64 -64 256)"
			vertices_plus
			{
				"v" "128 -64 320"
				"v" "-64 -64 320"
				"v" "-64 -64 256"
				"v" "128 -64 256"
			}
			"material" "DEV/REFLECTIVITY_40"
			"uaxis" "[1 0 0 0] 0.25"
			"vaxis" "[0 0 -1 0] 0.25"
			"rotation" "0"
			"lightmapscale" "16"
			"smoothing_groups" "0"
		}
		side
		{
			"id" "133"
			"plane" "(128 -256 256) (-64 -256 256) (-64 -256 320)"
			vertices_plus
			{
				"v" "128 -256 256"
				"v" "-64 -256 256"
				"v" "-64 -256 320"
				"v" "128 -256 320"
			}
			"material" "DEV/REFLECTIVITY_40"
			"uaxis" "[1 0 0 0] 0.25"
			"vaxis" "[0 0 -1 0] 0.25"
			"rotation" "0"
			"lightmapscale" "16"
			"smoothing_groups" "0"
		}
		editor
		{
			"color" "0 143 136"
			"visgroupshown" "1"
			"visgroupautoshown" "1"
		}
	}
}
      """;

void main() {
  test('findStructures', () {
    Map result = findStructures(structureTest);
    expect(result.entries.toString(),
        '(MapEntry(versioninfo: [0, 71]), MapEntry(visgroups: [14]), MapEntry(viewsettings: []), ..., MapEntry(cameras: [52]), MapEntry(cordons: []))');
  });

  test('substringPositions', () {
    expect(substringPositions(classTest, "vertices_plus"),
        [301, 665, 1029, 1393, 1755, 2118]);
  });
  test('stringToClass', () {
    VMFClass vmf = stringToClass(classTest);
    expect(vmf.className, 'world');
    expect(vmf.toString(),
        """
Class: "world"
"id": 1
"mapversion": 11
"classname": worldspawn
"detailmaterial": detail/detailsprites_2fort
"detailvbsp": detail_2fort.vbsp
"maxpropscreenwidth": -1
"skyname": sky_tf2_04
""");
    vmf = stringToClass(
        """viewsettings
{
	"bSnapToGrid" "1"
	"bShowGrid" "1"
	"bShowLogicalGrid" "0"
	"nGridSpacing" "64"
}""");
    expect(vmf.toString(),
        """
Class: "viewsettings"
"bSnapToGrid": 1
"bShowGrid": 1
"bShowLogicalGrid": 0
"nGridSpacing": 64
""");
  });
}
