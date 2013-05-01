import 'package:unittest/unittest.dart';

import "package:dddsample/dddsample/domain/voyage.dart";
import "package:dddsample/dddsample/domain/location.dart";

import "sample_location.dart";

main() => run();

run() {

  group("CarrierMovement", () {

    test("is not accept null argument", () {

      expect(
        () => new CarrierMovement(null, null, new DateTime.now(), new DateTime.now()),
          throwsA(new isInstanceOf<ArgumentError>()));

      expect(
        () => new CarrierMovement(STOCKHOLM, HAMBURG, new DateTime.now(), new DateTime.now()),
          isNot(throwsA(new isInstanceOf<ArgumentError>())));
    });

    test('is same value as equals hash code', () {

      final Location hamburg = HAMBURG;
      final Location stockholm = STOCKHOLM;

      CarrierMovement cm1 = new CarrierMovement(stockholm, hamburg, new DateTime.now(), new DateTime.now());
      CarrierMovement cm2 = new CarrierMovement(stockholm, hamburg, new DateTime.now(), new DateTime.now());
      CarrierMovement cm3 = new CarrierMovement(hamburg, stockholm, new DateTime.now(), new DateTime.now());
      CarrierMovement cm4 = new CarrierMovement(hamburg, stockholm, new DateTime.now(), new DateTime.now());

      expect(cm1.sameValueAs(cm2), isTrue);
      expect(cm2.sameValueAs(cm3), isFalse);
      expect(cm3.sameValueAs(cm4), isTrue);

      expect(cm1, equals(cm2));
      expect(cm2, isNot(equals(cm3)));
      expect(cm3, equals(cm4));

      expect(cm1.hashCode, equals(cm2.hashCode));
      expect(cm2.hashCode, isNot(equals(cm3.hashCode)));
      expect(cm3.hashCode, equals(cm4.hashCode));
    });

  });
}