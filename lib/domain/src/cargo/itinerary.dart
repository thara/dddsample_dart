part of cargo;

/**
 * An itinerary.
 */
class Itinerary implements ValueObject<Itinerary> {

  static final Itinerary EMPTY = new Itinerary();
  
  //TODO Why is this private field?
//  static final Date END_OF_DAYS = new Date.fromMillisecondsSinceEpoch(Date._MAX_MILLISECONDS_SINCE_EPOCH, isUtc:false);
  static final Date END_OF_DAYS = new Date.fromMillisecondsSinceEpoch(8640000000000000, isUtc:false);
  
  final List<Leg> _legs;
  
  Itinerary() : this._([]);
  
  Itinerary._(this._legs);
  
  factory Itinerary.withLegs(List<Leg> legs) {
    if (legs.some((elem) => elem == null)) 
      throw new ArgumentError("legs must not be contains null elements.");
    
    return new Itinerary._(new List.from(legs));
  }
  
  bool isExpected(HandlingEvent event) {
    if (_legs.isEmpty) return true;
    
    var types = new Map<HandlingEventType, Function>();
    
    types[HandlingEventType.RECEIVE] = () {
      // Check that ther first leg's origin is the event's location
      return _legs.first.loadLocation == event.location;
    };
    
    types[HandlingEventType.LOAD] = () {
      // Check that the there is one leg with same load location and voyage
      return _legs.some((leg) {
        return leg.loadLocation.sameIdentityAs(event.location) && leg.voyage.sameIdentityAs(event.voyage);
      });
    };
    
    types[HandlingEventType.UNLOAD] = () {
      // Check that the there is one leg with same unload location and voyage
      return _legs.some((leg) {
        return leg.unloadLocation.sameIdentityAs(event.location) && leg.voyage.sameIdentityAs(event.voyage);
      });
    };
    
    types[HandlingEventType.CLAIM] = () {
      return _legs.last.unloadLocation == event.location;
    };
    
    if (types.containsKey(event.type)) {
      return types[event.type]();
    } else {
      // HandlingEventType.CUSTOMS
      return true;
    }
  }
  
  Location get initialDepartureLocation => 
    _legs.isEmpty ? Location.UNKNOWN : _legs.first.loadLocation;

  Location get finalArrivalLocation => 
    _legs.isEmpty ? Location.UNKNOWN : _legs.last.unloadLocation;
  
  Date get finalArrivalDate =>
    _legs.isEmpty ? END_OF_DAYS : _legs.last.unloadTime;
  
  List<Leg> get legs => new List.from(_legs);
  
  bool sameValueAs(Itinerary other) => 
      other != null && _legs == other._legs;
  
  int get hashCode => _legs.hashCode;
  
  bool operator==(other) {
    if (identical(this, other)) return true;
    if (other is! Itinerary) return false;
    return sameValueAs(other as Itinerary);
  }
}