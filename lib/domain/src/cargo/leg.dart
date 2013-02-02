part of cargo;

/**
 * An itinerary consists of one or more legs.
 */
class Leg {

  final Voyage voyage;
  final Location loadLocation;
  final Location unloadLocation;
  final Date loadTime;
  final Date unloadTime;

  Leg._(this.voyage, this.loadLocation, this.unloadLocation,
      this.loadTime, this.unloadTime);
  
  factory Leg(Voyage voyage, Location loadLocation, Location unloadLocation,
      Date loadTime, Date unloadTime) {
    var args = [voyage, loadLocation, unloadLocation, loadTime, unloadTime];
    Expect.isFalse(args.any((elem) => elem == null));
    
    return new Leg._(voyage, loadLocation, unloadLocation, loadTime, unloadTime);
  }
}