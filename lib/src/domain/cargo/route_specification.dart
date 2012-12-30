part of cargo;

class RouteSpecification extends Specification<Itinerary> implements ValueObject<RouteSpecification> {
  
  final Location origin;
  final Location destination;
  final Date arrivalDeadline;
  
  Proposition<Itinerary> routeSatisfiedBy;
  
  RouteSpecification._(this.origin, this.destination, this.arrivalDeadline) {
    
    routeSatisfiedBy = (Itinerary itinerary) {
      return itinerary != null &&
          origin.sameIdentityAs(itinerary.initialDepartureLocation) &&
          destination.sameIdentityAs(itinerary.finalArrivalLocation) &&
          arrivalDeadline > itinerary.finalArrivalDate;
    };
  }
  
  factory RouteSpecification(Location origin, Location destination, arrivalDeadline) {
    Expect.isNotNull(origin, "Origin is required.");
    Expect.isNotNull(destination, "Destination is required.");
    Expect.isNotNull(arrivalDeadline, "Arrival deadline is required.");
    Expect.isFalse(origin.sameIdentityAs(destination), "Origin and destination can't be the same: $origin");
    
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
