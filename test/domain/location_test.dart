import 'package:unittest/unittest.dart';

import "package:dddsample_dart/domain/location.dart";

main() {

  group('UnLocode', () {

    test('has valid UN/LOCODE', () {
      new UnLocode("AA234");
      new UnLocode("AA29B");
    });

    test("can't have invalid UN/LOCODE", () {
      expect(() => new UnLocode("AAAA"), throwsA(new isInstanceOf<ArgumentError>()));
      expect(() => new UnLocode("AAAAAA"), throwsA(new isInstanceOf<ArgumentError>()));
      expect(() => new UnLocode("22AAA"), throwsA(new isInstanceOf<ArgumentError>()));
      expect(() => new UnLocode("AA111"), throwsA(new isInstanceOf<ArgumentError>()));
      expect(() => new UnLocode(null), throwsA(new isInstanceOf<ArgumentError>()));
    });

    test('has UN/LOCODE of upper case',  () {
      expect(new UnLocode("AbcDe").idString, equals("ABCDE"));
    });

    test('has equality',  () {
      var allCaps = new UnLocode("ABCDE");
      var mixedCase = new UnLocode("aBcDe");

      expect(allCaps, equals(mixedCase));
      expect(mixedCase, equals(allCaps));
      expect(allCaps, equals(allCaps));
      expect(allCaps, isNot(equals(null)));
      expect(allCaps, isNot(equals(new UnLocode("FGHIJ"))));
    });

    test('has hashCode', () {
      var allCaps = new UnLocode("ABCDE");
      var mixedCase = new UnLocode("aBcDe");
      expect(allCaps.hashCode, equals(mixedCase.hashCode));
    });
  });

  group('Location', () {

    test('has equality ', () {
      expect(new Location(new UnLocode("ATEST"), "test-name"),
              equals(new Location(new UnLocode("ATEST"), "test-name")));

      expect(new Location(new UnLocode("ATEST"), "test-name"),
          isNot(equals(new Location(new UnLocode("TESTB"), "test-name"))));

      Location location = new Location(new UnLocode("ATEST"), "test-name");
      expect(location, equals(location));
      expect(location, isNot(equals(null)));

      expect(Location.UNKNOWN, equals(Location.UNKNOWN));
    });

    test("can't have null value", () {
      expect(() => new Location(null, null), throwsA(new isInstanceOf<ArgumentError>()));
    });
  });
}