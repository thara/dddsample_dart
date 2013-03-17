part of voyage;

class CarrierMovement implements ValueObject<CarrierMovement> {

  final Location departureLocation;
  final Location arrivalLocation;
  final DateTime departureTime;
  final DateTime arrivalTime;

  CarrierMovement._(this.departureLocation, this.arrivalLocation, this.departureTime, this.arrivalTime);
  
  factory CarrierMovement(Location departureLocation, Location arrivalLocation, DateTime departureTime, DateTime arrivalTime) {
    
    if (departureLocation == null) throw new ArgumentError("Departure location must not be null.");
    if (arrivalLocation == null) throw new ArgumentError("Arrival location must not be null.");
    if (departureTime == null) throw new ArgumentError("Departure time must not be null.");
    if (arrivalTime == null) throw new ArgumentError("Arrival time must not be null.");
    
    return new CarrierMovement._(departureLocation, arrivalLocation, departureTime, arrivalTime);
  }

  bool sameValueAs(CarrierMovement other) =>
      other != null &&
      this.departureLocation == other.departureLocation &&
        this.arrivalLocation == other.arrivalLocation &&
          this.departureTime == other.departureTime &&
            this.arrivalTime == other.arrivalTime;

  int get hashCode {
    const int constant = 37;
    return
      [this.departureLocation, this.arrivalLocation, this.departureTime, this.arrivalTime]
        .reduce(17, (total, elem) => total * constant + elem.hashCode);
  }

  bool operator==(other) {
    if (identical(this, other)) return true;
    if (other is! CarrierMovement) return false;
    return sameValueAs(other as CarrierMovement);
  }
}
