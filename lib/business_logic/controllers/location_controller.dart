import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:background_location/background_location.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as google_maps;
import 'package:geolocator/geolocator.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:location/location.dart' as loc;
import 'package:routescoapp/data/models/Destination.dart';
import 'package:signalr_core/signalr_core.dart';
import '../../Assistants/assistantMethods.dart';
import '../../Assistants/distance_calculator.dart';
import '../../Assistants/globals.dart';
import '../../Assistants/request-assistant.dart';
import '../../constants/current_data.dart';
import '../../constants/strings.dart';
import '../../data/models/address.dart';
import 'dart:math' show cos, sqrt, asin;

import '../../data/models/location.dart';
import '../../data/models/placePredictions.dart';
import '../../data/models/place_short.dart';

class LocationController extends GetxController {
  var pickUpAddress = ''.obs;
  var dropOffAddress = ''.obs;
  List placePredictionList = [].obs;
  var latPinLoc = 0.0.obs;
  var lngPinLoc = 0.0.obs;
  var startAddingPickUp = false.obs;
  var startAddingDropOff = false.obs;
  var buttonString = ''.obs;
  var addDropOff = false.obs;
  var addPickUp = false.obs;
  var tripCreatedDone = false.obs;
  var showPinOnMap = false.obs;
  var liveLocation = new LatLng(0.0, 0.0).obs;
  var currentLocation = new LatLng(29.376291619820897, 47.98638395798397).obs;
  var currentLocationG = new google_maps.LatLng(0.0, 0.0).obs;
  var liveLocationG = new google_maps.LatLng(0.0, 0.0).obs;

  Address? pickUpLocation;
  Address? dropOffLocation;
  var addressText =''.obs;
  var askedForRoute = false.obs;
  var animatedContainer = 120.0.obs;
  var isContainerOpen = false.obs;
  var startMovingCamera = false.obs;
  var stopMovingCamera = false.obs;


  Rx<Position> positionFromPin = Position(
          latitude: 29.37631633045168,
          accuracy: 0.0,
          altitude: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
          longitude: 47.98637351560368,
          heading: 0.0,
          timestamp: null)
      .obs;
  bool isLocationUpdated = false;

  var myCorrectBuses = [].obs;
  var myRouteBuses = [].obs;
  var myCorrectBusesGot = false.obs;
  var bussesList = [].obs;
  var bussesOnMapList = [].obs;
  var waitingForBusInfo = false.obs;

  var timeBusToR = 0.0.obs;
  late google_maps.BitmapDescriptor mapMarker;

