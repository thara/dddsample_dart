part of domain.location;

class UnLocode implements ValueObject<UnLocode> {

  /**
   * Country code is exactly two letters.
   * Location code is usually three letters, but may contain ther numbers 2-9 as well.
   */
  static final RegExp _VALID_PATTERN = new RegExp(r'[a-zA-Z]{2}[a-zA-Z2-9]{3}');

  final String unlocode;

  const UnLocode._(this.unlocode);
  
  factory UnLocode(String countryAndLocation) {
    if (countryAndLocation == null) throw new ArgumentError("Country and location may not be null.");
    
    //TODO Is it the standard way?
    if (_VALID_PATTERN.stringMatch(countryAndLocation) != countryAndLocation) {
      throw new ArgumentError("${countryAndLocation} is not a valid UN/LOCODE (does not match pattern).");
    }
    
    return new UnLocode._(countryAndLocation.toUpperCase());
  }

  String get idString => this.unlocode;

  bool sameValueAs(UnLocode other) =>
      other != null && this.unlocode == other.unlocode;

  int get hashCode => this.unlocode.hashCode;

  bool operator==(other) {
    if (identical(this, other)) return true;
    if (other is! UnLocode) return false;
    return sameValueAs(other as UnLocode);
  }

  String toString() => this.unlocode;
}