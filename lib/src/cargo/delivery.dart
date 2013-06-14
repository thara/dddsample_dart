part of domain.cargo;

class Delivery implements ValueObject<Delivery>{

  final HandlingEvent lastEvent;
  final DateTime calculatedAt;
  
  TransportStatus transportStatus;
  Location _lastKnownLocation;
  Voyage _currentVoyage;
  bool _misdirected;
  DateTime eta;
  HandlingActivity nextExpectedActivity;
  bool isUnloadedAtDestination;
  RoutingStatus routingStatus;
  
  static const DateTime ETA_UNKNOWN = null;
  static const HandlingActivity NO_ACTIVITY = null;
  
  Delivery._(this.lastEvent, Itinerary itinerary, RouteSpecification routeSpec) 
      : this.calculatedAt = new DateTime.now(){
    
    this._misdirected = _calculateMisdirectionStatus(itinerary);
    this.routingStatus = _calculateRoutingStatus(itinerary, routeSpec);
    this.transportStatus = _calculateTransportStatus();
    this._lastKnownLocation = lastEvent != null ? lastEvent.location : null;
    this._currentVoyage = _calculateCurrentVoyage();
    this.eta = _calculateEta(itinerary);
    this.nextExpectedActivity = _calculateNextExpectedActivity(routeSpec, itinerary);
    this.isUnloadedAtDestination = _calculateUnloadedAtDestination(routeSpec);
  }
  
  factory Delivery.derivedFrom(RouteSpecification routeSpec, Itinerary itinerary, HandlingHistory handlingHistory) {
    if (routeSpec == null) throw new ArgumentError("Route Specification is required.");
    if (handlingHistory == null) throw new ArgumentError("Delivary history is required.");
    
    var lastEvent = handlingHistory.mostRecentlyCompletedEvent();
    return new Delivery._(lastEvent, itinerary, routeSpec);
  }
  
  Location get lastKnownLocation => 
      _lastKnownLocation == null ? Location.UNKNOWN : _lastKnownLocation;
  
  Voyage get currentVoyage => _currentVoyage == null ? Voyage.NONE : _currentVoyage;
  
  bool get isMisdirected => _misdirected;
  
  bool _onTrack() => routingStatus == RoutingStatus.ROUTED && !_misdirected;
  
  bool sameValueAs(Delivery other) {
    return false;
  }
  
  DateTime estimatedTimeOfArrival() => eta != ETA_UNKNOWN ? eta : ETA_UNKNOWN;
  
  bool _calculateMisdirectionStatus(Itinerary itinerary) 
    => lastEvent == null ? false : !itinerary.isExpected(lastEvent);
  
  RoutingStatus _calculateRoutingStatus(
    Itinerary itinerary, RouteSpecification routeSpec) {
    
    if (itinerary == null) return RoutingStatus.NOT_ROUTED;
    
    return routeSpec.isSatisfiedBy(itinerary) 
        ? RoutingStatus.ROUTED : RoutingStatus.MISROUTED;
  }
  
  TransportStatus _calculateTransportStatus() {
    if (lastEvent == null) return TransportStatus.NOT_RECEIVED;
    
    var eventTypes = new Map<HandlingEventType, TransportStatus>();
    eventTypes[HandlingEventType.LOAD] = TransportStatus.ONBOARD_CARRIER;
    eventTypes[HandlingEventType.UNLOAD] = TransportStatus.IN_PORT;
    eventTypes[HandlingEventType.RECEIVE] = TransportStatus.IN_PORT;
    eventTypes[HandlingEventType.CUSTOMS] = TransportStatus.IN_PORT;
    eventTypes[HandlingEventType.CLAIM] = TransportStatus.CLAIMED;
    
    if (eventTypes.containsKey(lastEvent.type)) {
      return eventTypes[lastEvent.type];
    }
    
    return TransportStatus.UNKNOWN;
  }
  
  Voyage _calculateCurrentVoyage() {
    if (this.transportStatus == TransportStatus.ONBOARD_CARRIER && lastEvent != null) {
      return lastEvent.voyage;
    } else {
      return null;
    }
  }
    
  DateTime _calculateEta(Itinerary itinerary) =>
    _onTrack() ? itinerary.finalArrivalDate : ETA_UNKNOWN;
  
  HandlingActivity _calculateNextExpectedActivity(RouteSpecification routeSpec, Itinerary itinerary) {
    
    if (!_onTrack()) return NO_ACTIVITY;
    
    if (lastEvent == null)
      return new HandlingActivity(HandlingEventType.RECEIVE, routeSpec.origin);
    
    var eventTypes = new Map<HandlingEventType, Function>();
    
    eventTypes[HandlingEventType.LOAD] = () {
      for (var leg in itinerary.legs) {
        if (leg.loadLocation.sameIdentityAs(lastEvent.location)) {
          return new HandlingActivity(HandlingEventType.UNLOAD, leg.unloadLocation, leg.voyage);
        }
      }
      return NO_ACTIVITY;
    };
    
    eventTypes[HandlingEventType.UNLOAD] = () {
      for (var iter = itinerary.legs.iterator; iter.moveNext(); ) {
        Leg leg = iter.current;
        if (leg.unloadLocation.sameIdentityAs(lastEvent.location)) {
          Leg nextLeg = iter.current;
          return new HandlingActivity(HandlingEventType.LOAD, nextLeg.loadLocation, nextLeg.voyage);
        } else {
          return new HandlingActivity(HandlingEventType.CLAIM, leg.unloadLocation);
        }
      }
      return NO_ACTIVITY;
    };
    
    eventTypes[HandlingEventType.RECEIVE] = () {
      Leg firstLeg = itinerary.legs.first;
      return new HandlingActivity(HandlingEventType.LOAD, firstLeg.loadLocation, firstLeg.voyage);
    };
    
    return eventTypes.containsKey(lastEvent.type) ? NO_ACTIVITY : eventTypes[lastEvent.type]();
  }
  
  bool _calculateUnloadedAtDestination(RouteSpecification routeSpec) {
    return lastEvent != null &&
      HandlingEventType.UNLOAD.sameValueAs(lastEvent.type) &&
      routeSpec.destination.sameIdentityAs(lastEvent.location);
  }

  /**
   * 
   */
  Delivery updateOnRouting(RouteSpecification routeSpec, Itinerary itinerary) {
    if (routeSpec == null) throw new ArgumentError("Route Specification is required.");
   
    return new Delivery._(this.lastEvent, itinerary, routeSpec);
  }
}