  var points = [];
  var bussesIds = [].obs;
  var myFavAddresses = [].obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    Timer(Duration(milliseconds: 100), () {
      getCurrentLocationFromChannel();
      signalRInit();
      signalRTRacking();
    });
    getLocation();
  }

  void resetData() {
    myCorrectBusesGot.value = false;
    myCorrectBuses.clear();
    bussesList.clear();
    bussesOnMapList.clear();
    bussesIds.clear();
  }

  //get current location from ios channel
  static const locationChannel = MethodChannel('location');
  final arguments = {'name': 'khaled'};

  Future getCurrentLocationFromChannel() async {
    var value;
    try {
      value =
          await locationChannel.invokeMethod("getCurrentLocation", arguments);
      var lat = value['lat'];
      var lng = value['lng'];
      if (lng > 0.0) {
        user.currentLocation = LocationModel(value['lat'], value['lng']);

        print("value  , main :: ${value.toString()}");
        changePickUpAddress('Current Location');
        currentPosition = geo.Position(
          latitude: lat,
          longitude: lng,
          accuracy: 0.0,
          altitude: lat,
          speedAccuracy: 0.0,
          heading: 0.0,
          timestamp: DateTime.now(),
          speed: 0.0,
        );
        searchCoordinateAddress(LocationModel(lat, lng));

        addPickUp.value = true;
      } else {
        print('Wrong coordinates ###');
      }
    } catch (err) {
      print(err);
    }
  }

  Future updateMyLocationInSystem(LocationModel location) async {
    var headers = {
      'Authorization': 'bearer ${user.accessToken}',
      'Content-Type': 'application/json'
    };
    var request = http.Request('POST', Uri.parse('$baseUrl/api/UserTracking'));
    request.body = json.encode(
        {"Longitude": location.longitude, "Latitude": location.latitude});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
      print("......... send location update in system done  .......");
    } else {
      print(response.reasonPhrase);
    }
  }

  // send location signal
  HubConnection? connection;
  HubConnection? connectionTracking;

  final liveServerUrl = "https://route.click68.com/ChatHub";
  final liveServerTrackingUrl = "https://route.click68.com/trackinghub";

  //tracking hub
  Future<void> signalRTRacking() async {
    //tracking hub
    connectionTracking = HubConnectionBuilder()
        .withUrl(
            liveServerTrackingUrl,
            HttpConnectionOptions(
                // accessTokenFactory: () async => await liveTransactionAccessToken,
                transport: HttpTransportType.webSockets,
                logging: (level, message) {
                  if (message.contains(
                      'HubTransaction tracking connected successfully')) {
                    print('connected tracking successfully');
                  }
                  print(
                      "SignalR tracking Level: $level, Message: ${message.toString()}");
                }))
        .build();

    connectionTracking?.serverTimeoutInMilliseconds =
        Duration(minutes: 122).inMilliseconds;
    connectionTracking?.onclose((exception) {
      print("onclose.tracking. Exception: $exception");
    });
    connectionTracking?.onreconnected((connectionId) {
      print("-----tracking-- ConnectionId: $connectionId");
    });

    connectionTracking?.on('NearestLocation', (message) async {
      print(
          "---------- NearestLocation ..---------... Message: ${message!.first}");
      myCorrectBuses.value = message.first;
      myCorrectBusesGot.value = true;
      setBussesMarkers();
      update();
    });

    await connectionTracking?.start();
  }

  Future detectingCorrectBus() async {
    if (tripCreatedDone.value == true) {
      var invoke =
          await connectionTracking?.invoke("NearestBusLocation", args: [
        {"BusID": bussesIds},
      ]);
    }
  }

  Future<void> signalRInit() async {
    connection = HubConnectionBuilder()
        .withUrl(
            liveServerUrl,
            HttpConnectionOptions(
                // accessTokenFactory: () async => await liveTransactionAccessToken,
                transport: HttpTransportType.webSockets,
                logging: (level, message) {
                  if (message
                      .contains('HubConnection connected successfully')) {
                    print('connected successfully');
                  }
                  print(
                      "SignalR Level: $level, Message: ${message.toString()}");
                }))
        .build();

    connection?.serverTimeoutInMilliseconds =
        Duration(minutes: 122).inMilliseconds;
    connection?.onclose((exception) {
      print("onclose.. Exception: $exception");
    });
    connection?.onreconnected((connectionId) {
      print("------- ConnectionId: $connectionId");
    });

    await connection?.start();
  }

  // send user location signalr
  sendUserLocationSignalR(LocationModel location) async {
    print({
      "UserID": "${user.id}",
      "Longitude": location.longitude,
      "Latitude": location.latitude
    });
    await connection?.invoke('SendUserLocation', args: [
      {
        "UserID": "${user.id}",
        "Longitude": location.longitude,
        "Latitude": location.latitude
      }
    ]);
  }

  var location = loc.Location();
  geo.Position? currentPosition;
  double bottomPaddingOfMap = 0;
  late loc.PermissionStatus _permissionGranted;

