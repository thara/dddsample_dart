import 'package:unittest/unittest.dart';
import 'package:unittest/mock.dart';

import 'package:dddsample/cargo.dart';
import "package:dddsample/handling.dart";
import "package:dddsample/voyage.dart";
import "package:dddsample/location.dart";

import "../sample/sample_location.dart";
import "../sample/sample_voyage.dart";

main() => run();

run() {
  
  group("HandlingEvent", () {
    Cargo cargo;
    
    setUp(() {
      TrackingId trackingId = new TrackingId("XYZ");
      RouteSpecification routeSpec = new RouteSpecification(HONGKONG, NEWYORK, new DateTime.now());
      cargo = new Cargo(trackingId, routeSpec);
    });
    
    test("new with carrier movement", () {
      HandlingEvent e1 = new HandlingEvent(cargo, new DateTime.now(), new DateTime.now(), HandlingEventType.LOAD, HONGKONG, CM003);
      expect(e1.location, equals(HONGKONG));
      
      HandlingEvent e2 = new HandlingEvent(cargo, new DateTime.now(), new DateTime.now(), HandlingEventType.UNLOAD, NEWYORK, CM003);
      expect(e2.location, equals(NEWYORK));
      
      // These event types prohibit a carrier movement association
      for (var type in [HandlingEventType.CLAIM, HandlingEventType.RECEIVE, HandlingEventType.CUSTOMS]) {
        expect(
            () => new HandlingEvent(cargo, new DateTime.now(), new DateTime.now(), type, HONGKONG, CM003),
            throwsA(new isInstanceOf<ArgumentError>()));
      }
      
      // These event types requires a carrier movement association
      for (var type in [HandlingEventType.LOAD, HandlingEventType.UNLOAD]) {
        expect(
            () => new HandlingEvent(cargo, new DateTime.now(), new DateTime.now(), type, HONGKONG, null),
            throwsA(new isInstanceOf<ArgumentError>()));
      }
    });
    
    test("new with location", () {
      HandlingEvent e1 = new HandlingEvent(cargo, new DateTime.now(), new DateTime.now(), HandlingEventType.CLAIM, HELSINKI);
      expect(e1.location, equals(HELSINKI));
    });
    
    test("current location load event", () {
      HandlingEvent ev = new HandlingEvent(cargo, new DateTime.now(), new DateTime.now(), HandlingEventType.LOAD, CHICAGO, CM004);
      expect(ev.location, equals(CHICAGO));
    });
    
    test("current location unload event", () {
      HandlingEvent ev = new HandlingEvent(cargo, new DateTime.now(), new DateTime.now(), HandlingEventType.UNLOAD, HAMBURG, CM004);
      expect(ev.location, equals(HAMBURG));
    });
    
    test("current location received event", () {
      HandlingEvent ev = new HandlingEvent(cargo, new DateTime.now(), new DateTime.now(), HandlingEventType.RECEIVE, CHICAGO);
      expect(ev.location, equals(CHICAGO));
    });
    
    test("current location claimed event", () {
      HandlingEvent ev = new HandlingEvent(cargo, new DateTime.now(), new DateTime.now(), HandlingEventType.CLAIM, CHICAGO);
      expect(ev.location, equals(CHICAGO));
    });
    
    test("equals and samve as", () {
      DateTime timeOccured = new DateTime.now();
      DateTime timeRegistered = new DateTime.now();
      
      HandlingEvent ev1 = new HandlingEvent(cargo, timeOccured, timeRegistered, HandlingEventType.LOAD, CHICAGO, CM005);
      HandlingEvent ev2 = new HandlingEvent(cargo, timeOccured, timeRegistered, HandlingEventType.LOAD, CHICAGO, CM005);
      
      expect(ev1 == ev2, isTrue);
      expect(ev2 == ev1, isTrue);
      
      expect(ev1 == ev1, isTrue);
      
      expect(ev2 == null, isFalse);
      expect(ev2 == new Object(), isFalse);
    });
  });
  
  group("HandlingEventFactory", () {
    
    HandlingEventFactory factory;
    CargoReposSpy cargoRepos;
    VoyageRepository voyageRepos;
    LocationRepository locationRepos;
    TrackingId trackingId;
    Cargo cargo;
    
    setUp(() {
      cargoRepos = new CargoReposSpy();
      voyageRepos = new VoyageReposInMem();
      locationRepos = new LocationRepositoryInMem();
      factory = new HandlingEventFactory(cargoRepos, voyageRepos, locationRepos);
      
      trackingId = new TrackingId("ABC");
      RouteSpecification routeSpec = new RouteSpecification(TOKYO, HELSINKI, new DateTime.now());
      cargo = new Cargo(trackingId, routeSpec);
    });
    
    tearDown(() {
      cargoRepos.calls("find").verify(happenedExactly(1));
    });
    
    test("create handling event with carrier movement", () {
      cargoRepos.when(callsTo("find")).thenReturn(cargo);
      
      var voyageNumber = CM001.voyageNumber;
      var unLocode = STOCKHOLM.unLocode;
      var handlingEvent = factory.createHandlingEvent(
        new DateTime.now(), date(100), trackingId, voyageNumber, unLocode, HandlingEventType.LOAD);
      
      expect(handlingEvent, isNotNull);
      expect(handlingEvent.location, equals(STOCKHOLM));
      expect(handlingEvent.voyage, equals(CM001));
      expect(handlingEvent.cargo, equals(cargo));
      expect(handlingEvent.completionTime, equals(date(100)));
      
      expect(handlingEvent.registrationTime.isBefore(new DateTime.now().add(new Duration(milliseconds:1))), isTrue);
    });
    
    test("create handling event without carrier movement", () {
      cargoRepos.when(callsTo("find")).thenReturn(cargo);
      
      var voyageNumber = CM001.voyageNumber;
      var unLocode = STOCKHOLM.unLocode;
      var handlingEvent = factory.createHandlingEvent(
        new DateTime.now(), date(100), trackingId, null, unLocode, HandlingEventType.CLAIM);
      
      expect(handlingEvent, isNotNull);
      expect(handlingEvent.location, equals(STOCKHOLM));
      expect(handlingEvent.voyage, equals(Voyage.NONE));
      expect(handlingEvent.cargo, equals(cargo));
      expect(handlingEvent.completionTime, equals(date(100)));
      
      expect(handlingEvent.registrationTime.isBefore(new DateTime.now().add(new Duration(milliseconds:1))), isTrue);      
    });
    
    test("create handling event unknown location", () {
      cargoRepos.when(callsTo("find")).thenReturn(cargo);
      
      expect(
        () {
          var invalid = new UnLocode("NOEXT");
          factory.createHandlingEvent(
              new DateTime.now(), date(100), trackingId, CM001.voyageNumber, invalid, HandlingEventType.LOAD);
        },
        throwsA(new isInstanceOf<UnknownLocationException>()));
    });
    
    test("create handling event unknown carrier movement", () {
      cargoRepos.when(callsTo("find")).thenReturn(cargo);
      
      expect(
        () {
          var invalid = new VoyageNumber("XXX");
          factory.createHandlingEvent(
              new DateTime.now(), date(100), trackingId, invalid, STOCKHOLM.unLocode, HandlingEventType.LOAD);
        },
        throwsA(new isInstanceOf<UnknownVoyageException>()));
    });
    
    test("create handling event unknown tracking id", () {
      cargoRepos.when(callsTo("find")).thenReturn(null);
      
      expect(
        () {
          factory.createHandlingEvent(
              new DateTime.now(), date(100), trackingId, CM001.voyageNumber, STOCKHOLM.unLocode, HandlingEventType.LOAD);
        },
        throwsA(new isInstanceOf<UnknownCargoException>()));
    });
  });
  
  group("HandlingHistory", (){
    
    Cargo cargo;
    Voyage voyage;
    HandlingEvent event1;
    HandlingEvent event1duplicate;
    HandlingEvent event2;
    HandlingHistory handlingHistory;
    
    setUp(() {
      cargo = new Cargo(new TrackingId("ABC"), new RouteSpecification(SHANGHAI, DALLAS, new DateTime(2009, 4, 1)));
      voyage = 
          (new VoyageBuilder(new VoyageNumber("X25"), HONGKONG)
            ..addMovement(SHANGHAI, new DateTime.now(), new DateTime.now())
            ..addMovement(DALLAS, new DateTime.now(), new DateTime.now())).build();
      
      event1 = new HandlingEvent(cargo, new DateTime(2009, 3, 5), date(100), HandlingEventType.LOAD, SHANGHAI, voyage);
      event1duplicate = new HandlingEvent(cargo, new DateTime(2009, 3, 5), date(200), HandlingEventType.LOAD, SHANGHAI, voyage);
      event2 = new HandlingEvent(cargo, new DateTime(2009, 3, 10), date(150), HandlingEventType.UNLOAD, DALLAS, voyage);
      
      handlingHistory = new HandlingHistory([event2, event1, event1duplicate]);
    });
    
//    test("distinct events by completion time", (){
//      expect(handlingHistory.distinctEventsByCompletionTime(), equals([event1, event2]));
//    });
//    
//    test("most recently completed event", () {
//      expect(handlingHistory.mostRecentlyCompletedEvent(), equals(event2));
//    });
  });
}

DateTime date(int num) => new DateTime.fromMillisecondsSinceEpoch(num, isUtc:false);

class CargoReposSpy extends Mock implements CargoRepository {
  
}

class VoyageReposInMem implements VoyageRepository {
  
  Voyage find(VoyageNumber voyageNumber) => lookupVoyage(voyageNumber);
}

class LocationRepositoryInMem implements LocationRepository {
  
  Location find(UnLocode unLocode) => lookupLocation(unLocode);
  
  List<Location> findAll() => getAllLocations();
}