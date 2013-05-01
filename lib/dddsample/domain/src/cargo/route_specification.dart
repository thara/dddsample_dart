part of domain.cargo;

class RouteSpecification extends Specification<Itinerary> implements ValueObject<RouteSpecification> {
  
  final Location origin;
  final Location destination;
  final DateTime arrivalDeadline;
  
  Proposition<Itinerary> routeSatisfiedBy;
  
  RouteSpecification._(this.origin, this.destination, this.arrivalDeadline) {
    
    
    routeSatisfiedBy = (Itinerary itinerary) {
      return itinerary != null &&
          origin.sameIdentityAs(itinerary.initialDepartureLocation) &&
          destination.sameIdentityAs(itinerary.finalArrivalLocation) &&
          arrivalDeadline.isAfter(itinerary.finalArrivalDate);
    };
  }
  
  factory RouteSpecification(Location origin, Location destination, DateTime arrivalDeadline) {
    
    if (origin == null) throw new ArgumentError("Origin is required.");
    if (destination == null) throw new ArgumentError("Destination is required.");
    if (arrivalDeadline == null) throw new ArgumentError("Arrival deadline is required.");
    if (origin.sameIdentityAs(destination)) throw new ArgumentError("Origin and destination can't be the same: $origin");
    
    return new RouteSpecification._(origin, destination, arrivalDeadline);
  }
  
  bool isSatisfiedBy(Itinerary itinerary) {
    return routeSatisfiedBy(itinerary);
  }
  
  bool sameValueAs(RouteSpecification other) =>
      other != null &&
        this.origin == other.origin &&
          this.destination == other.destination &&
            this.arrivalDeadline == other.arrivalDeadline;
  
  bool operator==(other) {
    if (identical(this, other)) return true;
    if (other is! RouteSpecification) return false;
    return sameValueAs(other as RouteSpecification);
  }
}
