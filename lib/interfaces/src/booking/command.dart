part of booking;

class CargoAdminController {
  
  BookingServiceFacade _bookingServiceFacade;
  
  void registrationForm(
    show(List<LocationDto> dtoList, List<String> unLocodeStrings)) {
    
    List<LocationDto> dtoList = _bookingServiceFacade.listShippingLocations();
    var unLocodeStrings = 
        _bookingServiceFacade.listShippingLocations().map((_) => _.unLocode);
  }
  
  void register(RegistrationCommand command, onSuccess(String trackingId)) {
    var arrivalDeadline = new DateFormat("M/dd/yyyy").parse(command.arrivalDeadline);
    var trackingId = 
      _bookingServiceFacade.bookNewCargo(
        command.originUnlocode, command.destinationUnlocode, arrivalDeadline);
    onSuccess(trackingId);
  }
  
  void list(callback(List<CargoRoutingDto> cargoList)) {
    var cargoList = _bookingServiceFacade.listAllCargos();
    callback(cargoList);
  }
  
  void show(String trackingId, callback(CargoRoutingDto dto)) {
    var dto = _bookingServiceFacade.loadCargoForRouting(trackingId);
    callback(dto);
  }
  
  void selectItinerary(String trackingId,
    callback(List<RouteCandidateDto> routeCandidates, CargoRoutingDto cargoDto)) {
    
    var routeCandidates = _bookingServiceFacade.requestPossibleRoutesForCargo(trackingId);
    var cargoDto = _bookingServiceFacade.loadCargoForRouting(trackingId);
    callback(routeCandidates, cargoDto);
  }
  
  void assignItinerary(RouteAssignmentCommand command, onSuccess(String trackingId)) {
    var legDtos = command.legs.map((_) {
      return new LegDto(_.voyageNumber,
          _.fromUnLocode, _.toUnLocode, _.fromDate, _.toDate);
    });
    
    var selectedRoute = new RouteCandidateDto(legDtos);
    
    _bookingServiceFacade.assignCargoToRoute(command.trackingId, selectedRoute);
    onSuccess(command.trackingId);
  }
  
  void pickNewDestination(String trackingId, callback(List<LocationDto> locations, CargoRoutingDto cargo)) {
    var locations = _bookingServiceFacade.listShippingLocations();
    var cargo = _bookingServiceFacade.loadCargoForRouting(trackingId);
    callback(locations, cargo);
  }
}

class RegistrationCommand {
  String originUnlocode;
  String destinationUnlocode;
  String arrivalDeadline;
}

class RouteAssignmentCommand {
  String trackingId;
  List<LegCommand> legs;
}

class LegCommand {
  String voyageNumber;
  String fromUnLocode;
  String toUnLocode;
  Date fromDate;
  Date toDate;
  LegCommand(this.voyageNumber,
      this.fromUnLocode, this.toUnLocode, this.fromDate, this.toDate);
}