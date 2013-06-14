part of tracking;

final DateFormat _dateFormat = new DateFormat("yyyy-MM-dd HH:mm");

class CargoTrackingController {
  
  final CargoRepository _cargoRepos;
  final HandlingEventRepository _handlingEventRepos;
  
  CargoTrackingController(this._cargoRepos, this._handlingEventRepos);
  
  /**
   * Pass a cargo has [command] to [onSuccess].
   */
  void findCargo(TrackCommand command,
              onSuccess(CargoTrackingViewAdapter adaptor),
              onError(TrackingId trackingId)) {
    
    var trackingId = new TrackingId(command.trackingId);
    var cargo = _cargoRepos.find(trackingId);
    
    if (cargo != null) {
      var handlingEvents = 
          _handlingEventRepos
            .lookupHandlingHistoryOfCargo(trackingId)
              .distinctEventsByCompletionTime();
      var view = new CargoTrackingViewAdapter(cargo, handlingEvents);
      onSuccess(view);
    } else {
      onError(trackingId);
    }
  }
}

class CargoTrackingViewAdapter {
  final Cargo cargo;

  List<HandlingEventViewAdapter> _events;

  CargoTrackingViewAdapter(this.cargo, List<HandlingEvent> handlingEvents) {
    _events = handlingEvents.map(_createAdapter).toList();
  }
  
  String _getDisplayText(Location location) => location.name;
  
  List<HandlingEventViewAdapter> get events => new List.from(_events);
  
  String get statusText {
    var delivery = cargo.delivery;
    
    switch(delivery.transportStatus) {
      case TransportStatus.NOT_RECEIVED :
        return "Not received";
      case TransportStatus.IN_PORT :
        return "In port ${_getDisplayText(delivery.lastKnownLocation)}";
      case TransportStatus.ONBOARD_CARRIER :
        return "Onboard voyage ${delivery.currentVoyage.voyageNumber.idString}";
      case TransportStatus.CLAIMED :
        return "Claimed";
      case TransportStatus.UNKNOWN :
        return "Unknown";
    }
    
    return "[Unknown status]";
  }
  
  String get destination => _getDisplayText(cargo.routeSpec.destination);
  
  String get origin => _getDisplayText(cargo.routeSpec.origin);
  
  String get trackingId => cargo.trackingId.idString;
  
  String get eta {
    var eta = cargo.delivery.estimatedTimeOfArrival();
    if (eta == null) return "?";
    return _dateFormat.format(eta);
  }
  
  String get nextExpectedActivity {
    var activity = cargo.delivery.nextExpectedActivity;
    if (activity == null) return "";
    
    String text = "Next expected activity is to ";
    
    var type = activity.type;
    
    if (type.sameValueAs(HandlingEventType.LOAD)) {
      return "$text ${type.name.toLowerCase()} cargo"
              " onto voyage ${activity.voyage.voyageNumber}"
              " in ${activity.location.name}";
    } else if (type.sameValueAs(HandlingEventType.UNLOAD)) {
      return "$text ${type.name.toLowerCase()} cargo"
              " off of ${activity.voyage.voyageNumber}"
              " in ${activity.location.name}";      
    } else {
      return "$text ${type.name.toLowerCase()} cargo"
              " in ${activity.location.name}";
    }
  }
  
  bool get isMisdirected => cargo.delivery.isMisdirected;
  
  HandlingEventViewAdapter _createAdapter(HandlingEvent event) =>
      new HandlingEventViewAdapter(event, this);
}


class HandlingEventViewAdapter {
  final HandlingEvent handlingEvent;
  final Cargo _cargo;
  HandlingEventViewAdapter(this.handlingEvent, CargoTrackingViewAdapter parent) 
    : this._cargo = parent.cargo;
  
  String get location => handlingEvent.location.name;
  
  String get time => _dateFormat.format(handlingEvent.completionTime);
  
  String get type => handlingEvent.type.toString();
  
  String get voyageNumber => handlingEvent.voyage.voyageNumber.idString;
  
  bool get isExpected => _cargo.itinerary.isExpected(handlingEvent);
  
  String get description {
    var he = handlingEvent;
    var type = he.type;
    
    if (type == HandlingEventType.LOAD) {
      return "Loaded onto voyage ${he.voyage.voyageNumber.idString}"
              " in ${he.location.name}, at ${he.completionTime}";
    }
    
    if (type == HandlingEventType.UNLOAD) {
      return "Unloaded off voyage ${he.voyage.voyageNumber.idString}"
              " in ${he.location.name}, at ${he.completionTime}";
    }
    
    if (type == HandlingEventType.RECEIVE) {
      return "Received in ${he.location.name},"
              " at ${he.completionTime}";
    }
    
    if (type == HandlingEventType.CLAIM) {
      return "Claimed in ${he.location.name},"
              " at ${he.completionTime}";
    }
    
    return "Cleared customes in ${he.location.name},"
            " at ${he.completionTime}";
  }
}