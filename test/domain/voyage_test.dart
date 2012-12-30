import 'package:unittest/unittest.dart';

import "package:dddsample_dart/src/domain/voyage.dart";
import "package:dddsample_dart/src/domain/location.dart";

import "sample_location.dart";

main () {

  group("CarrierMovement", () {

    test("is not accept null argument", () {

      expect(
        () => new CarrierMovement(null, null, new Date.now(), new Date.now()),
          throwsA(new isInstanceOf<ExpectException>()));

      expect(
        () => new CarrierMovement(STOCKHOLM, HAMBURG, new Date.now(), new Date.now()),
          isNot(throwsA(new isInstanceOf<ExpectException>())));
    });

    test('is same value as equals hash code', () {

      final Location hamburg = HAMBURG;
      final Location stockholm = STOCKHOLM;

      CarrierMovement cm1 = new CarrierMovement(stockholm, hamburg, new Date.now(), new Date.now());
      CarrierMovement cm2 = new CarrierMovement(stockholm, hamburg, new Date.now(), new Date.now());
      CarrierMovement cm3 = new CarrierMovement(hamburg, stockholm, new Date.now(), new Date.now());
      CarrierMovement cm4 = new CarrierMovement(hamburg, stockholm, new Date.now(), new Date.now());

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