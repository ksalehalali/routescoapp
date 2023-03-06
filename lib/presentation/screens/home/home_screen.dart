import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../Assistants/assistantMethods.dart';
import '../../../Assistants/globals.dart';
import '../../../business_logic/controllers/location_controller.dart';
import '../../../business_logic/cubit/internet_bloc/internet_bloc.dart';
import '../../../business_logic/cubit/internet_bloc/internet_state.dart';
import '../../../business_logic/bloc/location_bloc_bloc.dart';
import '../../../constants/current_data.dart';
import '../../../constants/strings.dart';
import '../../../data/models/address.dart';
import '../../../data/models/place_short.dart';
import '../../../data/web_services/request-assistant.dart';
import '../../widgets/dialogs.dart';
import '../../widgets/divider.dart';
import '../../widgets/prediction_tile.dart';

class HomeScreen extends StatefulWidget {
  static const String idScreen = "HomeScreen";
  HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
bool pickUpFilling = false;
TextEditingController pickUpController = TextEditingController();

TextEditingController dropOffController = TextEditingController();
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

  String dropOffString = "Enter 3 letters to search";
  bool isFocused = false;
  bool isFocused2 = false;
  var assistantMethods = AssistantMethods();

  bool pickUpFilling = false;
  FocusNode? focusNodePickUp;
  FocusNode? focusNodeDropOff;
  final LocationController locationController = Get.find();

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
  }
  start()async{
    Timer(Duration(milliseconds: 100), () {
      locationController.refreshPlacePredictionList();
      focusNodeDropOff = FocusNode();
      focusNodePickUp = FocusNode();
      if(locationController.addDropOff.value ==true){
        dropOffController.text = locationController.dropOffAddress.value;
      }else if(locationController.addPickUp.value == true){
        pickUpController.text = locationController.pickUpAddress.value;
      }else{
        pickUpController.text = '';
        dropOffController.text = '';
      }
    });
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
                          locationController.animatedContainer.value = 120;
                          locationController.isContainerOpen.value = false;
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
          body:  Stack(
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
                  onCameraIdle: ()async{
                    print('onCameraIdle');
                    locationController.showPinOnMap.value = true;
                    locationController.addressText.value = await assistantMethods.searchCoordinateAddress(
                        locationController.positionFromPin.value, false);
                    if (locationController.addDropOff.value == true &&
                        locationController.addPickUp.value == true) {

                    } else {
                      if (locationController.startAddingPickUp.value == true) {
                        trip.startPointAddress =  locationController.addressText.value;

                      } else {
                        trip.endPointAddress =  locationController.addressText.value;

                      }
                    }
                    locationController.startMovingCamera.value = false;
                    locationController.stopMovingCamera.value = true;


                  },
                  onCameraMove: (camera){
                    locationController.showPinOnMap.value = false;
                    locationController.updatePinPos(
                        camera.target.latitude, camera.target.longitude);
                    locationController.positionFromPin.value = Position(
                      longitude: camera.target.longitude,
                      latitude: camera.target.latitude,
                      speedAccuracy: 1.0,
                      altitude: camera.target.latitude,
                      speed: 1.0,
                      heading: 1.0,
                      timestamp: DateTime.now(),
                      accuracy: 1.0,
                    );
                  },
                  onCameraMoveStarted: (){
                    locationController.startMovingCamera.value = true;
                    locationController.stopMovingCamera.value = false;

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
                    top:5,
                    right: 5,
                    left: 5,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Container(
                          width: screenSize.width,
                          height: screenSize.height *0.1 -36,
                          decoration:BoxDecoration(
                            color:Colors.white,
                            borderRadius: BorderRadius.circular(3)
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Obx(()=> Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Text(locationController.addressText.value,maxLines: 1,overflow:TextOverflow.ellipsis ,textAlign: TextAlign.right,textDirection: TextDirection.ltr,),
                            )),
                          ),
                        ),
                      ),
                    )),
                Positioned(
                  bottom: 0.0,
                  child: Obx(()=>AnimatedContainer(
                      width: screenSize.width,
                      height: locationController.animatedContainer.value,
                      duration: 300.milliseconds,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                      ),
                      child: Column(
                        children: [

                          Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: InkWell(
                              onTap: () {
                                locationController.animatedContainer.value = screenSize.height * 0.9 - 20;
                                setState(() {});
                                start();

                                Timer(700.milliseconds, () {
                                  isFocused2 = true;
                                  locationController.isContainerOpen.value = true;
                                  setState(() {});
                                });
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
                                        child: locationController.isContainerOpen.value
                                            ? TextFormField(
                                                autofocus: isFocused,
                                                decoration: InputDecoration(
                                                  contentPadding:
                                                      // //  (languageDirection == 'rtl')
                                                      //      // ? EdgeInsets.only(bottom: screenSize.width * 0.035)
                                                      //   //    :
                                                      EdgeInsets.only(
                                                          bottom: screenSize.width * 0.012),
                                                  border: InputBorder.none,
                                                  hintText:  locationController
                                                      .gotMyLocation.value ==
                                                      true
                                                      ? locationController.pickUpAddress.value
                                                      : 'loading..._txt'.tr,
                                                  hintStyle: TextStyle(
                                                      overflow: TextOverflow.ellipsis,

                                                      color: locationController.gotMyLocation.value == true
                                                          ? Colors.blue[900] : Colors.red),

                                                  isDense: true,
                                                ),
                                                maxLines: 1,
                                                onChanged: (val) {
                                                  if(val.length ==0)  locationController.refreshPlacePredictionList();
                                                  locationController.startAddingPickUpStatus(true);
                                                  locationController.startAddingDropOffStatus(false);
                                                  pickUpFilling = true;
                                                  locationController.findPlace(val);
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
                          SizedBox(height:12),
                          locationController.isContainerOpen.value ==false ?
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  InkWell(
                                    onTap: (){
                                      print("PICKUP NOW");
                                    },
                                    child: Container(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text("PICKUP NOW",style: TextStyle(fontSize: 14),),
                                      )
                                    ),
                                  ),
                                  Container(
                                    height:screenSize.height *0.1 -44,
                                    width: 2,
                                    color: Colors.grey,
                                  ),
                                  InkWell(
                                    onTap: (){
                                      print("PICKUP LATER");
                                    },
                                    child: Container(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text("PICKUP LATER",style: TextStyle(fontSize: 14),),
                                        )
                                    ),
                                  )
                                ],
                              ):Container(),
                          locationController.isContainerOpen.value
                        ?   Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: InkWell(
                              onTap: () {
                                locationController.animatedContainer.value = screenSize.height * 0.9 - 20;

                                isFocused = true;
                                locationController.isContainerOpen.value = true;
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
                                          color: Colors.red.withOpacity(0.3)),
                                      child: Container(
                                        height: screenSize.width * 0.02,
                                        width: screenSize.width * 0.02,
                                        decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.red),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: SizedBox(
                                        width: 200,
                                        child:TextFormField(
                                            autofocus: isFocused2,
                                            decoration: InputDecoration(
                                              contentPadding:
                                              // //  (languageDirection == 'rtl')
                                              //      // ? EdgeInsets.only(bottom: screenSize.width * 0.035)
                                              //   //    :
                                              EdgeInsets.only(
                                                  bottom:
                                                  screenSize.width *
                                                      0.012),
                                              border: InputBorder.none,
                                              hintText: "where_To?_txt".tr,

                                              hintStyle: TextStyle(
                                                  overflow: TextOverflow.ellipsis,
                                                  color: locationController
                                                      .gotMyLocation.value ==
                                                      true
                                                      ? Colors.blue[900]
                                                      : Colors.red),

                                              filled: false,
                                              isDense: true,

                                            ),

                                            maxLines: 1,
                                            onChanged: (val) {
                                              if(val.length ==0)  locationController.refreshPlacePredictionList();
                                              locationController.startAddingPickUpStatus(true);
                                              locationController.startAddingDropOffStatus(false);
                                              pickUpFilling = true;
                                              locationController.findPlace(val);
                                            },
                                        onTap: (){
                                          pickUpFilling = true;
                                          locationController.startAddingPickUpStatus(true);
                                          locationController.startAddingDropOffStatus(false);
                                        },
                                          onFieldSubmitted: (val) {
                                            FocusScope.of(context)
                                                .requestFocus(focusNodeDropOff);
                                          },
                                        )

                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ) : Container(
                    ),
                          SizedBox(
                            height: 3,
                          ),
                          //tile for predictions
                          locationController.isContainerOpen.value? Obx(() {
                            return Expanded(
                              child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 8.0,
                                    horizontal: 16.0,
                                  ),
                                  child: ListView.separated(
                                    padding: EdgeInsets.all(0.0),
                                    itemBuilder: (context, index) => PredictionTile(
                                      placePredictions:
                                      locationController.placePredictionList[index],
                                    ),
                                    itemCount: locationController.placePredictionList.length,
                                    separatorBuilder: (BuildContext context, index) =>
                                        DividerWidget(),
                                    shrinkWrap: true,
                                    physics: ClampingScrollPhysics(),
                                  )),
                            );
                          }):Container()
                        //   BlocBuilder<LocationBloc, LocationBlocState>(
                        //     builder: (context, state) {
                        //       if (state is LoadingState) {
                        //         return const CircularProgressIndicator();
                        //       } else if (state is LoadedState) {
                        //         return Text(state.location.latitude.toString());
                        //       } else {
                        //         return CircularProgressIndicator(
                        //           color: Colors.redAccent,
                        //         );
                        //       }
                        //     },
                        //   ),
                        //
                        // ElevatedButton(onPressed: (){
                        //   locationBloc.add(GetCurrentLocation());
                        // }, child: Text("B1")),
                        //   SizedBox(
                        //     width: 100,
                        //     child: ListTile(
                        //       leading: GetBuilder<LangController>(
                        //         init: LangController(),
                        //         builder: (controller) => DropdownButton(
                        //           iconSize: 38,
                        //           style: TextStyle(
                        //             fontSize: 18,
                        //             color: Colors.blue[900],
                        //           ),
                        //           items: const [
                        //             DropdownMenuItem(
                        //               child: Text('EN'),
                        //               value: 'en',
                        //             ),
                        //             DropdownMenuItem(
                        //               child: Text('AR'),
                        //               value: 'ar',
                        //             ),
                        //             // DropdownMenuItem(child: Text('HI'),value: 'hi',)
                        //           ],
                        //           value: controller.appLocal,
                        //           onChanged: (val) async {
                        //             print(val.toString());
                        //             controller.changeLang(val.toString());
                        //             Get.updateLocale(Locale(val.toString()));
                        //             controller.changeDIR(val.toString());
                        //             print(Get.deviceLocale);
                        //             print(Get.locale);
                        //             SharedPreferences prefs =
                        //                 await SharedPreferences.getInstance();
                        //
                        //             await prefs.setString('lang', val.toString());
                        //           },
                        //         ),
                        //       ),
                        //       onTap: () {},
                        //     ),
                        //   ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

    );
  }
}



