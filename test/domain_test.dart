import 'package:unittest/unittest.dart';

import 'package:dddsample/domain.dart';
import 'package:dddsample/application/service.dart';

import 'unittest/cargo_test.dart' as cargo_test;
import 'unittest/handling_test.dart' as handling_test;
import 'unittest/location_test.dart' as location_test;
import 'unittest/voyage_test.dart' as voygae_test;

main() => run();

run() {
  cargo_test.run();
  handling_test.run();
  location_test.run();
  voygae_test.run();
}