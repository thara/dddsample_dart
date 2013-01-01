import 'package:unittest/unittest.dart';
import 'package:unittest/mock.dart';

import 'package:dddsample_dart/domain/cargo.dart';
import 'package:dddsample_dart/domain/location.dart';
import 'package:dddsample_dart/domain/handling.dart';
import 'package:dddsample_dart/domain/voyage.dart';
import 'package:dddsample_dart/domain/service.dart';

import 'package:dddsample_dart/application/service.dart';

import './domain/sample_location.dart';
import './domain/sample_voyage.dart';

main() {
  
  group('Booking Service', () {
    
    BookingService bookingService;
    CargoReposMock cargoRepos;
    LocationReposMock locationRepos;
    RoutingServiceMock routingService;
    
    setUp(() {
      cargoRepos = new CargoReposMock();
      locationRepos = new LocationReposMock();
      routingService = new RoutingServiceMock();
      
      bookingService = new BookingService(cargoRepos, locationRepos, routingService);
    });
    
    tearDown(() {
      cargoRepos.calls("nextTrackingId").verify(happenedExactly(1));
      locationRepos.calls("find").verify(happenedExactly(2));
    });
    
    test('register new', () {
      TrackingId expectedTrackingId = new TrackingId('TRK1');
      UnLocode fromUnlocode = new UnLocode('USCHI');
      UnLocode toUnlocode = new UnLocode('SESTO');
      
      cargoRepos.when(callsTo("nextTrackingId")).thenReturn(expectedTrackingId);
      cargoRepos.when(callsTo("store")).thenReturn(null);
      
      locationRepos.when(callsTo("find", fromUnlocode)).thenReturn(CHICAGO);
      locationRepos.when(callsTo("find", toUnlocode)).thenReturn(STOCKHOLM);
      
      var trackingId = bookingService.bookNewCargo(fromUnlocode, toUnlocode, new Date.now());
      expect(trackingId, equals(expectedTrackingId));
    });
  });
  
  group("Handling Event Service", () {
    
    HandlingEventService service;
    
    CargoReposMock cargoRepos;
    VoyageReposMock voyageRepos;
    HandlingEventReposMock handlingEventRepos;
    LocationReposMock locationRepos;
    AppEventsMock appEvents;
    
    final Cargo cargo = 
        new Cargo(new TrackingId("ABC"), new RouteSpecification(HAMBURG, TOKYO, new Date.now()));
    
    setUp(() {
      cargoRepos = new CargoReposMock();
      voyageRepos = new VoyageReposMock();
      handlingEventRepos = new HandlingEventReposMock();
      locationRepos = new LocationReposMock();
      appEvents = new AppEventsMock();
      
      HandlingEventFactory hef = new HandlingEventFactory(cargoRepos, voyageRepos, locationRepos);
      service = new HandlingEventService(handlingEventRepos, appEvents, hef);
    });
    
    tearDown(() {
      cargoRepos.calls("find").verify(happenedExactly(1));
      voyageRepos.calls("find").verify(happenedExactly(1));
      locationRepos.calls("find").verify(happenedExactly(1));
      handlingEventRepos.calls("store").verify(happenedExactly(1));
      appEvents.calls("cargoWasHandled").verify(happenedExactly(1));
    });
    
      //TODO What does this test?
    test('register event', () {
      cargoRepos.
        when(callsTo("find", cargo.trackingId)).thenReturn(cargo);
      voyageRepos.
        when(callsTo("find", CM001.voyageNumber)).thenReturn(CM001);
      locationRepos.
        when(callsTo("find", STOCKHOLM.unLocode)).thenReturn(STOCKHOLM);
      
      handlingEventRepos.when(callsTo("store")).thenReturn(null);
      appEvents.when(callsTo("cargoWasHandled")).thenReturn(null);
      
      service.registerHandlingEvent(new Date.now(),
                                    cargo.trackingId,
                                    CM001.voyageNumber,
                                    STOCKHOLM.unLocode,
                                    HandlingEventType.LOAD);
    });
  });
}

class CargoReposMock extends Mock implements CargoRepository {}

class LocationReposMock extends Mock implements LocationRepository {}

class VoyageReposMock extends Mock implements VoyageRepository {}

class HandlingEventReposMock extends Mock implements HandlingEventRepository {}

class RoutingServiceMock extends Mock implements RoutingService {}

class AppEventsMock extends Mock implements ApplicationEvents {}