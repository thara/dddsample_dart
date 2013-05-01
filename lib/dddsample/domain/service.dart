library domain.service;

import 'cargo.dart';
import 'location.dart';

abstract class RoutingService {
  
  List<Itinerary> fetchRoutesForSpecification(RouteSpecification routeSpec);
}