//get location for all
  Future getLocation() async {
    mapMarker = await google_maps.BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(20, 20)),
      Platform.isAndroid ? 'assets/icons/bus.png' : 'assets/icons/bus75.png',
    );

    loc.Location location = loc.Location.instance;

    loc.PermissionStatus permissionStatus = await location.hasPermission();
    _permissionGranted = permissionStatus;
    if (_permissionGranted != loc.PermissionStatus.granted) {
      final loc.PermissionStatus permissionStatusReqResult =
          await location.requestPermission();

      _permissionGranted = permissionStatusReqResult;
    }
    loc.LocationData loca = await location.getLocation();
    user.currentLocation = LocationModel(loca.latitude!, loca.longitude!);

    print(" ##@@@@@@## current  location ##@@@@@@@## ${loca.heading} ,, ${loca.headingAccuracy}");

  //  BackgroundLocation.startLocationService(distanceFilter: 1);

    // BackgroundLocation.getLocationUpdates((location) async {
    //   //print(" #### get Location Updates #### $location");
    //   if (!isLocationUpdated) {
    //     isLocationUpdated = true;
    //     Timer(Duration(seconds: 3), () {
    //       user.currentLocation =
    //           LocationModel(location.latitude!, location.longitude!);
    //
    //       print("......... send location update counter .......");
    //       //  updateMyLocationInSystem(LocationModel(location.latitude!, location.longitude!));
    //       // sendUserLocationSignalR(LocationModel(location.latitude!, location.longitude!));
    //       isLocationUpdated = false;
    //     });
    //   }
    //   // print("location ....... background update ${location.longitude} - ${location.latitude}");
    //   //audioPlayerService.audio1Play();
    // });

    if (loca.latitude != null) {
      changePickUpAddress('Current Location');
      currentPosition = geo.Position(
        latitude: loca.latitude!,
        longitude: loca.longitude!,
        accuracy: loca.accuracy!,
        altitude: loca.altitude!,
        speedAccuracy: loca.speedAccuracy!,
        heading: loca.heading!,
        timestamp: DateTime.now(),
        speed: loca.speed!,
      );
      searchCoordinateAddress(LocationModel(loca.latitude!, loca.longitude!));
      addPickUp.value = true;
    }

    gotMyLocation(true);
    addPickUp.value = true;
    changePickUpAddress('Current Location');

    addPickUp.value = true;
  }

  Future searchCoordinateAddress(LocationModel location) async {
    AssistantMethods assistantMethods = AssistantMethods();
    String address =
        await assistantMethods.searchCoordinateAddress(currentPosition!, true);
    trip.startPointAddress = address;
    trip.startPoint = LocationModel(location.latitude, location.longitude);
    gotMyLocation(true);
    changePickUpAddress(address);
  }

  void changePickUpAddress(String pickUpAddressV) {
    pickUpAddress.value = pickUpAddressV;
    update();
  }

  void changeDropOffAddress(String dropOffAddressV) {
    dropOffAddress.value = dropOffAddressV;
    update();
  }

  void startAddingPickUpStatus(bool status) {
    startAddingPickUp.value = status;
    update();
  }

  void startAddingDropOffStatus(bool status) {
    startAddingDropOff.value = status;
    update();
  }

  void tripCreatedStatus(bool status) {
    tripCreatedDone.value = status;
    update();
  }

  refreshPlacePredictionList() {
    placePredictionList.clear();
    placePredictionList.add(PlaceShort(
      placeId: '0',
      mainText: 'set_location_on_map_txt'.tr,
      secondText: 'choose_txt'.tr,
    ));
    getMyFavAddresses();
  }

  void updatePickUpLocationAddress(Address pickUpAddress) {
    pickUpLocation = pickUpAddress;
    update();
  }

  void updateDropOffLocationAddress(Address dropOffAddress) {
    dropOffLocation = dropOffAddress;
    update();
  }

  updateLiveLoc(LatLng latLng) {
    liveLocation.value = latLng;
  }

  void findPlace(String placeName) async {
    if (placeName.length > 1) {
      placePredictionList.clear();
      String autoCompleteUrl =
          "https://api.mapbox.com/geocoding/v5/mapbox.places/$placeName.json?worldview=us&country=kw&access_token=$mapbox_token";

      var res = await RequestAssistant.getRequest(autoCompleteUrl);

      if (res == "failed") {
        print('failed');
        return;
      }
      if (res["features"].length < 1) {
        print('failed');
        return;
      }
      if (res["features"] != null) {
        print("res features  ===== :: ${res["features"]}");

        print(res['status']);
        var predictions = res["features"];

        var placesList = (predictions as List)
            .map((e) => PlacePredictions.fromJson(e))
            .toList();

        //placePredictionList = placesList;
        placesList.forEach((element) {
          placePredictionList.add(PlaceShort(
              placeId: element.id,
              mainText: element.text,
              secondText: element.place_name,
              lat: element.lat,
              lng: element.lng));
        });
        print(placePredictionList.first);
        update();
      }
    }
  }

  //
  RxBool gotMyLocation = false.obs;

  addMyLocation(bool got) {
    gotMyLocation.value = got;
    update();
  }

  updatePinPos(double lat, double lng) {
    latPinLoc.value = lat;
    lngPinLoc.value = lng;
    currentLocationG.value = google_maps.LatLng(lat, lng);
    update();
  }

