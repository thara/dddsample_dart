part of voyage;

class Voyage implements Entity<Voyage>{
  
  static const Voyage NONE = const Voyage._(const VoyageNumber._(""), Schedule.EMPTY);
  
  final VoyageNumber voyageNumber;
  final Schedule schedule;
  
  const Voyage._(this.voyageNumber, this.schedule);
  
  factory Voyage(VoyageNumber voyageNumber, Schedule schedule) {
    Expect.isNotNull(voyageNumber, "Voyage number is required.");
    Expect.isNotNull(schedule, "Schedule is required.");
    return new Voyage._(voyageNumber, schedule);
  }
  
  bool sameIdentityAs(Voyage other) =>
      other != null && voyageNumber.sameValueAs(other.voyageNumber);
  
  int get hashCode => this.voyageNumber.hashCode;
  
  bool operator==(other) {
    if (identical(this, other)) return true;
    if (other is! Voyage) return false;
    return sameIdentityAs(other as Voyage);
  }
}

class VoyageBuilder {

  final List<CarrierMovement> carrierMovements;
  final VoyageNumber voyageNumber;
  
  Location departureLocation;
  
  VoyageBuilder._(this.voyageNumber, this.departureLocation)
    : this.carrierMovements = [];
  
  factory VoyageBuilder(VoyageNumber voyageNumber, Location departureLocation) {
    Expect.isNotNull(voyageNumber, "Voyage number is required.");
    Expect.isNotNull(departureLocation, "Departure location is required.");
    return new VoyageBuilder._(voyageNumber, departureLocation);
  }
  
  void addMovement(Location arrivalLocation, Date departureTime, Date arrivalTime) {
    carrierMovements.add(new CarrierMovement(this.departureLocation, arrivalLocation, departureTime, arrivalTime));
    // Next departure location is the same sa this arrival locaiton
    this.departureLocation = arrivalLocation;
  }
  
  Voyage build() {
    return new Voyage(voyageNumber, new Schedule(this.carrierMovements));
  }
}

abstract class VoyageRepository {
  Voyage find(VoyageNumber voyageNumber);
}

class VoyageNumber implements ValueObject<VoyageNumber>{
  final String _number;
  const VoyageNumber._(this._number);
  
  factory VoyageNumber(String number) {
    Expect.isNotNull(number, "number is required.");
    return new VoyageNumber._(number);
  }
  
  bool sameValueAs(VoyageNumber other) => other != null && _number == other._number;
  
  int get hashCode => _number.hashCode;
  
  bool operator==(other) {
    if (identical(this, other)) return true;
    if (other is! VoyageNumber) return false;
    return sameValueAs(other as VoyageNumber);
  }
  
  String get idString => _number;
  
  String toString() => _number;
}