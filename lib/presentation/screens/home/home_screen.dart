import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:shared_preferences/shared_preferences.dart';
import '../../../business_logic/controllers/lang_controller.dart';
import '../../../business_logic/cubit/internet_bloc/internet_bloc.dart';
import '../../../business_logic/cubit/internet_bloc/internet_state.dart';
import '../../../business_logic/bloc/location_bloc_bloc.dart';
import '../../../constants/strings.dart';
import '../../../data/models/address.dart';
import '../../../data/web_services/location_web_service.dart';
import '../../widgets/divider.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int navIndex = 3;

  double bottomPaddingOfMap = 0;

  CameraPosition cameraPosition = CameraPosition(
      target: LatLng(29.370314422169248, 47.98216642044717), zoom: 14.0);

  Completer<GoogleMapController> _controllerMaps = Completer();

  bool showDisSelection = false;

  GoogleMapController? homeMapController;

  late BitmapDescriptor pickUpMapMarker3;

  bool setCustomMarkerDone = false;

  double animatedContainer = 250;
  String dropOffString = "Enter 3 letters to search";
  bool isFocused = false;
  bool isContainerOpen = false;
  bool pickUpFilling = false;
  FocusNode? focusNodePickUp;
  FocusNode? focusNodeDropOff;

  //custom icon
  void setCustomIconMarker() async {
    setCustomMarkerDone = false;
    pickUpMapMarker3 = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(1, 1)),
        Platform.isAndroid
            ? 'assets/images/pickupmarkerIos.png'
            : 'assets/images/pickupmarkerIOs24.png');
    setCustomMarkerDone = true;
  }
  late LocationBloc locationBloc;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    locationBloc = BlocProvider.of<LocationBloc>(context);
  }
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Material(
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(65.0),
            child: Container(
              padding: EdgeInsets.only(left: 8, top: 10),
              color: Colors.blue,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                      onTap: () {
                        setState(() {
                          animatedContainer = 100;
                          isContainerOpen = false;
                        });
                      },
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 30,
                      )),
                  SizedBox(width: screenSize.width * 0.075),
                  const Text(
                    'select_destination',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  Image.asset(
                    'assets/animated_images/app_bar_arrow.png',
                    width: 100,
                    height: 100,
                    fit: BoxFit.fitHeight,
                  ),
                ],
              ),
            ),
          ),
          body: BlocListener<InternetBloc, InternetState>(
            listener: (context, state) {
              if (state is Connected) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content:
                      Text(state.msg, style: TextStyle(color: Colors.white)),
                  duration: Duration(seconds: 1),
                  backgroundColor: Colors.green,
                ));
              } else if (state is NotConnected) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                  state.msg,
                )));
              }
            },
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: cameraPosition,
                  mapToolbarEnabled: true,
                  padding: EdgeInsets.only(
                    top: screenSize.height * 0.1,
                    bottom: screenSize.height * 0.2 - 20,
                  ),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  onMapCreated: (GoogleMapController controller) {
                    _controllerMaps.complete(controller);
                    homeMapController = controller;
                  },
                ),
                Positioned(
                    top: screenSize.height / 2,
                    right: screenSize.width / 2 - 22,
                    child: Image.asset(
                      "assets/images/pickupmarker.png",
                      height: 36,
                    )),
                Positioned(
                  bottom: 0.0,
                  child: AnimatedContainer(
                    width: screenSize.width,
                    height: animatedContainer,
                    duration: 300.milliseconds,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: InkWell(
                            onTap: () {
                              animatedContainer = screenSize.height * 0.9 - 20;

                              isFocused = true;
                              isContainerOpen = true;
                              setState(() {});
                            },
                            child: Container(
                              padding: EdgeInsets.fromLTRB(
                                  screenSize.width * 0.03,
                                  screenSize.width * 0.01,
                                  screenSize.width * 0.03,
                                  screenSize.width * 0.01),
                              height: screenSize.width * 0.11,
                              width: screenSize.width * 0.9,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey.withOpacity(0.5),
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(
                                    screenSize.width * 0.035),
                                // color: Colors.grey.withOpacity(0.3)
                              ),
                              alignment: Alignment.centerLeft,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    height: screenSize.width * 0.04,
                                    width: screenSize.width * 0.04,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.blue.withOpacity(0.3)),
                                    child: Container(
                                      height: screenSize.width * 0.02,
                                      width: screenSize.width * 0.02,
                                      decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.blue),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: SizedBox(
                                      width: 200,
                                      child: isContainerOpen
                                          ? TextFormField(
                                              autofocus: isFocused,
                                              decoration: InputDecoration(
                                                contentPadding:
                                                    // //  (languageDirection == 'rtl')
                                                    //      // ? EdgeInsets.only(bottom: screenSize.width * 0.035)
                                                    //   //    :
                                                    EdgeInsets.only(
                                                        bottom:
                                                            screenSize.width *
                                                                0.035),
                                                border: InputBorder.none,
                                                hintText: dropOffString,
                                              ),
                                              maxLines: 1,
                                              onChanged: (val) {
                                               locationBloc.add(FindPlaces(msg: val));
                                              })
                                          : Container(
                                              child: Text(dropOffString),
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        BlocBuilder<LocationBloc, LocationBlocState>(
                          builder: (context, state) {
                            if (state is LoadingState) {
                              return const CircularProgressIndicator();
                            } else if (state is LoadedState) {
                              return Text(state.location.latitude.toString());
                            } else {
                              return CircularProgressIndicator(
                                color: Colors.redAccent,
                              );
                            }
                          },
                        ),
                      BlocBuilder(builder: (context , state){
                        if (state is LoadingState) {
                          return const CircularProgressIndicator();
                        } else if (state is FindPlaces) {
                          return       Expanded(
                            child: Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: 8.0,
                                  horizontal: 16.0,
                                ),
                                child: ListView.separated(
                                  padding: EdgeInsets.all(0.0),
                                  itemBuilder: (context, index) => PredictionTile(
                                    placePredictions: locationBloc.placePredictionList[index],
                                  ),
                                  itemCount: locationBloc.placePredictionList.length,
                                  separatorBuilder: (BuildContext context, index) =>
                                      DividerWidget(),
                                  shrinkWrap: true,
                                  physics: ClampingScrollPhysics(),
                                )),
                          );
                        } else {
                          return CircularProgressIndicator(
                            color: Colors.redAccent,
                          );
                        }
                      },

                      ),
                      ElevatedButton(onPressed: (){
                        locationBloc.add(GetCurrentLocation());
                      }, child: Text("B1")),
                        SizedBox(
                          width: 100,
                          child: ListTile(
                            leading: GetBuilder<LangController>(
                              init: LangController(),
                              builder: (controller) => DropdownButton(
                                iconSize: 38,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.blue[900],
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    child: Text('EN'),
                                    value: 'en',
                                  ),
                                  DropdownMenuItem(
                                    child: Text('AR'),
                                    value: 'ar',
                                  ),
                                  // DropdownMenuItem(child: Text('HI'),value: 'hi',)
                                ],
                                value: controller.appLocal,
                                onChanged: (val) async {
                                  print(val.toString());
                                  controller.changeLang(val.toString());
                                  Get.updateLocale(Locale(val.toString()));
                                  controller.changeDIR(val.toString());
                                  print(Get.deviceLocale);
                                  print(Get.locale);
                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();

                                  await prefs.setString('lang', val.toString());
                                },
                              ),
                            ),
                            onTap: () {},
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

bool pickUpFilling = false;
TextEditingController pickUpController = TextEditingController();

TextEditingController dropOffController = TextEditingController();

class PredictionTile extends StatelessWidget {
  final PlaceShort? placePredictions;

  PredictionTile({Key? key, this.placePredictions}) : super(key: key);

  @override
  Widget build(BuildContext context) {


    return InkWell(
      onTap: () {
        Address address = Address(
          placeName: placePredictions!.mainText,
        );

        if (placePredictions!.placeId == '0') {
          // initialPoint.latitude = locationController.currentLocation.value.latitude;
          // initialPoint.longitude = locationController.currentLocation.value.longitude;
          // locationController.buttonString.value = 'confirm_drop_off_spot_txt'.tr;
          // locationController.startAddingDropOff.value = true;
          // locationController.startAddingPickUpStatus(false);
          // locationController.startAddingDropOffStatus(true);

         // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => Map()), (route) => false);
        } else {
          getPlaceAddressDetails(placePredictions!.placeId!, context);
          //print(placePredictions!.placeId);

          // initialPoint.latitude = placePredictions!.lat!;
          // initialPoint.longitude = placePredictions!.lng!;
          // locationController.showPinOnMap.value = true;

          if (pickUpFilling == false) {

            locati.buttonString.value = 'confirm_drop_off_spot_txt'.tr;
            locationController.updatePickUpLocationAddress(address);

            trip.endPointAddress =
            "${placePredictions!.mainText!} ,${placePredictions!.secondText!}";
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => Map()),
                    (route) => false);
          } else {
            locationController.updateDropOffLocationAddress(address);
            locationController.buttonString.value = 'confirm_pick_up_spot_txt'.tr;

            trip.startPointAddress =
            "${placePredictions!.mainText!} ,${placePredictions!.secondText!}";
            locationController.changePickUpAddress(
                "${placePredictions!.mainText!} ,${placePredictions!.secondText!}");
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => Map()),
                    (route) => false);
          }
        }

      },
      child: Container(
        child: Column(
          children: [
            SizedBox(
              width: 10.0,
            ),
            Row(
              children: [
                Icon(Icons.add_location),
                SizedBox(
                  width: 14.0,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        placePredictions!.mainText!,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 16.0),
                      ),
                      SizedBox(height: 4.0),
                      Text(
                        placePredictions!.secondText!,
                        overflow: TextOverflow.ellipsis,
                        style:
                        TextStyle(fontSize: 12.0, color: Colors.grey[600]),
                      ),
                      SizedBox(
                        height: 8,
                      )
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              width: 14.0,
            ),
          ],
        ),
      ),
    );
  }

  void getPlaceAddressDetails(String placeId, context) async {
    final LocationController locationController = Get.find();
    final RouteMapController routeMapController = Get.find();

    showDialog(
        context: context,
        builder: (BuildContext context) => ProgressDialog(
          message: "Setting DropOff , Please wait ...",
        ));

    String placeDetailsURL =
        "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$mapKey";

    var res = await RequestAssistant.getRequest(placeDetailsURL);

    if (res == "failed") {
      return;
    }

    if (res["status"] == "OK") {
      Address address = Address();

      address.placeName = res["result"]["name"];
      address.placeId = placeId;
      address.latitude = res["result"]["geometry"]["location"]["lat"];
      address.longitude = res["result"]["geometry"]["location"]["lng"];

      // initialPoint.latitude = address.latitude!;
      // initialPoint.longitude = address.longitude!;
      locationController.updateDropOffLocationAddress(address);

      locationController.positionFromPin.value = Position(
        longitude:address.longitude!,
        latitude: address.latitude!,
        speedAccuracy: 1.0,
        altitude:  address.latitude!,
        speed: 1.0,
        heading: 1.0,
        timestamp: DateTime.now(),
        accuracy: 1.0,
      );
      print("this drop off location :: ${address.placeName}");
      print(
          "this drop off location :: lat ${address.latitude} ,long ${address.longitude}");
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (context) => Map()), (route) => false);
    }
  }
}