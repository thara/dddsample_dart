part of domain.cargo;

class HandlingHistory {
  
  static final HandlingHistory EMPTY = new HandlingHistory([]);
  
  final List<HandlingEvent> handlingEvents;
  
  HandlingHistory._(this.handlingEvents);
  
  factory HandlingHistory(List<HandlingEvent> handlingEvents) {
    if (handlingEvents == null) throw new ArgumentError("Handling Events is required.");
    return new HandlingHistory._(new List.from(handlingEvents));
  }
  
  List<HandlingEvent> distinctEventsByCompletionTime() {
    List<HandlingEvent> ordered = new List.from(new Set.from(this.handlingEvents));
    ordered.sort((he1, he2)=> he1.completionTime.compareTo(he2.completionTime));
    return ordered;
  }
  
  HandlingEvent mostRecentlyCompletedEvent() {
    List<HandlingEvent> distinctEvents = distinctEventsByCompletionTime();
    return distinctEvents.isEmpty ? null : distinctEvents.last;
  }
}