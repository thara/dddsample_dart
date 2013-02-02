import 'package:unittest/unittest.dart';

import 'package:dddsample_dart/domain/cargo.dart';
import "package:dddsample_dart/domain/handling.dart";
import "package:dddsample_dart/domain/voyage.dart";
import "package:dddsample_dart/domain/location.dart";

import "sample_location.dart";

main () {
  
  group("TrackingId", () {
    test("not accept null constructor arguments", () {
      expect(
          () => new TrackingId(null),
          throwsA(new isInstanceOf<ExpectException>()));
    });
  });

  group("Leg", () {
    test("not accept null constructor arguments", () {
      expect(
        () => new Leg(null, null, null, null, null),
        throwsA(new isInstanceOf<ExpectException>()));
    });
  });
  
  group("Route Specification", () {
    
    final Voyage hongKongTokyoNewYork = 
        (new VoyageBuilder(new VoyageNumber("V0001"), HONGKONG)
          ..addMovement(TOKYO, new Date(2009, 2, 1), new Date(2009, 2, 5))
          ..addMovement(NEWYORK, new Date(2009, 2, 6), new Date(2009, 2, 10))
          ..addMovement(HONGKONG, new Date(2009, 2, 11), new Date(2009, 2, 14))).build();

    final Voyage dellasNewYorkChicago = 
        (new VoyageBuilder(new VoyageNumber("V0002"), DALLAS)
          ..addMovement(NEWYORK, new Date(2009, 2, 6), new Date(2009, 2, 7))
          ..addMovement(CHICAGO, new Date(2009, 2, 12), new Date(2009, 2, 20))).build();
    
    //TODO:
    // it shouldn't be possible to create Legs that have load/unload locations
    // and/or dates that don't match the voyage's carrier movements.
    final Itinerary itinerary = new Itinerary.withLegs([
      new Leg(hongKongTokyoNewYork, HONGKONG, NEWYORK, new Date(2009, 2, 1), new Date(2009, 2, 10)),
      new Leg(dellasNewYorkChicago, NEWYORK, CHICAGO, new Date(2009, 2, 12), new Date(2009, 2, 20))
    ]);
    
    test("is satisfied by success", () {
      RouteSpecification routeSpec = new RouteSpecification(HONGKONG, CHICAGO, new Date(2009, 3, 1));
      expect(routeSpec.isSatisfiedBy(itinerary), isTrue);
    });
    
    test("is satisfied by wrong oring", () {
      RouteSpecification routeSpec = new RouteSpecification(HANGZOU, CHICAGO, new Date(2009, 3, 1));
      expect(routeSpec.isSatisfiedBy(itinerary), isFalse);
    });

    test("is satisfied by wrong destination", () {
      RouteSpecification routeSpec = new RouteSpecification(HONGKONG, DALLAS, new Date(2009, 3, 1));
      expect(routeSpec.isSatisfiedBy(itinerary), isFalse);
    });

    test("is satisfied by missed deadline", () {
      RouteSpecification routeSpec = new RouteSpecification(HONGKONG, CHICAGO, new Date(2009, 2, 15));
      expect(routeSpec.isSatisfiedBy(itinerary), isFalse);
    });

  });
  
  group("Itinerary", () {
    
    Voyage voyage, wrongVoyage;
    
    setUp(() {
      voyage = 
          (new VoyageBuilder(new VoyageNumber("0123"), SHANGHAI)
            ..addMovement(ROTTERDAM, new Date.now(), new Date.now())
            ..addMovement(GOTHENBURG, new Date.now(), new Date.now())).build();
      wrongVoyage = 
          (new VoyageBuilder(new VoyageNumber("666"), NEWYORK)
            ..addMovement(STOCKHOLM, new Date.now(), new Date.now())
            ..addMovement(HELSINKI, new Date.now(), new Date.now())).build();
    });
    
    test("Cargo on Track", () {
      
      var trackingId = new TrackingId("CARG01");
      RouteSpecification routeSpec = new RouteSpecification(SHANGHAI, GOTHENBURG, new Date.now());
      Cargo cargo = new Cargo(trackingId, routeSpec);
      
      Itinerary itinerary = new Itinerary.withLegs([
        new Leg(voyage, SHANGHAI, ROTTERDAM, new Date.now(), new Date.now()),
        new Leg(voyage, ROTTERDAM, GOTHENBURG, new Date.now(), new Date.now())
      ]);
      
      // Happy path
      HandlingEvent event = new HandlingEvent(cargo, new Date.now(), new Date.now(), HandlingEventType.RECEIVE, SHANGHAI);
      expect(itinerary.isExpected(event), isTrue);
      
      event = new HandlingEvent(cargo, new Date.now(), new Date.now(), HandlingEventType.LOAD, SHANGHAI, voyage);
      expect(itinerary.isExpected(event), isTrue);
      
      event = new HandlingEvent(cargo, new Date.now(), new Date.now(), HandlingEventType.UNLOAD, ROTTERDAM, voyage);
      expect(itinerary.isExpected(event), isTrue);
      
      event = new HandlingEvent(cargo, new Date.now(), new Date.now(), HandlingEventType.LOAD, ROTTERDAM, voyage);
      expect(itinerary.isExpected(event), isTrue);
      
      event = new HandlingEvent(cargo, new Date.now(), new Date.now(), HandlingEventType.UNLOAD, GOTHENBURG, voyage);
      expect(itinerary.isExpected(event), isTrue);
      
      event = new HandlingEvent(cargo, new Date.now(), new Date.now(), HandlingEventType.CLAIM, GOTHENBURG);
      expect(itinerary.isExpected(event), isTrue);
      
      // Customs event changes nothing
      event = new HandlingEvent(cargo, new Date.now(), new Date.now(), HandlingEventType.CUSTOMS, GOTHENBURG);
      expect(itinerary.isExpected(event), isTrue);

      // Received at the wrong location
      event = new HandlingEvent(cargo, new Date.now(), new Date.now(), HandlingEventType.RECEIVE, HANGZOU);
      expect(itinerary.isExpected(event), isFalse);
      
      // Loaded to onto the wroing ship, correct location
      event = new HandlingEvent(cargo, new Date.now(), new Date.now(), HandlingEventType.LOAD, ROTTERDAM, wrongVoyage);
      expect(itinerary.isExpected(event), isFalse);
      
      // Unloaded from the wrong ship in the wrong location
      event = new HandlingEvent(cargo, new Date.now(), new Date.now(), HandlingEventType.UNLOAD, HELSINKI, wrongVoyage);
      expect(itinerary.isExpected(event), isFalse);
      
      event = new HandlingEvent(cargo, new Date.now(), new Date.now(), HandlingEventType.CLAIM, ROTTERDAM);
      expect(itinerary.isExpected(event), isFalse);
    });
  });
  
  group("Cargo", () {
    
    List<HandlingEvent> events;
    Voyage voyage;
    
    setUp(() {
      events = <HandlingEvent>[];
      voyage = 
          (new VoyageBuilder(new VoyageNumber("0123"), STOCKHOLM)
            ..addMovement(HAMBURG, new Date.now(), new Date.now())
            ..addMovement(HONGKONG, new Date.now(), new Date.now())
            ..addMovement(MELBOURNE, new Date.now(), new Date.now())).build();
    });
    
    test("is valid construction", () {
      TrackingId trackingId = new TrackingId("XYZ");
      Date arrivalDeadline = new Date(2009, 3, 13);
      RouteSpecification routeSpec = 
        new RouteSpecification(STOCKHOLM, MELBOURNE, arrivalDeadline);
      
      Cargo cargo = new Cargo(trackingId, routeSpec);
      
      expect(cargo.delivery.routingStatus, equals(RoutingStatus.NOT_ROUTED));
      expect(cargo.delivery.transportStatus, equals(TransportStatus.NOT_RECEIVED));
      expect(cargo.delivery.lastKnownLocation, equals(Location.UNKNOWN));
      expect(cargo.delivery.currentVoyage, equals(Voyage.NONE));
    });
    
    test("routing status", () {
      Cargo cargo = new Cargo(new TrackingId("XYZ"),
                      new RouteSpecification(STOCKHOLM, MELBOURNE, new Date.now()));
      
      Itinerary good = new Itinerary();
      Itinerary bad = new Itinerary();
      RouteSpecification acceptOnlyGood = new RouteSpecification(cargo.origin, cargo.routeSpec.destination, new Date.now());
      //TODO hmmmmmm
      acceptOnlyGood.routeSatisfiedBy = (itinerary) => identical(itinerary, good);
      
      cargo.specifyNewRoute(acceptOnlyGood);
      expect(cargo.delivery.routingStatus, equals(RoutingStatus.NOT_ROUTED));
      
      cargo.assignToRoute(bad);
      expect(cargo.delivery.routingStatus, equals(RoutingStatus.MISROUTED));
      
      cargo.assignToRoute(good);
      expect(cargo.delivery.routingStatus, equals(RoutingStatus.ROUTED));
    });
    
    test("last known location unknown when no events", () {
      Cargo cargo = new Cargo(new TrackingId("XYZ"), 
                      new RouteSpecification(STOCKHOLM, MELBOURNE, new Date.now()));
      expect(cargo.delivery.lastKnownLocation, equals(Location.UNKNOWN));
    });
    
    test("last known location received", () {
      Cargo cargo = new Cargo(new TrackingId("XYZ"), new RouteSpecification(STOCKHOLM, MELBOURNE, new Date.now()));
      
      HandlingEvent he = new HandlingEvent(
          cargo, new Date(2007, 12, 1), new Date.now(),
          HandlingEventType.RECEIVE, STOCKHOLM);
      
      var events = [he];
      cargo.deriveDeliveryProgress(new HandlingHistory(events));
      
      expect(cargo.delivery.lastKnownLocation, equals(STOCKHOLM));
    });
    
    test("last known locatipon clainmed", (){
      Cargo cargo = createCargo(STOCKHOLM, MELBOURNE);
      
      events.add(createEvent(cargo, new Date(2007, 12, 1), HandlingEventType.LOAD, STOCKHOLM, voyage));
      events.add(createEvent(cargo, new Date(2007, 12, 2), HandlingEventType.UNLOAD, HAMBURG, voyage));
      
      events.add(createEvent(cargo, new Date(2007, 12, 3), HandlingEventType.LOAD, HAMBURG, voyage));
      events.add(createEvent(cargo, new Date(2007, 12, 4), HandlingEventType.LOAD, HONGKONG, voyage));

      events.add(createEvent(cargo, new Date(2007, 12, 5), HandlingEventType.LOAD, HONGKONG, voyage));
      events.add(createEvent(cargo, new Date(2007, 12, 6), HandlingEventType.LOAD, MELBOURNE, voyage));
      
      cargo.deriveDeliveryProgress(new HandlingHistory(events));
      
      events.add(createEvent(cargo, new Date(2007, 12, 9), HandlingEventType.CLAIM, MELBOURNE));
      
      cargo.deriveDeliveryProgress(new HandlingHistory(events));
      
      expect(cargo.delivery.lastKnownLocation, equals(MELBOURNE));
    });
    
    test("last known locatipon unloaded", (){
      Cargo cargo = createCargo(STOCKHOLM, MELBOURNE);
      
      events.add(createEvent(cargo, new Date(2007, 12, 1), HandlingEventType.LOAD, STOCKHOLM, voyage));
      events.add(createEvent(cargo, new Date(2007, 12, 2), HandlingEventType.UNLOAD, HAMBURG, voyage));
      events.add(createEvent(cargo, new Date(2007, 12, 3), HandlingEventType.LOAD, HAMBURG, voyage));
      events.add(createEvent(cargo, new Date(2007, 12, 4), HandlingEventType.UNLOAD, HONGKONG, voyage));
      
      cargo.deriveDeliveryProgress(new HandlingHistory(events));
      
      expect(cargo.delivery.lastKnownLocation, equals(HONGKONG));
    });
    
    test("last known location loaded", () {
      Cargo cargo = createCargo(STOCKHOLM, MELBOURNE);
      
      events.add(createEvent(cargo, new Date(2007, 12, 1), HandlingEventType.LOAD, STOCKHOLM, voyage));
      events.add(createEvent(cargo, new Date(2007, 12, 2), HandlingEventType.UNLOAD, HAMBURG, voyage));
      events.add(createEvent(cargo, new Date(2007, 12, 3), HandlingEventType.LOAD, HAMBURG, voyage));
      
      cargo.deriveDeliveryProgress(new HandlingHistory(events));
      
      expect(cargo.delivery.lastKnownLocation, equals(HAMBURG));
    });

    test("equality", () {
      RouteSpecification spec1 = new RouteSpecification(STOCKHOLM, HONGKONG, new Date.now());
      RouteSpecification spec2 = new RouteSpecification(STOCKHOLM, MELBOURNE, new Date.now());
      
      Cargo c1 = new Cargo(new TrackingId("ABC"), spec1);
      Cargo c2 = new Cargo(new TrackingId("CBA"), spec1);
      Cargo c3 = new Cargo(new TrackingId("ABC"), spec2);
      Cargo c4 = new Cargo(new TrackingId("ABC"), spec1);
      
      expect(c1, equals(c4), reason : "Cargos should be equal when TrackingIDs are equal");
      expect(c1, equals(c3), reason : "Cargos should be equal when TrackingIDs are equal");
      expect(c3, equals(c4), reason : "Cargos should be equal when TrackingIDs are equal");
      expect(c1, isNot(equals(c2)), reason : "Cargos are not equal when TrackingID differ");
    });
    
    test("is unloaded at final destination", () {
      
      Cargo cargo = setupCargoWithItinerary(voyage, HANGZOU, TOKYO, NEWYORK);
      expect(cargo.delivery.isUnloadedAtDestination, isFalse);
      
      // Adding event unrelated to unloading at final destination
      events.add(
          new HandlingEvent(cargo, date(10), new Date.now(), HandlingEventType.RECEIVE, HANGZOU));
      cargo.deriveDeliveryProgress(new HandlingHistory(events));
      expect(cargo.delivery.isUnloadedAtDestination, isFalse);
      
      voyage = 
          (new VoyageBuilder(new VoyageNumber("0123"), HANGZOU)
            ..addMovement(NEWYORK, new Date.now(), new Date.now())).build();
      
      // Adding an unload event, but not at the final destination
      events.add(
          new HandlingEvent(cargo, date(20), new Date.now(), HandlingEventType.UNLOAD, TOKYO, voyage));
      cargo.deriveDeliveryProgress(new HandlingHistory(events));
      expect(cargo.delivery.isUnloadedAtDestination, isFalse);
      
      // Adding an event in the final destincation, but not unload
      events.add(
          new HandlingEvent(cargo, date(30), new Date.now(), HandlingEventType.CUSTOMS, NEWYORK));
      cargo.deriveDeliveryProgress(new HandlingHistory(events));
      expect(cargo.delivery.isUnloadedAtDestination, isFalse);
      
      // Finally, cargo is unloaded at final destination
      events.add(
          new HandlingEvent(cargo, date(40), new Date.now(), HandlingEventType.UNLOAD, NEWYORK, voyage));
      cargo.deriveDeliveryProgress(new HandlingHistory(events));
      expect(cargo.delivery.isUnloadedAtDestination, isTrue);
    });
    
    test("is misdirected", () {
      // A cargo with no itinerary is not misdirected
      Cargo cargo = new Cargo(new TrackingId("TRKID"), new RouteSpecification(SHANGHAI, GOTHENBURG, new Date.now()));
      expect(cargo.delivery.isMisdirected, isFalse);
      
      cargo = setupCargoWithItinerary(voyage, SHANGHAI, ROTTERDAM, GOTHENBURG);
      
      // A cargo with no handling events is not misdirected
      expect(cargo.delivery.isMisdirected, isFalse);
      
      var handlingEvents = <HandlingEvent>[];
      
      // Happy path
      handlingEvents.add(new HandlingEvent(cargo, date(10), date(20), HandlingEventType.RECEIVE, SHANGHAI));
      handlingEvents.add(new HandlingEvent(cargo, date(30), date(40), HandlingEventType.LOAD, SHANGHAI, voyage));
      handlingEvents.add(new HandlingEvent(cargo, date(50), date(60), HandlingEventType.UNLOAD, ROTTERDAM, voyage));
      handlingEvents.add(new HandlingEvent(cargo, date(70), date(80), HandlingEventType.LOAD, ROTTERDAM, voyage));
      handlingEvents.add(new HandlingEvent(cargo, date(90), date(100), HandlingEventType.UNLOAD, GOTHENBURG, voyage));
      handlingEvents.add(new HandlingEvent(cargo, date(110), date(120), HandlingEventType.CLAIM, GOTHENBURG));
      handlingEvents.add(new HandlingEvent(cargo, date(130), date(140), HandlingEventType.CUSTOMS, GOTHENBURG));
      events.addAll(handlingEvents);
      
      cargo.deriveDeliveryProgress(new HandlingHistory(events));
      expect(cargo.delivery.isMisdirected, isFalse);
      
      // Try a couple of failing ones
      
      cargo = setupCargoWithItinerary(voyage, SHANGHAI, ROTTERDAM, GOTHENBURG);
      handlingEvents = <HandlingEvent>[];
      
      handlingEvents.add(new HandlingEvent(cargo, new Date.now(), new Date.now(), HandlingEventType.RECEIVE, HANGZOU));
      events.addAll(handlingEvents);
      cargo.deriveDeliveryProgress(new HandlingHistory(events));
      
      expect(cargo.delivery.isMisdirected, isTrue);
      
      
      cargo = setupCargoWithItinerary(voyage, SHANGHAI, ROTTERDAM, GOTHENBURG);
      handlingEvents = <HandlingEvent>[];
      
      handlingEvents.add(new HandlingEvent(cargo, date(10), date(20), HandlingEventType.RECEIVE, SHANGHAI));
      handlingEvents.add(new HandlingEvent(cargo, date(30), date(40), HandlingEventType.LOAD, SHANGHAI, voyage));
      handlingEvents.add(new HandlingEvent(cargo, date(50), date(60), HandlingEventType.UNLOAD, ROTTERDAM, voyage));
      handlingEvents.add(new HandlingEvent(cargo, date(70), date(80), HandlingEventType.LOAD, ROTTERDAM, voyage));
      
      events.addAll(handlingEvents);
      cargo.deriveDeliveryProgress(new HandlingHistory(events));
      
      expect(cargo.delivery.isMisdirected, isTrue);

      cargo = setupCargoWithItinerary(voyage, SHANGHAI, ROTTERDAM, GOTHENBURG);
      handlingEvents = <HandlingEvent>[];
      
      handlingEvents.add(new HandlingEvent(cargo, date(10), date(20), HandlingEventType.RECEIVE, SHANGHAI));
      handlingEvents.add(new HandlingEvent(cargo, date(30), date(40), HandlingEventType.LOAD, SHANGHAI, voyage));
      handlingEvents.add(new HandlingEvent(cargo, date(50), date(60), HandlingEventType.UNLOAD, ROTTERDAM, voyage));
      handlingEvents.add(new HandlingEvent(cargo, new Date.now(), new Date.now(), HandlingEventType.CLAIM, ROTTERDAM));
      
      events.addAll(handlingEvents);
      cargo.deriveDeliveryProgress(new HandlingHistory(events));
      
      expect(cargo.delivery.isMisdirected, isTrue);
    });
  });
}

