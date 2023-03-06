import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import '../../Assistants/globals.dart';
import '../../Assistants/request-assistant.dart';
import '../../business_logic/controllers/location_controller.dart';
import '../../constants/current_data.dart';
import '../../constants/strings.dart';
import '../../data/models/address.dart';
import '../../data/models/place_short.dart';
import '../screens/home/home_screen.dart';
import 'dialogs.dart';

class PredictionTile extends StatelessWidget {
  final PlaceShort? placePredictions;

  PredictionTile({Key? key, this.placePredictions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final LocationController locationController = Get.find();

    return InkWell(
      onTap: () {
        Address address = Address(
          placeName: placePredictions!.mainText,
        );
        locationController.isContainerOpen.value =false;
        locationController.animatedContainer.value = 120.0;

        if (placePredictions!.placeId == '0') {
          initialPoint.latitude = locationController.currentLocation.value.latitude;
          initialPoint.longitude = locationController.currentLocation.value.longitude;
          locationController.buttonString.value = 'confirm_drop_off_spot_txt'.tr;
          locationController.startAddingDropOff.value = true;
          locationController.startAddingPickUpStatus(false);
          locationController.startAddingDropOffStatus(true);


        } else {
          getPlaceAddressDetails(placePredictions!.placeId!, context);
          //print(placePredictions!.placeId);

          initialPoint.latitude = placePredictions!.lat!;
          initialPoint.longitude = placePredictions!.lng!;
          locationController.showPinOnMap.value = true;

          if (pickUpFilling == false) {

            locationController.buttonString.value = 'confirm_drop_off_spot_txt'.tr;
            locationController.updatePickUpLocationAddress(address);

            trip.endPointAddress =
            "${placePredictions!.mainText!} ,${placePredictions!.secondText!}";


            ///
            // Navigator.pushAndRemoveUntil(
            //     context,
            //     MaterialPageRoute(builder: (context) => Map()),
            //         (route) => false);
          } else {
            locationController.updateDropOffLocationAddress(address);
            locationController.buttonString.value = 'confirm_pick_up_spot_txt'.tr;

            trip.startPointAddress =
            "${placePredictions!.mainText!} ,${placePredictions!.secondText!}";
            locationController.changePickUpAddress(
                "${placePredictions!.mainText!} ,${placePredictions!.secondText!}");

            ///
            // Navigator.pushAndRemoveUntil(
            //     context,
            //     MaterialPageRoute(builder: (context) => Map()),
            //         (route) => false);
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

      initialPoint.latitude = address.latitude!;
      initialPoint.longitude = address.longitude!;
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

      ///
      // Navigator.pushAndRemoveUntil(context,
      //     MaterialPageRoute(builder: (context) => Map()), (route) => false);
    }
  }
}
