import 'dart:async';

import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:geolocator/geolocator.dart';
import 'dart:math' show cos, sqrt, asin;
import 'package:location/location.dart' as loc;
import 'package:background_location/background_location.dart';
import 'package:routescoapp/business_logic/bloc/location_bloc_bloc.dart';

import '../../constants/strings.dart';
import '../models/address.dart';
import '../models/location.dart';
import '../models/placePredictions.dart';
import 'request-assistant.dart';

class LocationWebService {
  //get current location from ios channel
  static const locationChannel = MethodChannel('location');
  final arguments = {'name': 'khaled'};
  var pickUpAddress = '';
  bool gotMyLocation = false;
  var addPickUp = false;
  bool isLocationUpdated = false;
  bool startAddingPickUp = false;
  bool startAddingDropOff = false;
  var dropOffAddress = '';

  Future getCurrentLocationFromChannel() async {
    var value;
    try {
      value =
          await locationChannel.invokeMethod("getCurrentLocation", arguments);
      var lat = value['lat'];
      var lng = value['lng'];
      if (lng > 0.0) {
        //   user.currentLocation = LocationModel(value['lat'], value['lng']);

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

        addPickUp = true;
      } else {
        print('Wrong coordinates ###');
      }
    } catch (err) {
      print(err);
    }
  }

  var location = loc.Location();
  geo.Position? currentPosition;
  double bottomPaddingOfMap = 0;
  late loc.PermissionStatus _permissionGranted;

  //get location for all
  Future getLocation() async {
    print("-----------.... get location for all");
    loc.Location location = loc.Location.instance;

    loc.PermissionStatus permissionStatus = await location.hasPermission();
    _permissionGranted = permissionStatus;

    if (_permissionGranted != loc.PermissionStatus.granted) {
      final loc.PermissionStatus permissionStatusReqResult =
          await location.requestPermission();

      _permissionGranted = permissionStatusReqResult;
    } else {
      print(" -----------1111------------ ${permissionStatus}");
    }
    loc.LocationData loca = await location.getLocation();
    //user.currentLocation = LocationModel(loca.latitude!, loca.longitude!);

    print(
        " ##@@@@@@## current  location ##@@@@@@@## ${loca.heading} ,, ${loca.headingAccuracy}");

    BackgroundLocation.startLocationService(distanceFilter: 1);

    BackgroundLocation.getLocationUpdates((location) async {
      //print(" #### get Location Updates #### $location");
      if (!isLocationUpdated) {
        isLocationUpdated = true;
        Timer(Duration(seconds: 3), () {
          // user.currentLocation =
          //     LocationModel(location.latitude!, location.longitude!);

          print("......... send location update counter ...${location.longitude}....");
          //  updateMyLocationInSystem(LocationModel(location.latitude!, location.longitude!));
          // sendUserLocationSignalR(LocationModel(location.latitude!, location.longitude!));
          isLocationUpdated = false;
        });
      }
      // print("location ....... background update ${location.longitude} - ${location.latitude}");
      //audioPlayerService.audio1Play();
    });

    // if (loca.latitude != null) {
    //   changePickUpAddress('Current Location');
    //   currentPosition = geo.Position(
    //     latitude: loca.latitude!,
    //     longitude: loca.longitude!,
    //     accuracy: loca.accuracy!,
    //     altitude: loca.altitude!,
    //     speedAccuracy: loca.speedAccuracy!,
    //     heading: loca.heading!,
    //     timestamp: DateTime.now(),
    //     speed: loca.speed!,
    //   );
    //   searchCoordinateAddress(LocationModel(loca.latitude!, loca.longitude!));
    //   addPickUp = true;
    // }

    gotMyLocation = true;
    addPickUp = true;
    changePickUpAddress('Current Location');

    addPickUp = true;
    return loca;
  }

  Future searchCoordinateAddress(LocationModel location) async {
    String address = await searchCoordinateAddressGet(currentPosition!, true);
    // trip.startPointAddress = address;
    // trip.startPoint = LocationModel(location.latitude, location.longitude);
    gotMyLocation = true;
    changePickUpAddress(address);
  }

  void changePickUpAddress(String pickUpAddressV) {
    pickUpAddress = pickUpAddressV;
  }

  void changeDropOffAddress(String dropOffAddressV) {
    dropOffAddress = dropOffAddressV;
  }

  //addresses
  Future<String> searchCoordinateAddressGet(
      Position position, bool homeCall) async {
    String placeAddress = "";

    var res = await RequestAssistant.getRequest(
        'https://api.mapbox.com/geocoding/v5/mapbox.places/${position.longitude},${position.latitude}.json?access_token=$mapbox_token');
    if (res != "failed") {
      if (startAddingPickUp == true) {
        changePickUpAddress(res['features'][0]['place_name']);
      } else if (startAddingDropOff == true) {
        changeDropOffAddress(res['features'][0]['place_name']);
      }
      placeAddress = res['features'][0]['place_name'];
      print("address ===== $placeAddress");
      Address userAddress = Address();
      userAddress.latitude = position.latitude;
      userAddress.longitude = position.longitude;
      userAddress.placeName = placeAddress;
    } else {
      print("get address failed");
    }

    return placeAddress;
  }

  //get place address
  Future findPlace(String placeName) async {
    if (placeName.length > 1) {
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
          // location_bloc.placePredictionList.add(PlaceShort(
          //     placeId: element.id,
          //     mainText: element.text,
          //     secondText: element.place_name,
          //     lat: element.lat,
          //     lng: element.lng));
        });
    //    print(location_bloc.placePredictionList.first);
        return placesList;

      }
    }

  }

}

class PlaceShort {
  String? placeId;
  String? mainText;
  String? secondText;
  double? lat;
  double? lng;

  PlaceShort(
      {this.mainText, this.placeId, this.secondText, this.lat, this.lng});
}