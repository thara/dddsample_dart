part of booking;

/**
 * This facade shields the domain layer - model, services, repositories.
 */
class BookingServiceFacade {
 
  static final Logger logger =
    new Logger("dddsample_dart.interfaces.BookingServiceFacade");
  
  final BookingService _bookingService;
  final LocationRepository _locationRepos;
  final CargoRepository _cargoRepos;
  final VoyageRepository _voyageRepos;
  
  BookingServiceFacade(this._bookingService,
                        this._locationRepos,
                        this._cargoRepos,
                        this._voyageRepos);
  
  String bookNewCargo(String origin, String destination, DateTime arrivalDeadline) {
    var trackingId = _bookingService.bookNewCargo(
        new UnLocode(origin), new UnLocode(destination), arrivalDeadline
    );
    return trackingId.idString;
  }
  
  CargoRoutingDto loadCargoForRouting(String trackingId) {
    var cargo = _cargoRepos.find(new TrackingId(trackingId));
    return new CargoRoutingDtoAssembler().toDto(cargo);
  }
  
  void assignCargoToRoute(String trackingIdStr, RouteCandidateDto routeCandidateDto) {
    var assembler = new ItineraryCandidateDtoAssembler();
    var itinerary = assembler.fromDto(
                      routeCandidateDto, _voyageRepos, _locationRepos);
    var trackingId = new TrackingId(trackingIdStr);
    _bookingService.assignCargoToRoute(itinerary, trackingId);
  }
  
  void changeDestination(String trackingIdStr, String destinationUnLocode) {
    var trackingId = new TrackingId(trackingIdStr);
    var destination = new UnLocode(destinationUnLocode);
    _bookingService.changeDestination(trackingId, destination);
  }
  
  List<RouteCandidateDto> requestPossibleRoutesForCargo(String trackingIdStr) {
    var trackingId = new TrackingId(trackingIdStr);
    var itineraries = _bookingService.requestPossibleRoutesForCargo(trackingId);
    return itineraries.map(new ItineraryCandidateDtoAssembler().toDto).toList();
  }
  
  List<LocationDto> listShippingLocations() {
    var allLocations = _locationRepos.findAll();
    return new LocationDtoAssembler().toDtoList(allLocations);
  }
  
  List<CargoRoutingDto> listAllCargos() {
    var cargoList = _cargoRepos.findAll();
    return cargoList.map(new CargoRoutingDtoAssembler().toDto).toList();
  }
}