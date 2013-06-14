library dddsample.domain;

import 'cargo.dart';
import 'handling.dart';
import 'location.dart';
import 'voyage.dart';

export 'cargo.dart';
export 'handling.dart';
export 'location.dart';
export 'voyage.dart';

abstract class RoutingService {
  
  List<Itinerary> fetchRoutesForSpecification(RouteSpecification routeSpec);
}