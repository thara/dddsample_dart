part of location;

class Location implements Entity<Location> {

  static const Location UNKNOWN =
      const Location._(const UnLocode._("XXXXX"), "Unknown location");

  final UnLocode unLocode;
  final String name;

  const Location._(this.unLocode, this.name);
  
  factory Location(UnLocode unLocode, String name) {
    if (unLocode == null) throw new ArgumentError("UnLocode must not be null.");
    if (name == null) throw new ArgumentError("name must not be null.");
    return new Location._(unLocode, name);
  }

  /** [override] */
  bool sameIdentityAs(Location other) {
    return this.unLocode.sameValueAs(other.unLocode);
  }

  int get hashCode => this.unLocode.hashCode;

  bool operator==(other) {
    if (identical(this, other)) return true;
    if (other is! Location) return false;
    return sameIdentityAs(other as Location);
  }

  String toString() => "$name [$unLocode]";
}

abstract class LocationRepository {

  /**
   * Finds a location using [unlocode].
   */
  Location find(UnLocode unlocode);

  /**
   * Finds all locations.
   */
  List<Location> findAll();
}