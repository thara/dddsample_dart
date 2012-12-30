library service_impl;

import 'service.dart';

import 'package:logging/logging.dart';

import 'package:dddsample_dart/domain/cargo.dart';
import 'package:dddsample_dart/domain/handling.dart';
import 'package:dddsample_dart/domain/location.dart';
import 'package:dddsample_dart/domain/voyage.dart';

import 'package:dddsample_dart/domain/service.dart';

/***/
class BookingServiceImpl implements BookingService {
  
  static final Logger _logger = 
      new Logger("dddsample_dart/application/BookingServiceImpl");
  
  final CargoRepository _cargoRepository;
  final LocationRepository _locationRepository;
  final RoutingService _routingService;
  
  BookingServiceImpl(this._cargoRepository, this._locationRepository, this._routingService);
  
  TrackingId bookNewCargo(UnLocode originUnLocode,
                          UnLocode destinationUnLocode, Date arrivalDeadline) {
    
    var trackingId = _cargoRepository.nextTrackingId();
    var origin = _locationRepository.find(originUnLocode);
    var destination = _locationRepository.find(destinationUnLocode);
    var routeSpec = new RouteSpecification(origin, destination, arrivalDeadline);
    
    var cargo = new Cargo(trackingId, routeSpec);
    
    _cargoRepository.store(cargo);
    _logger.info("Booked new cargo with tracking id ${cargo.trackingId.idString}");
    
    return cargo.trackingId;
  }
  
  List<Itinerary> requestPossibleRoutesForCargo(TrackingId trackingId) {
    
    var cargo = _cargoRepository.find(trackingId);
    if (cargo == null) return [];
    
    return _routingService.fetchRoutesForSpecification(cargo.routeSpec);
  }
  
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

class CargoInspectionServiceImpl implements CargoInspectionService {
  
  static final Logger _logger = 
      new Logger("dddsample_dart/application/CargoInspectionServiceImpl");
  
  final ApplicationEvents _applicationEvents;
  final CargoRepository _cargoRepository;
  final HandlingEventRepository _handlingEventRepository;
  
  CargoInspectionServiceImpl(this._applicationEvents, this._cargoRepository, this._handlingEventRepository);
  
  void inspectCargo(TrackingId trackingId) {
    Expect.isNotNull(trackingId, "Tracking ID is required");
    
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

class HandlingEventServiceImpl implements HandlingEventService {
  
  static final Logger _logger = 
      new Logger("dddsample_dart/application/HandlingEventServiceImpl");
  
  final HandlingEventRepository _handlingEventRepository;
  final ApplicationEvents _applicationEvents;
  final HandlingEventFactory _handlingEventFactory;
  
  HandlingEventServiceImpl(
      this._handlingEventRepository, this._applicationEvents, this._handlingEventFactory);
  
  void registerHandlingEvent(Date completionTime,
                             TrackingId trackingId,
                             VoyageNumber voyageNumber,
                             UnLocode unLocode,
                             HandlingEventType type) {
    
    var registrationTime = new Date.now();
    
    var event = _handlingEventFactory.createHandlingEvent(
      registrationTime, completionTime, trackingId, voyageNumber, unLocode, type
    );
    
    _handlingEventRepository.store(event);
    
    _applicationEvents.cargoWasHandled(event);

    _logger.info("Registered handling event");
  }
}