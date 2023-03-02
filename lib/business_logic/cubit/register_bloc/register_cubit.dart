import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routescoapp/business_logic/cubit/register_bloc/register_event.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';

import '../../../data/web_services/registeration_web_service.dart';
import 'register_state.dart';

class RegistrationBloc extends Bloc<RegisterEvent, RegisterStates> {
  final RegistrationWebService registrationWebService;

  RegistrationBloc(this.registrationWebService) : super(TryingLogin()) {
    var userInfo;

    on<LoadServiceEvent>((event, emit) async {
      emit(TryingLogin());
      print("Registration -----------------------------------------------");
      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();

        String? prefToken = await prefs.getString('lastToken');
        String? prefUsername = await prefs.getString('userName');
        String? prefPassword = await prefs.getString('password');

        //  if(prefToken == null){
        print('null');
        var userInfo = await registrationWebService.makeAutoLoginRequest(
            prefUsername, prefPassword);
        LoggedIn(userInfo);

        // } else {
        //
        // }
      } catch (e) {
        // emit(ServiceErrorState(msg: e.toString()));
      }
    });
  }

  static RegistrationBloc get(BuildContext context) {
    return BlocProvider.of(context);
  }

  var userInfo;

  void login(userName, password) async {
    userInfo =
        await registrationWebService.makeLoginRequest(userName, password);
    emit(LoggedIn(userInfo));
  }
}
