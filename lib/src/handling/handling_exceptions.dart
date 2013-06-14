part of domain.handling;

class UnknownCargoException implements Exception {
  
  final TrackingId trackingId;
  
  UnknownCargoException(this.trackingId);
  
  String toString() =>
      "No cargo with tracking id ${trackingId.idString} exists in the system";
}

class UnknownVoyageException implements Exception {
  
  final VoyageNumber voyageNumber;
  
  UnknownVoyageException(this.voyageNumber);
  
  String toString() =>
      "No voyage with number ${voyageNumber.idString} exists in the system";
}

class UnknownLocationException implements Exception {
  
  final UnLocode unLocode;
  
  UnknownLocationException(this.unLocode);
  
  String toString() => 
      "No location with UN locode ${unLocode.idString} exists in the system";
}

class CannotCreateHandlingEventException implements Exception {
  
  final Exception e;
  
  CannotCreateHandlingEventException(this.e);
}