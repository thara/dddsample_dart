part of path_finder;

/**
 * Part of the external graph traversal API exposed by the routing team
 * and used by us (booking and tracking team).
 */
abstract class GraphTraversalService {
  
  factory GraphTraversalService() {
    return new _GraphTraversalServiceImpl(new _GraphDAO());
  }
  
  List<TransitPath> findShortestPath(
      String originUnLocode,
      String destinationUnLocode, [Map<String, String> limitations]);
}

class _GraphTraversalServiceImpl implements GraphTraversalService {

  static const int ONE_MIN_MS = 1000 * 60;
  static const int ONE_DAY_MS = ONE_MIN_MS * 60 * 24;
  
  final _GraphDAO _dao;
  final math.Random _random;
  
  _GraphTraversalServiceImpl(this._dao) : this._random = new math.Random();
  
  List<TransitPath> findShortestPath(
                      String originUnLocode,
                      String destinationUnLocode,
                      [Map<String, String> limitation]) {
    
    var date = nextDate(new DateTime.now());
    
    var allVertices = _dao.listLocations();
    
    var filters = [originUnLocode, destinationUnLocode];
    var vertices = allVertices.where((elem) => !filters.contains(elem)).toList(); 
    
    var candidateCount = getRandomNumberOfCandidates();
    var candidates = new List<TransitPath>(candidateCount);
    
    for (var i = 0; i < candidateCount; i++) {
      vertices = getRandomChunkOfLocations(vertices);
      var transitEdges = new List<TransitEdge>(vertices.length - 1);
      
      var firstLegTo = vertices[0];
      var fromDate = nextDate(date);
      var toDate = nextDate(fromDate);
      date = nextDate(toDate);
      
      transitEdges.add(new TransitEdge(
          _dao.getVoyageNumber(originUnLocode, firstLegTo),
          originUnLocode, firstLegTo, fromDate, toDate));
      
      for (int j = 0; j < vertices.length - 1; j++) {
        var curr = vertices[j];
        var next = vertices[j + 1];
        fromDate = nextDate(date);
        toDate = nextDate(fromDate);
        date = nextDate(toDate);
        transitEdges.add(
          new TransitEdge(
            _dao.getVoyageNumber(curr, next), curr, next, fromDate, toDate));
      }
      
      var lastLegFrom = vertices.last;
      fromDate = nextDate(date);
      toDate = nextDate(fromDate);
      transitEdges.add(new TransitEdge(
        _dao.getVoyageNumber(lastLegFrom, destinationUnLocode),
        lastLegFrom, destinationUnLocode, fromDate, toDate));

      candidates.add(new TransitPath(transitEdges));
    }
    
    return candidates;
  }
  
  DateTime nextDate(DateTime date) {
    return new DateTime(date.millisecondsSinceEpoch +
                      ONE_DAY_MS + (_random.nextInt(1000) - 500) * ONE_MIN_MS);
  }
  
  int getRandomNumberOfCandidates() {
    return 3 + _random.nextInt(3);
  }
  
  List<String> getRandomChunkOfLocations(List<String> allLocations) {
    allLocations = shuffle(allLocations);
    var total = allLocations.length;
    var chunk = total > 4 ? 1 + new math.Random().nextInt(5) : total;
    return allLocations.sublist(0, chunk);
  }
  
  List shuffle(List items) {
    var random = new math.Random();
    // Go through all elements.
    for (var i = items.length - 1; i > 0; i--) {
      // Pick a pseudorandom number.
      var n = random.nextInt(items.length + 1);
      var temp = items[i];
      items[i] = items[n];
      items[n] = temp;
    }
    return items;
  }
}

class _GraphDAO {
  
  static final math.Random _random = new math.Random();
  
  List<String> listLocations() {
    return [
      "CNHKG", "AUMEL", "SESTO", "FIHEL", "USCHI", "JNTKO", "DEHAM",
      "CNSHA", "NLRTM", "SEGOT", "CNHGH", "USNYC", "USDAL"
    ];
  }
  
  String getVoyageNumber(String from, String to) {
    var i = _random.nextInt(5);
    if (i == 0) return "0100S";
    if (i == 1) return "0200T";
    if (i == 2) return "0300A";
    if (i == 3) return "0301S";
    return "0400S";
  }
}