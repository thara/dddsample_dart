part of tracking;

class TrackCommand {
  String trackingId;
  String toString() => trackingId;
}

class TrackCommandValidator {
  
  void validate(TrackCommand command, onError()) {
    if (command.trackingId == null || command.trackingId.isEmpty) {
      onError();
    }
  }
}