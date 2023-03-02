import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'internet_event.dart';
import 'internet_state.dart';

class InternetBloc extends Bloc<InternetEvent , InternetState>{
  StreamSubscription? subscription;
  InternetBloc() :super (InitialState()){
    on<OnConnected>((event , emit)=>emit(Connected(msg: "Connected...")));
    on<OnNotConnected>((event , emit)=>emit(Connected(msg: "Not Connected...")));

    subscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if(result == ConnectivityResult.wifi || result == ConnectivityResult.mobile){
        add(OnConnected());
      }else{
        add(OnNotConnected());
      }
    });
  }

  @override
  Future<void> close() {
    // TODO: implement close
    subscription?.cancel();

    return super.close();
  }
}