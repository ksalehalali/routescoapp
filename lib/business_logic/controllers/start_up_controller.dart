
import 'dart:async';

import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Assistants/globals.dart';
import '../../presentation/Auth/login.dart';
import 'login_controller.dart';

class StartUpController extends GetxController {

  final loginController = Get.put(LoginController());
  var promoterId ="".obs;
  var isConnected = false.obs;



  @override
  void onInit()async {
    // TODO: implement onInit
    super.onInit();
   // fetchUserLoginPreference();
  }

  Future saveInstallationForPromoters(String promoterIdN) async {

    print('from url =............== $promoterIdN');
    promoterId.value = promoterIdN;

  }
  Future<void> fetchUserLoginPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? prefToken = prefs.getString('lastToken');
    String? prefUsername = prefs.getString('userName');
    String? prefPassword = prefs.getString('password');

    print("last token ::: ${prefToken}");
    if(prefToken == null){
      print('null');
      Get.to(LoginScreen());
    } else {
      token = prefToken;
      await loginController.makeAutoLoginRequest(prefUsername, prefPassword);
//      Get.to(MainScreen(indexOfScreen: 0,));
    }

  }

}