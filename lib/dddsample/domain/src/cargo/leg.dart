part of domain.cargo;

/**
 * An itinerary consists of one or more legs.
 */
class Leg {

  final Voyage voyage;
  final Location loadLocation;
  final Location unloadLocation;
  final DateTime loadTime;
  final DateTime unloadTime;

  Leg._(this.voyage, this.loadLocation, this.unloadLocation,
      this.loadTime, this.unloadTime);
  
  factory Leg(Voyage voyage, Location loadLocation, Location unloadLocation,
      DateTime loadTime, DateTime unloadTime) {
    var args = [voyage, loadLocation, unloadLocation, loadTime, unloadTime];
    if (args.contains(null)) throw new ArgumentError("");
    
    return new Leg._(voyage, loadLocation, unloadLocation, loadTime, unloadTime);
  }
}