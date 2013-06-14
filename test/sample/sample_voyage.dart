library sample_dart;

import 'package:dddsample/cargo.dart';
import "package:dddsample/voyage.dart";
import "package:dddsample/location.dart";

import "sample_location.dart";

final Voyage CM001 = createVoayge("CM001", STOCKHOLM, HAMBURG);
final Voyage CM002 = createVoayge("CM002", HAMBURG, HONGKONG);
final Voyage CM003 = createVoayge("CM003", HONGKONG, NEWYORK);
final Voyage CM004 = createVoayge("CM003", NEWYORK, CHICAGO);
final Voyage CM005 = createVoayge("CM003", CHICAGO, HAMBURG);

Voyage createVoayge(String id, Location from, Location to) {
  return new Voyage(new VoyageNumber(id), new Schedule([
    new CarrierMovement(from, to, new DateTime.now(), new DateTime.now())
  ]));
}

final _ALL = new Map<VoyageNumber, Voyage>();

Voyage lookupVoyage(VoyageNumber voyageNumber) {
  if (_ALL.isEmpty) {
    _putToAll([CM001, CM002, CM003, CM004, CM005]);
  }
  return _ALL[voyageNumber];  
}

_putToAll(List<Voyage> voyages) {
  for (var voyage in voyages) {
    _ALL[voyage.voyageNumber] = voyage;
  }
}