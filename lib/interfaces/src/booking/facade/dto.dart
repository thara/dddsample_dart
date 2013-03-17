part of booking;

/** Location DTO. */
class LocationDto {
  final String unLocode;
  final String name;
  LocationDto(this.unLocode, this.name);
}

class LegDto {
  final String voyageNumber;
  final String from;
  final String to;
  final DateTime loadTime;
  final DateTime unloadTime;
  
  LegDto(this.voyageNumber, this.from, this.to, this.loadTime, this.unloadTime);
}

class CargoRoutingDto {
  
  final String trackingId;
  final String origin;
  final String finalDestination;
  final DateTime arrivalDeadline;
  final bool misrouted;
  final List<LegDto> _legs = [];
  
  CargoRoutingDto(this.trackingId, this.origin,
                  this.finalDestination, this.arrivalDeadline, this.misrouted);
  
  void addLeg(String voyageNumber,
                String from, String to, DateTime loadTime, DateTime unloadTime) {
    _legs.add(new LegDto(voyageNumber, from, to, loadTime, unloadTime));
  }
  
  List<LegDto> get legs => new List.from(_legs);
  
  bool get isRouted => !_legs.isEmpty;
}

/** 
 * DTO for presenting and selecting an itinerary from a collection of candidates.
 */
class RouteCandidateDto {
  final List<LegDto> _legs;
  RouteCandidateDto(this._legs);
  List<LegDto> get legs => new List.from(_legs);
}
