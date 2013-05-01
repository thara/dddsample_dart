part of domain.voyage;

class Schedule {
  
  static const EMPTY = const Schedule._(const []);
  
  final List<CarrierMovement> _carrierMovements;

  const Schedule._(this._carrierMovements);
  
  factory Schedule(List<CarrierMovement> carrierMovements) {
    return new Schedule._(new List.from(carrierMovements));
  }
  
  List<CarrierMovement> get carrierMovements =>
    new List.from(_carrierMovements);
}