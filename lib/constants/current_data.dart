import 'package:intl/intl.dart';
import '../data/models/charge_toSave_model.dart';
import '../data/models/location.dart';
import '../data/models/payment_saved_model.dart';
import '../data/models/tripModel.dart';
import '../data/models/trip_to_save_model.dart';
import '../data/models/user.dart';



var time = DateFormat('yyyy-MM-dd-HH:mm').format(DateTime.now());
Trip trip = Trip(endPointAddress:'',startPointAddress:'',startPoint:LocationModel(29.37631633045168,47.98637351560368),endPoint: LocationModel(0.0,0.0),routeId: '',startStationId: '',endStationId: '',userId: '',createDate: time,fromToOfRoute:'',routeName:'');
LocationModel currentLocation = LocationModel(29.37631633045168,47.986373515603680);

LocationModel locationChoose = LocationModel(29.37631633045168,47.986373515603680);

ChargeSaved chargeSaved = ChargeSaved();
PaymentSaved paymentSaved = PaymentSaved();
TripToSave tripToSave = TripToSave();
User user = User(accessToken: ' ');
String promoterId ="";