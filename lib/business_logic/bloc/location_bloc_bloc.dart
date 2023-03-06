import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:meta/meta.dart';

import '../../data/web_services/location_web_service.dart';

part 'location_bloc_event.dart';
part 'location_bloc_state.dart';

class LocationBloc extends Bloc<LocationBlocEvent, LocationBlocState> {
  LocationWebService locationWebService;
  List placePredictionList = [];
  var buttonString = '';

  LocationBloc({required this.locationWebService}) :super(LoadingState()){
    on<LocationBlocEvent>((event, emit)async{
   if(event is FindPlaces){
     try {
       placePredictionList.clear();
       // final places = await locationWebService.findPlace(event.msg);
       // places.forEach((element) {
       //   placePredictionList.add(PlaceShort(
       //       placeId: element.id,
       //       mainText: element.text,
       //       secondText: element.place_name,
       //       lat: element.lat,
       //       lng: element.lng));
       // });
       print("++++ ${placePredictionList.first.mainText}");
       emit(LoadedState(""));
     }catch (e){
       print("$e");
     }
   }else if( event is GetCurrentLocation){
     // final location = await locationWebService.getLocation();
     // emit(LoadedState(location));
   }
    });
  }
  refreshPlacePredictionList() {
    placePredictionList.clear();
    placePredictionList.add(PlaceShort(
      placeId: '0',
      mainText: 'set_location_on_map_txt'.tr,
      secondText: 'choose_txt'.tr,
    ));
    //getMyFavAddresses();
  }
}
