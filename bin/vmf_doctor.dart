import 'package:args/args.dart';
import 'package:duplicate_solids/duplicate_solids.dart';

const dSolid = 'dsolid';
const dEntity = 'dentity';
void main(List<String> arguments) {
  final parser = ArgParser();
  parser.addFlag(dSolid, defaultsTo: false);
  parser.addFlag(dEntity, defaultsTo: false);
  ArgResults results = parser.parse(arguments);
  print("""\n\n\n
--------------------------------------------\n
Starting VMF DOCTOR's appointment by KaPPY\n
--------------------------------------------
""");
  if (results[dSolid]) {
    findDuplicateSolids(arguments.last);
  }
  if (results[dEntity]) {}
}
