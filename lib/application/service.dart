library application;

import 'package:logging/logging.dart';

import '../domain.dart';

/**
 * a way to let other parts of the system know about events that have occurred.
 */
abstract class ApplicationEvents {
  
  /** A cargo has been handled. */
  void cargoWasHandled(HandlingEvent event);
  
  /** A [cargo] has been misdirected */
  void cargoWasMisdirected(Cargo cargo);
  
  /** A [cargo] has arrived at its final destination. */
  void cargoHasArrived(Cargo cargo);
  
//  void receivedHandlingEventRegistrationAttempt(HandlingEventRegistrationAttempt attempt);
}

/**
 * Cargo booking service.
 */
class BookingService {
  
  static final Logger _logger = 
      new Logger("dddsample_dart.application.BookingService");
  
  final CargoRepository _cargoRepository;
  final LocationRepository _locationRepository;
  final RoutingService _routingService;
  
  BookingService(this._cargoRepository, this._locationRepository, this._routingService);
  
  /**
   * Registers a new cargo in the tracking system, not yet routed.
   */
  TrackingId bookNewCargo(UnLocode originUnLocode,
                          UnLocode destinationUnLocode, DateTime arrivalDeadline) {
    
    var trackingId = _cargoRepository.nextTrackingId();
    var origin = _locationRepository.find(originUnLocode);
    var destination = _locationRepository.find(destinationUnLocode);
    var routeSpec = new RouteSpecification(origin, destination, arrivalDeadline);
    
    var cargo = new Cargo(trackingId, routeSpec);
    
    _cargoRepository.store(cargo);
    _logger.info("Booked new cargo with tracking id ${cargo.trackingId.idString}");
    
    return cargo.trackingId;
  }
  
  /** 
   * Requests a list of itineraries describing possible routes for this cargo.
   */
  List<Itinerary> requestPossibleRoutesForCargo(TrackingId trackingId) {
    
    var cargo = _cargoRepository.find(trackingId);
    if (cargo == null) return [];
    
    return _routingService.fetchRoutesForSpecification(cargo.routeSpec);
  }
  
  /**
   * Changes the destination of a cargo.
   */
  void assignCargoToRoute(Itinerary itinerary,TrackingId trackingId) {
    
    var cargo = _cargoRepository.find(trackingId);
    if (cargo == null) 
      throw new ArgumentError("Can't assign itinerary to non-existing cargo $trackingId");
    
    cargo.assignToRoute(itinerary);
    _cargoRepository.store(cargo);
    
    _logger.info("Assigned cargo $trackingId to new route");
  }
  
  void changeDestination(TrackingId trackingId, UnLocode unLocode){
    
    var cargo = _cargoRepository.find(trackingId);
    var newDestination = _locationRepository.find(unLocode);
    
    var routeSpec = new RouteSpecification(cargo.origin, newDestination, cargo.routeSpec.arrivalDeadline);
    
    cargo.specifyNewRoute(routeSpec);
    _cargoRepository.store(cargo);
    
    _logger.info("Changed destination for cargo ${routeSpec} to ${routeSpec.destination}");
  }
}

/**
 * Cargo inspection service.
 */
class CargoInspectionService {
  
  static final Logger _logger = 
      new Logger("dddsample_dart.application.CargoInspectionService");
  
  final ApplicationEvents _applicationEvents;
  final CargoRepository _cargoRepository;
  final HandlingEventRepository _handlingEventRepository;
  
  CargoInspectionService(this._applicationEvents, this._cargoRepository, this._handlingEventRepository);
  
  /** Inspect cargo and send relevant notifications to interested parties */
  void inspectCargo(TrackingId trackingId) {
    if (trackingId == null) throw new ArgumentError("Tracking ID is required.");
    
    var cargo = _cargoRepository.find(trackingId);
    if (cargo == null) {
      _logger.warning("Can't inspect non-existing cargo $trackingId");
      return;
    }
    
    var handlingHistory = _handlingEventRepository.lookupHandlingHistoryOfCargo(trackingId);
    cargo.deriveDeliveryProgress(handlingHistory);
    
    if (cargo.delivery.isMisdirected) {
      _applicationEvents.cargoWasMisdirected(cargo);
    }
    
    if (cargo.delivery.isUnloadedAtDestination) {
      _applicationEvents.cargoHasArrived(cargo);
    }
    
    _cargoRepository.store(cargo);
  }
}

/**
 * Handling event service.
 */
class HandlingEventService { 
  
  static final Logger _logger = 
      new Logger("dddsample_dart.application.HandlingEventService");
  
  final HandlingEventRepository _handlingEventRepository;
  final ApplicationEvents _applicationEvents;
  final HandlingEventFactory _handlingEventFactory;
  
  HandlingEventService(
      this._handlingEventRepository, this._applicationEvents, this._handlingEventFactory);
  
  /**
   * Registers a handling event in the system, and notifies interested
   * parties that a cargo has been handled.
   */
  void registerHandlingEvent(DateTime completionTime,
                             TrackingId trackingId,
                             VoyageNumber voyageNumber,
                             UnLocode unLocode,
                             HandlingEventType type) {
    
    var registrationTime = new DateTime.now();
    
    var event = _handlingEventFactory.createHandlingEvent(
      registrationTime, completionTime, trackingId, voyageNumber, unLocode, type
    );
    
    _handlingEventRepository.store(event);
    
    _applicationEvents.cargoWasHandled(event);

    _logger.info("Registered handling event");
  }
}