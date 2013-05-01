import 'package:unittest/unittest.dart';

import 'package:dddsample/dddsample/domain.dart';
import 'package:dddsample/dddsample/application.dart';

import 'domain/cargo_test.dart' as cargo_test;
import 'domain/handling_test.dart' as handling_test;
import 'domain/location_test.dart' as location_test;
import 'domain/voyage_test.dart' as voygae_test;

main() => run();

run() {
  cargo_test.run();
  handling_test.run();
  location_test.run();
  voygae_test.run();
}