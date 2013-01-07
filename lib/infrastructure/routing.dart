library routeing;

import 'package:logging/logging.dart';

import 'package:dddsample_dart/domain/cargo.dart';
import 'package:dddsample_dart/domain/location.dart';
import 'package:dddsample_dart/domain/service.dart';
import 'package:dddsample_dart/domain/voyage.dart';

import 'package:dddsample_dart/pathfinder/path_finder.dart';

/**
 * Our end of the routing service. This is basically a data model
 * translation layer between our domain model and the API put forward
 * by the routing team, which operates in a different context from us.
 */
class ExternalRoutingService implements RoutingService {
  
  static final Logger logger = 
      new Logger("infrastructure.routing.ExternalRoutingService");
  
  final GraphTraversalService graphTraversalService;
  final LocationRepository locationRepos;
  final VoyageRepository voyageRepos;
  
  ExternalRoutingService(
      this.graphTraversalService, this.locationRepos, this.voyageRepos);
  
  List<Itinerary> fetchRoutesForSpecification(RouteSpecification routeSpec) {
    // The RouteSpecification is picked apart and adapted to the external API.
    var origin = routeSpec.origin;
    var destination = routeSpec.destination;
    
    var limitations = {'DEADLINE' : routeSpec.arrivalDeadline.toString()};
    
    List<TransitPath> transitPaths;
    try {
      transitPaths = graphTraversalService.findShortestPath(
          origin.unLocode.idString, destination.unLocode.idString, limitations);
    } on Exception catch (e) {
      logger.severe(e.toString());
      return [];
    }
    
    // The returned result is then translated back into our domain model.
    var itineraries = transitPaths
                        .map(_toItinerary)
                        .filter(routeSpec.isSatisfiedBy);
    
    if (itineraries.length != transitPaths.length) {
      logger.warning(
          "Received itinerary that did not satisfy the route specification");
    }
    
    return itineraries;
  }
  
  Itinerary _toItinerary(TransitPath transitPath) =>
    new Itinerary.withLegs(transitPath.transitEdges.map(_toLeg));
  
  Leg _toLeg(TransitEdge edge) {
    return new Leg(
        voyageRepos.find(new VoyageNumber(edge.voyageNumber)),
        locationRepos.find(new UnLocode(edge.fromUnLocode)),
        locationRepos.find(new UnLocode(edge.toUnLocode)),
        edge.fromDate, edge.toDate
    );
  }
}
