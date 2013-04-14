part of cargo;

class HandlingActivity implements ValueObject<HandlingActivity> {
  
  final HandlingEventType type;
  final Location location;
  final Voyage voyage;
  
  HandlingActivity._(this.type, this.location, this.voyage);
  
  factory HandlingActivity(HandlingEventType type, Location location, [Voyage voyage = null]) {
    if (type == null) throw new ArgumentError("Handling event type is required.");
    if (location == null) throw new ArgumentError("Location is required.");
    
    if (?voyage) {
      if (voyage == null) throw new ArgumentError("Voyage is required.");
    }
    
    return new HandlingActivity._(type, location, voyage);  
  }
  
  bool sameValueAs(HandlingActivity other) =>
      other != null &&
        type == other.type &&
          location == other.location &&
            (voyage == null ? other.voyage == null : voyage == other.voyage);

  int get hashCode {
    const int constant = 37;
    return
      [this.type, this.location, this.voyage]
        .fold(17, (total, elem) => elem ? total : total * constant + elem.hashCode);
  }

  bool operator==(other) {
    if (identical(this, other)) return true;
    if (other is! HandlingActivity) return false;
    return sameValueAs(other as HandlingActivity);
  }
}