//address
  Future getMyFavAddresses() async {
    var headers = {
      'Authorization': 'bearer ${user.accessToken}',
      'Content-Type': 'application/json'
    };
    var request =
        http.Request('Get', Uri.parse(baseURL + '/api/ListLocationByUser'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    var json = jsonDecode(await response.stream.bytesToString());

    if (response.statusCode == 200 && json['status'] == true) {
      print("res ====----==== ${json}");
      myFavAddresses.value = json["description"];

      if (myFavAddresses.length > 0) {
        for (int i = 0; i < 3; i++) {
          placePredictionList.add(PlaceShort(
            placeId: '$i',
            mainText: "${myFavAddresses[i]['name']}",
            secondText: '${myFavAddresses[i]['desc']}',
            lat: myFavAddresses[i]['latitude'],
            lng: myFavAddresses[i]['longitude'],
          ));
        }
      }

      return myFavAddresses;
    } else {
      print(response.reasonPhrase);
      return false;
    }
  }

  //get route's busses
  Future getRouteBusses(String routeId) async {
    print("route id: $routeId");
    myCorrectBusesGot.value = false;
    waitingForBusInfo.value = true;
    int index =0;
    points.clear();
    var headers = {
      'Authorization': 'bearer ${user.accessToken}',
      'Content-Type': 'application/json'
    };
    var request =
        http.Request('POST', Uri.parse(baseURL + '/api/divice/BusInRoute'));
    request.body = json.encode({"RouteID": routeId});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    var jsonResponse = jsonDecode(await response.stream.bytesToString());

    if (response.statusCode == 200 && jsonResponse['status'] == true) {
      print(
          "res ====--.......................length : ${jsonResponse["description"].length} ..................................--==== ");

      var query3 = trip.startPoint.longitude.toString() +
          "," +
          trip.startPoint.latitude.toString() +
          ";" +
          trip.endPoint.longitude.toString() +
          "," +
          trip.endPoint.latitude.toString();
      for (var p in jsonResponse["description"]) {
        index++;
        print("bus ===== $p");
        var query = p["longitude1"].toString() +
            "," +
            p["latitude1"].toString() +
            ";" +
            trip.startPoint.longitude.toString() +
            "," +
            trip.startPoint.latitude.toString() +
            ";" +
            trip.endPoint.longitude.toString() +
            "," +
            trip.endPoint.latitude.toString();

        var query2 = p["longitude2"].toString() +
            "," +
            p["latitude2"].toString() +
            ";" +
            trip.startPoint.longitude.toString() +
            "," +
            trip.startPoint.latitude.toString() +
            ";" +
            trip.endPoint.longitude.toString() +
            "," +
            trip.endPoint.latitude.toString();

        var busToEndP1 = await getDistanceInformation(query);
        var busToEndP2 = await getDistanceInformation(query2);
        var startToEnd = await getDistanceInformation(query3);

        print("busToEndP1 = ${busToEndP1["routes"][0]["distance"] / 1000} .............$index ..........");
        print("busToEndP2 = ${busToEndP2["routes"][0]["distance"] / 1000}");
        print("startToEnd = ${startToEnd["routes"][0]["distance"] / 1000}");

        print("bus id : ${p["busID"]}");

        if (busToEndP1["routes"][0]["distance"] >= busToEndP2["routes"][0]["distance"] &&
            busToEndP2["routes"][0]["distance"] > startToEnd["routes"][0]["distance"]) {
          var query4 = p["longitude2"].toString() +
              "," +
              p["latitude2"].toString() +
              ";" +
              trip.startPoint.longitude.toString() +
              "," +
              trip.startPoint.latitude.toString();

          var busToEnd = await getDistanceInformation(query4);
          print("bus to start duration =...........................= ${busToEnd["routes"][0]["duration"] / 60}");
          points.add(
            Point(p["latitude2"], p["longitude2"], p["busID"],
                distance: busToEndP2["routes"][0]["distance"],
                duration: busToEnd["routes"][0]["duration"]),
          );
          bussesIds.add(p["busID"]);
          bussesList.clear();
        }
      }
      waitingForBusInfo.value = false;

      print("-----points length =====--------------------------------== ${points.length}");
      if (bussesIds.length > 0) {
        Timer.periodic(
            Duration(seconds: 4), (Timer t) => detectingCorrectBus());
      }

      if (points.length > 1) {
        points.sort((a, b) {
          return a.distance.compareTo(b.distance);
        });
      } else if (points.length > 0) {
        timeBusToR.value = points[0].duration / 60;
      }

      update();
    } else {
      print("routeId ${trip.routeId}");
      print("Error getRouteBusses $jsonResponse");
    }
  }

  //set markers for correct busses
  setBussesMarkers() {
    bussesOnMapList.clear();
    for (var i = 0; myCorrectBuses.length > i; i++) {
      bussesOnMapList.add(google_maps.Marker(
          icon: mapMarker,
          flat: true,
          draggable: false,
          anchor: Offset(0.5, 1.0),
          rotation: double.parse(myCorrectBuses[i]["heading"].toString()),
          alpha: 1,
          infoWindow: google_maps.InfoWindow(
              title: '${trip.routeName}', snippet: trip.routeName),
          position: google_maps.LatLng(
              myCorrectBuses[i]["latitude2"], myCorrectBuses[i]["longitude2"]),
          markerId: google_maps.MarkerId(myCorrectBuses[i]["busID"]),
          onTap: () {
            print(myCorrectBuses[i]["busID"].toString());
          }));
    }
    waitingForBusInfo.value = false;
    print("bussesOnMapList l... ${bussesOnMapList.length}");

    updateTimeBusToStart(
        myCorrectBuses[0]["latitude2"], myCorrectBuses[0]["longitude2"]);
    update();
  }

  //update time bus to start
  updateTimeBusToStart(double correctBusLat, double correctBusLng) async {
    var query = correctBusLng.toString() +
        "," +
        correctBusLat.toString() +
        ";" +
        trip.startPoint.longitude.toString() +
        "," +
        trip.startPoint.latitude.toString();

    var busToStartUpdated = await getDistanceInformation(query);
    timeBusToR.value = 0.0;
    timeBusToR.value = busToStartUpdated["routes"][0]["duration"] / 60;
    update();
  }

  //calculate the distance between tow points and
  calculateDistance(
      LocationModel point1, LocationModel point2, stationQuery) async {
    double calculateDistance(lat1, lon1, lat2, lon2) {
      var p = 0.017453292519943295;
      var c = cos;
      var a = 0.5 -
          c((lat2 - lat1) * p) / 2 +
          c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
      return 12742 * asin(sqrt(a));
    }

    List<dynamic> data = [
      {"lat": point1.latitude, "lng": point1.longitude},
      {"lat": point2.latitude, "lng": point2.longitude}
    ];
    double totalDistance = 0;
    for (var i = 0; i < data.length - 1; i++) {
      totalDistance += calculateDistance(data[i]["lat"], data[i]["lng"],
          data[i + 1]["lat"], data[i + 1]["lng"]);
    }

    return totalDistance;
  }

  //distanceInformation
  getDistanceInformation(query) async {
    //way 2

    final response = await http.get(Uri.parse(
        "https://api.mapbox.com/directions/v5/mapbox/driving-traffic/$query?alternatives=true&annotations=distance%2Cduration%2Cspeed&geometries=geojson&language=en&overview=full&steps=true&access_token=$mapbox_token"));
    if (response.statusCode == 200) {
      print('getDistanceInformation ${response.statusCode}');
      var decoded = jsonDecode(response.body);
      print("driving $decoded");
      return decoded;
    } else {
      print(response);
      print("boody getDistanceInformation error ${response.body}");
      return;
    }
  }

  //2
  distanceCalculation() {
    for (var d in points) {
      var km = getDistanceFromLatLonInKm(
          trip.startPoint.longitude, trip.startPoint.longitude, d.lat, d.lng);
      // var m = Geolocator.distanceBetween(position.latitude,position.longitude, d.lat,d.lng);
      // d.distance = m/1000;
      d.distance = km;
      bussesList.add(d);

      print("*********busses list length************ ${bussesList.length}");

      print("*********#########************ ${d.name}");

      // print(getDistanceFromLatLonInKm(position.latitude,position.longitude, d.lat,d.lng));
    }

    bussesList.sort((a, b) {
      return a.distance.compareTo(b.distance);
    });
  }
}


