import 'package:unittest/unittest.dart';
import 'package:unittest/mock.dart';

import 'application_test.dart' as application_test;
import 'domain_test.dart' as domain_test;
import 'interfaces_test.dart' as interfaces_test;

main() {
  application_test.run();
  domain_test.run();
  interfaces_test.run();
}