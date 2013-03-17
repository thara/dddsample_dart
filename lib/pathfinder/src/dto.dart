part of path_finder;

/**
 * Represents an edge in a path through a graph,
 * describing the route of a cargo.
 */
class TransitEdge {
  
  final String voyageNumber;
  final String fromUnLocode;
  final String toUnLocode;
  final DateTime fromDate;
  final DateTime toDate;
  
  TransitEdge(this.voyageNumber,
              this.fromUnLocode, this.toUnLocode,
              this.fromDate, this.toDate);
}

class TransitPath {
  
  final List<TransitEdge> _transitEdges;
  
  TransitPath(List<TransitEdge> transitEdges) :
    _transitEdges = new List.from(transitEdges);
  
  List<TransitEdge> get transitEdges => new List.from(_transitEdges);
}