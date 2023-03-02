
import 'location.dart';

class Trip {
   LocationModel startPoint;
   LocationModel endPoint;
    String routeId;
    String startStationId;
    String endStationId;
   String userId;
   String createDate;
  String startPointAddress;
  String endPointAddress;
  String routeName;
  String fromToOfRoute;




  Trip(
      {required this.endPointAddress,
      required this.startPointAddress,
      required this.startPoint,
      required this.endPoint,
      required this.routeId,
      required this.startStationId,
      required this.endStationId,
      required this.userId,
      required this.createDate,
      required this.fromToOfRoute,
      required this.routeName});
}