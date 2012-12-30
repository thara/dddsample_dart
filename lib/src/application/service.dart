library application;

import 'package:dddsample_dart/src/domain/cargo.dart';
import 'package:dddsample_dart/src/domain/handling.dart';
import 'package:dddsample_dart/src/domain/location.dart';
import 'package:dddsample_dart/src/domain/voyage.dart';

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
abstract class BookingService {
  
  /**
   * Registers a new cargo in the tracking system, not yet routed.
   */
  TrackingId bookNewCargo(UnLocode origin, UnLocode destination, Date arrivalDeadline);
  
  /** 
   * Requests a list of itineraries describing possible routes for this cargo.
   */
  List<Itinerary> requestPossibleRoutesForCargo(TrackingId trackingId);
  
  void assignCargoToRoute(Itinerary itinerary, TrackingId trackingId);
  
  /**
   * Changes the destination of a cargo.
   */
  void changeDestination(TrackingId trackingId, UnLocode unLocode);
}

/**
 * Cargo inspection service.
 */
abstract class CargoInspectionService {
  /** Inspect cargo and send relevant notifications to interested parties */
  void inspectCargo(TrackingId trackingId);
}

/**
 * Handling event service.
 */
abstract class HandlingEventService { 
  /**
   * Registers a handling event in the system, and notifies interested
   * parties that a cargo has been handled.
   */
  void registerHandlingEvent(Date completionTime,
                             TrackingId trackingId,
                             VoyageNumber voyageNumber,
                             UnLocode unLocode,
                             HandlingEventType type);
}