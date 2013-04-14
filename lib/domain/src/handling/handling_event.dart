part of handling;

class HandlingEvent implements DomainEvent<HandlingEvent> {
  
  final Cargo cargo;
  final DateTime completionTime;
  final DateTime registrationTime;
  final HandlingEventType type;
  final Location location;
  final Voyage voyage;
  
  HandlingEvent._(this.cargo, this.completionTime, this.registrationTime,
      this.type, this.location, this.voyage);
  
  factory HandlingEvent(Cargo cargo, DateTime completionTime, DateTime registrationTime,
      HandlingEventType type, Location location, [Voyage voyage = Voyage.NONE]) {
    
    if (cargo == null) throw new ArgumentError("Cargo is required.");
    if (completionTime == null) throw new ArgumentError("Completion time is required.");
    if (registrationTime == null) throw new ArgumentError("Registration time is required.");
    if (type == null) throw new ArgumentError("Handling Event type is required.");
    if (location == null) throw new ArgumentError("Location is required.");
    
    if (?voyage) {
      if (voyage == null) throw new ArgumentError("Voyage is required");
      if (type.prohibitsVoyage) throw new ArgumentError("Voyage is not allowed with event type $type");
    } else {
      if (type.requiresVoyage) throw new ArgumentError("Voyage is required for event type $type");
    }
    
    return new HandlingEvent._(cargo, completionTime, registrationTime, type, location, voyage);
  }
  
  bool sameEventAs(HandlingEvent other) =>
    other != null && 
    cargo == other.cargo &&
    voyage == other.voyage &&
    completionTime == other.completionTime &&
    location == other.location &&
    type == other.type;
  
  int get hashCode {
    const int constant = 37;
    return
      [cargo, completionTime, registrationTime, type, location, voyage]
        .fold(17, (total, elem) => elem == null ? total : total * constant + elem.hashCode);
  }
  
  bool operator==(other) {
    if (identical(this, other)) return true;
    if (other is! HandlingEvent) return false;
    return sameEventAs(other as HandlingEvent);
  }
  
  String toString() {
    
    String text = """
--- Handling event ---
Cargo: ${cargo.trackingId}
Type: ${type}
Location: ${location.name}
Completed on: ${completionTime}
Registered on: ${registrationTime}
    """;
    
    var sb = new StringBuffer(text);
    if (voyage != Voyage.NONE) {
      sb.write("Voyage: ${voyage.voyageNumber}");
    }
    return sb.toString();
  }
}

class HandlingEventType implements ValueObject<HandlingEventType> {
  
  static const LOAD = const HandlingEventType._(0, true, "LOAD");
  static const UNLOAD = const HandlingEventType._(1, true, "UNLOAD");
  static const RECEIVE = const HandlingEventType._(2, false, "RECEIVE");
  static const CLAIM = const HandlingEventType._(3, false, "CLAIM");
  static const CUSTOMS = const HandlingEventType._(4, false, "CUSTOMS");
  
  final num _value;
  final bool requiresVoyage;
  final String name;
  
  const HandlingEventType._(this._value, this.requiresVoyage, this.name);
  
  bool get prohibitsVoyage => !requiresVoyage;
  
  bool sameValueAs(HandlingEventType other) {
    return _value == other._value;
  }
  
  bool operator==(other) {
    if (identical(this, other)) return true;
    if (other is! HandlingEventType) return false;
    return sameValueAs(other as HandlingEventType);
  }
  
  String toString() => name;
}

class HandlingEventFactory {
  
  final CargoRepository _cargoRepos;
  final VoyageRepository _voyageRepos;
  final LocationRepository _locationRepos;
  
  HandlingEventFactory(this._cargoRepos, this._voyageRepos, this._locationRepos);
  
  HandlingEvent createHandlingEvent(
    DateTime registrationTime, DateTime completionTime,
    TrackingId trackingId, VoyageNumber voyageNumber,
    UnLocode unLocode, HandlingEventType type) {
    
    var cargo = _findCargo(trackingId);
    var voyage = _findVoyage(voyageNumber);
    var location = _findLocation(unLocode);
    
    try {
      if (voyage == null) {
        return new HandlingEvent(cargo, completionTime, registrationTime, type, location);
      } else {
        return new HandlingEvent(cargo, completionTime, registrationTime, type, location, voyage);
      }
    } on Exception catch(e) {
      throw new CannotCreateHandlingEventException(e);      
    }
  }

  Cargo _findCargo(TrackingId trackingId) {
    var cargo = _cargoRepos.find(trackingId);
    if (cargo == null) throw new UnknownCargoException(trackingId);
    return cargo;
  }
  
  Voyage _findVoyage(VoyageNumber voyageNumber) {
    if (voyageNumber == null) return null;
    
    var voyage = _voyageRepos.find(voyageNumber);
    if (voyage == null) throw new UnknownVoyageException(voyageNumber);
    return voyage;
  }
  
  Location _findLocation(UnLocode unLocode) {
    var location = _locationRepos.find(unLocode);
    if (location == null) throw new UnknownLocationException(unLocode);
    return location;
  }
}

abstract class HandlingEventRepository {
  
  void store(HandlingEvent event);
                  
  HandlingHistory lookupHandlingHistoryOfCargo(TrackingId trackingId);  
}