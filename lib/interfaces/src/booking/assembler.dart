part of booking;

/** Assembler class for the [CargoRoutingDto] */
class CargoRoutingDtoAssembler {
  
  CargoRoutingDto toDto(Cargo cargo) {
    var dto = new CargoRoutingDto(
        cargo.trackingId.idString,
        cargo.origin.unLocode.idString,
        cargo.routeSpec.destination.unLocode.idString,
        cargo.routeSpec.arrivalDeadline,
        cargo.delivery.routingStatus.sameValueAs(RoutingStatus.MISROUTED));
    
    for (var leg in cargo.itinerary.legs) {
      dto.addLeg(
          leg.voyage.voyageNumber.idString,
          leg.loadLocation.unLocode.idString,
          leg.unloadLocation.unLocode.idString,
          leg.loadTime,
          leg.unloadTime);
    }
    return dto;
  }
}

class ItineraryCandidateDtoAssembler {
  
  RouteCandidateDto toDto(Itinerary itinerary) =>
    new RouteCandidateDto(itinerary.legs.map(toLegDto));
  
  LegDto toLegDto(Leg leg) {
    var voyageNumber = leg.voyage.voyageNumber;
    var from = leg.loadLocation.unLocode;
    var to = leg.unloadLocation.unLocode;
    return new LegDto(voyageNumber.idString,
                        from.idString, to.idString, 
                        leg.loadTime, leg.unloadTime);
  }
  
  Itinerary fromDto(RouteCandidateDto routeCandidateDto,
                    VoyageRepository voyageRepos,
                    LocationRepository locationRepos) {
    
    var legs = routeCandidateDto.legs.map((LegDto legDto) {
      var voyageNumber = new VoyageNumber(legDto.voyageNumber);
      var voyage = voyageRepos.find(voyageNumber);
      var from = locationRepos.find(new UnLocode(legDto.from));
      var to = locationRepos.find(new UnLocode(legDto.to));
      return new Leg(voyage, from, to, legDto.loadTime, legDto.unloadTime);
    });
    
    return new Itinerary.withLegs(legs);
  }
}

class LocationDtoAssembler {
  
  LocationDto toDto(Location location) =>
    new LocationDto(location.unLocode.idString, location.name);
  
  List<LocationDto> toDtoList(List<Location> allLocations) => 
    allLocations.map(toDto);
}