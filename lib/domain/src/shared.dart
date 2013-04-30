library shared;

/**
 * An entity, as explained in the DDD book.
 */
abstract class Entity<T> {
  /**
   * Returns true if the identities are the same, regardless of [other].
   */
  bool sameIdentityAs(T other);
}

/**
 * A value object, as described in the DDD book.
 */
abstract class ValueObject<T> {
  /**
   * Returns true if [other] and this value object's attributes are the same.
   */
  bool sameValueAs(T other);
}

/**
 * A domain event is something that is unique, but does not have a lifecycle.
 * The identity may explicit, for example the sequence number of a payment,
 * or it could be derived from various aspects of the event such as where, 
 * when and what has happend.
 */
abstract class DomainEvent<T> {
  
  bool sameEventAs(T other);
}

typedef bool Proposition<T>(T t);

/**
 * A specification.
 */
abstract class Specification<T> {

  /**
   * Check if [target] is satisfied by the specification.
   */
  bool isSatisfiedBy(T target);

  Specification<T> and(Specification<T> spec) {
    return new AndSpecification<T>(this, spec);
  }

  Specification<T> or(Specification<T> spec) {
    return new OrSpecification<T>(this, spec);
  }

  Specification<T> not(Specification<T> spec) {
    return new NotSpecification<T>(spec);
  }
}

class AndSpecification<T> extends Specification<T> {

  final Specification<T> _spec1;
  final Specification<T> _spec2;

  AndSpecification(this._spec1, this._spec2);

  /**
   * see [Specification#isSatisfiedBy]
   */
  bool isSatisfiedBy(T target) {
    return _spec1.isSatisfiedBy(target) && _spec2.isSatisfiedBy(target);
  }
}

class OrSpecification<T> extends Specification<T> {

  final Specification<T> _spec1;
  final Specification<T> _spec2;

  OrSpecification(this._spec1, this._spec2);

  /**
   * see [Specification#isSatisfiedBy]
   */
  bool isSatisfiedBy(T target) {
    return _spec1.isSatisfiedBy(target) || _spec2.isSatisfiedBy(target);
  }
}

class NotSpecification<T> extends Specification<T> {

  final Specification<T> _spec1;

  NotSpecification(this._spec1);

  /**
   * see [Specification#isSatisfiedBy]
   */
  bool isSatisfiedBy(T target) {
    return !_spec1.isSatisfiedBy(target);
  }
}