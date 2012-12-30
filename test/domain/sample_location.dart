library sample_location;

import "package:dddsample_dart/domain/location.dart";

final Location HONGKONG = new Location(new UnLocode("CNHKG"), "Hongkong");
final Location MELBOURNE = new Location(new UnLocode("AUMEL"), "Melbourne");
final Location STOCKHOLM = new Location(new UnLocode("SESTO"), "Stockholm");
final Location HELSINKI = new Location(new UnLocode("FIHEL"), "Helsinki");
final Location CHICAGO = new Location(new UnLocode("USCHI"), "Chicago");
final Location TOKYO = new Location(new UnLocode("JNTKO"), "Tokyo");
final Location HAMBURG = new Location(new UnLocode("DEHAM"), "Hamburg");
final Location SHANGHAI = new Location(new UnLocode("CNSHA"), "Shanghai");
final Location ROTTERDAM = new Location(new UnLocode("NLRTM"), "Rotterdam");
final Location GOTHENBURG = new Location(new UnLocode("SEGIT"), "Gotebirg");
final Location HANGZOU = new Location(new UnLocode("CNHGH"), "Hangzhou");
final Location NEWYORK = new Location(new UnLocode("USNYC"), "New York");
final Location DALLAS = new Location(new UnLocode("USDAL"), "Dallas");

final _ALL = new Map<UnLocode, Location>();

_setupAll() {
  if (_ALL.isEmpty) {
    _putToAll([HONGKONG, MELBOURNE, STOCKHOLM, HELSINKI, CHICAGO, TOKYO,
               HAMBURG, SHANGHAI, ROTTERDAM, GOTHENBURG, HANGZOU, NEWYORK, DALLAS]);
  }
}

List<Location> getAllLocations() {
  _setupAll();
  return _ALL.values;
}

Location lookupLocation(UnLocode unLocode) {
  _setupAll();
  return _ALL[unLocode];
}

_putToAll(List<Location> locations) {
  for (var location in locations) {
    _ALL[location.unLocode] = location;
  }
}