Cargo createCargo(Location origin, Location distination, {TrackingId trackingId, Date arrivalDeadline}) {
  //TODO !?    
  if (!?trackingId) {
    trackingId = new TrackingId("XYZ");
  }
  
  if (!?arrivalDeadline) {
    arrivalDeadline = new Date.now();
  }
  
  return new Cargo(trackingId, new RouteSpecification(origin, distination, arrivalDeadline));
}

HandlingEvent createEvent(Cargo cargo, Date completionTime, HandlingEventType eventType, Location location, [Voyage voyage]) {
  
  if (?voyage) {
    return new HandlingEvent(cargo, completionTime, new Date.now(), eventType, location, voyage);
  }
  
  return new HandlingEvent(cargo, completionTime, new Date.now(), eventType, location);
}

Cargo setupCargoWithItinerary(Voyage voyage, Location origin, Location midpoint, Location destination) {
  Cargo cargo = new Cargo(new TrackingId("CARG01"), new RouteSpecification(origin, destination, new Date.now()));
  
  Itinerary itinerary = new Itinerary.withLegs([
    new Leg(voyage, origin, midpoint, new Date.now(), new Date.now()),
    new Leg(voyage, midpoint, destination, new Date.now(), new Date.now())
  ]);
  
  cargo.assignToRoute(itinerary);
  
  return cargo;
}

Date date(int num) => new Date.fromMillisecondsSinceEpoch(num, isUtc:false);