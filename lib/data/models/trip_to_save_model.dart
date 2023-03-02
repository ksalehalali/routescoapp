
class TripToSave {
   var startStationID;
  var routeID;
  var  endStationID;
  var  startPointLong;
  var  startPointLut;
  var  endPointLong;
   var  endPointLut;
   String? busId;
   String? paymentId;
   String? id;

  TripToSave(
      {this.startStationID,
      this.routeID,
      this.endStationID,
      this.startPointLong,
      this.startPointLut,
      this.endPointLong,
      this.endPointLut,
      this.busId,
      this.paymentId,this.id});
}