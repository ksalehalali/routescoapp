import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';

import '../../Assistants/globals.dart';
import '../../constants/current_data.dart';
import '../../presentation/Auth/confirm_otp.dart';
import '../../presentation/Auth/login.dart';
import '../../presentation/screens/home/home_screen.dart';


class LoginController extends GetxController {
  var isLoginLoading = false.obs;
  var loginIcon = new Container(
      child: Icon(
    Icons.arrow_forward,
  )).obs;

  final usernameController = new TextEditingController();
  final passwordController = new TextEditingController();
  RxString phoneNum = "".obs;
  late AndroidDeviceInfo androidInfo;

  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  IosDeviceInfo? iosInfo;

  @override
  void onInit() async {
    // TODO: implement onInit
    super.onInit();
    getUserLoginPreference();
  }

  @override
  void onClose() {
    super.onClose();
    usernameController.dispose();
    passwordController.dispose();
  }

  Future<bool> isConnected() async {
    bool connected = false;
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      // I am connected to a mobile network.
      user.isConnected = true;
      print('mobile.......');
      connected = true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      // I am connected to a wifi network.
      user.isConnected = true;

      print('wifi.......');
      connected = true;
    } else if (connectivityResult == ConnectivityResult.none) {
      // I am connected to a wifi network.
      print('none.......');
      connected = false;
      user.isConnected = false;
      isLoginLoading.value = false;
    }
    return connected;
  }

  //logout
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastToken', prefs.getString('token')!);
    await prefs.setString('lastPhone', prefs.getString('phoneNumber')!);

    isLoginLoading.value = false;
    user.accessToken = '';
    prefs.remove('token');
    prefs.remove('lastToken');
    prefs.remove('id');
    isLoginLoading.value = false;

    prefs.remove('phoneNumber');

    Get.offAll(() => LoginScreen());
  }

  //login
  Future<void> makeLoginRequest(BuildContext context) async {

    if (Platform.isAndroid) {
      androidInfo = await deviceInfo.androidInfo;

    } else if(Platform.isIOS) {
      iosInfo = await deviceInfo.iosInfo;
    }
//  isLoginLoading.value = true;
    final fcmToken = await FirebaseMessaging.instance.getToken();
    print(" 0000000000 FCM token: " + fcmToken!);
    loginIcon.value = Container(
      child: CircularProgressIndicator(),
    );

    List<String> loginCredentials = [
      phoneNum.value.replaceAll("+", ""),
      passwordController.text
    ];

    print("IIIINNNFFFOOO ${loginCredentials[0]} : ${loginCredentials[1]}");

    var head = {
      "Accept": "application/json",
      "content-type": "application/json"
    };

    if (loginCredentials[0].isEmpty || loginCredentials[1].isEmpty) {
      Fluttertoast.showToast(
          msg: "Please fill all the required information",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.white70,
          textColor: Colors.black,
          fontSize: 16.0);
      isLoginLoading.value = false;
    } else {
      print(
          "login info ==-- ${loginCredentials[0]} -- ${loginCredentials[1]}  FCMToken: $fcmToken device id ${iosInfo?.utsname.nodename}");
      print(
          "device info.......  ${Platform.isAndroid == true ? androidInfo.id : iosInfo?.identifierForVendor}");

      var response = await http
          .post(Uri.parse(baseURL + "/api/Login"),
              body: jsonEncode(
                {
                  "UserName": loginCredentials[0],
                  "Password": loginCredentials[1],
                  "FCMToken": fcmToken,
                  "UnicNumber": Platform.isAndroid == true
                      ? androidInfo.id
                      : iosInfo?.identifierForVendor
                },
              ),
              headers: head)
          .timeout(const Duration(seconds: 12), onTimeout: () {
        Fluttertoast.showToast(
            msg: "The connection has timed out, Please try again!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.white70,
            textColor: Colors.black,
            fontSize: 16.0);
        isLoginLoading.value = false;
       // Get.offAll(() => Login());
        print("Time out ---.........");

        throw TimeoutException(
            'The connection has timed out, Please try again!');
      });
      print(response.body);
      if (response.statusCode == 500) {
        Fluttertoast.showToast(
            msg: "Error 500",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.white70,
            textColor: Colors.black,
            fontSize: 16.0);
        isLoginLoading.value = false;
      } else if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        print('user info ::====::: $jsonResponse');
        if (jsonResponse["status"]) {
          print(jsonResponse["description"]);
          print('==================================');
          print("my new token is ::: ${jsonResponse["description"]['token']}");
          user.id = jsonResponse["description"]['id'];
          // TODO: store token in shared preferences then navigate to the following screen
          storeUserLoginPreference(
              jsonResponse["description"]["token"],
              jsonResponse["description"]["userName"],
              loginCredentials[1],
              jsonResponse["description"]["id"],
              jsonResponse["description"]["phoneNumber"],
              jsonResponse["description"]["guidUser"]);
          user.accessToken = jsonResponse["description"]["token"];
          Get.offAll(HomeScreen());
          phoneNum.value = "";

          passwordController.text = "";
        } else if (jsonResponse.toString().contains('You can\'t use more than one device')) {
          showCupertinoDialog<String>(
            context: context,
            builder: (BuildContext context) => CupertinoAlertDialog(
              title: Text('Add new device'.tr),
              content:
                  Text('You need to add this device and delete old one'.tr),
              actions: <Widget>[
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context, 'Confirm_txt'.tr);
                  },
                  child: Text('Close_txt'.tr),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context, 'Confirm_txt'.tr);
                    print("User =============================== ${loginCredentials[0]}");
                    resetDevice(loginCredentials[0], loginCredentials[1], context);
                    //notify the user account deleted
                    CupertinoAlertDialog(
                      title: const Text('Account deleted'),
                      content: const Text('Your account deleted'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () async {
                            Navigator.pop(context, 'Ok');
                          },
                          child: const Text('Ok'),
                        ),
                      ],
                    );
                  },
                  child: Text('Confirm_txt'.tr),
                ),
              ],
            ),
          );
        } else {
          Fluttertoast.showToast(
              msg: "Username and password do not match!",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.white70,
              textColor: Colors.black,
              fontSize: 16.0);
        }
        isLoginLoading.value = false;
      }
    }
    loginIcon.value = Container(
      child: Icon(
        Icons.arrow_forward,
      ),
    );

//    isLoginLoading.value = false;
  }

  Future<void> makeAutoLoginRequest(username, password) async {
    if (Platform.isAndroid) {
      androidInfo = await deviceInfo.androidInfo;

    } else if(Platform.isIOS) {
      iosInfo = await deviceInfo.iosInfo;
    }
    final fcmToken = await FirebaseMessaging.instance.getToken();
    print(" 0000000000 FCM token1: auto" + fcmToken!);

    var head = {
      "Accept": "application/json",
      "content-type": "application/json"
    };
print("device ${Platform.isAndroid == true
    ? androidInfo.id
    : iosInfo?.identifierForVendor} ........................................................");
    var response = await http
        .post(Uri.parse(baseURL + "/api/Login"),
            body: jsonEncode(
              {
                "UserName": username,
                "Password": password,
                "FCMToken": fcmToken,
                "UnicNumber": Platform.isAndroid == true
                    ? androidInfo.id
                    : iosInfo?.identifierForVendor
              },
            ),
            headers: head)
        .timeout(const Duration(seconds: 10), onTimeout: () {
      Fluttertoast.showToast(
          msg: "The connection has timed out, Please try again!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.white70,
          textColor: Colors.black,
          fontSize: 16.0);
      isLoginLoading.value = false;

      Get.offAll(() => LoginScreen());

      throw TimeoutException('The connection has timed out, Please try again!');
    });
    var jsonResponse = json.decode(response.body);

    if (response.statusCode == 500) {
      Fluttertoast.showToast(
          msg: "Error 500",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.white70,
          textColor: Colors.black,
          fontSize: 16.0);
      isLoginLoading.value = false;

      Get.to(() => LoginScreen());
    } else if (response.statusCode == 200) {
      print('user info ::==auto login==::: $jsonResponse');

      if (jsonResponse["status"]) {
        print('===================true==================');
        user.id = jsonResponse["description"]['id'];
        // TODO: store token in shared preferences then navigate to the following screen
        storeUserLoginPreference(
            jsonResponse["description"]["token"],
            jsonResponse["description"]["userName"],
            password,
            jsonResponse["description"]["id"],
            jsonResponse["description"]["phoneNumber"],
            jsonResponse["description"]["guidUser"]);
        user.accessToken = jsonResponse["description"]["token"];
        user.name = jsonResponse["description"]["name"];
        user.phone = jsonResponse["description"]["phoneNumber"];
        print("new token  ${jsonResponse["description"]["token"]}");

        //call func to save installation
        //if(promoterId!="")saveInstallationForPromoters(promoterId);

        Timer(const Duration(milliseconds: 200), () {

          ///
          Get.to(HomeScreen( ));
        });
      } else {
        Fluttertoast.showToast(
            msg: "Username and password do not match!",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.white70,
            textColor: Colors.black,
            fontSize: 16.0);
        Timer(Duration(milliseconds: 200), () {
          Get.to(() => LoginScreen());
        });
      }
    }
  }

  Future resetDevice(String userName, String password, BuildContext context) async {
    var head = {
      "Accept": "application/json",
      "content-type": "application/json"
    };

    var response = await http.post(Uri.parse(baseURL + "/api/RestUser"),
        body: jsonEncode(
          {
            "UserName": userName,
            "appSignature": Platform.isAndroid == true
                ? androidInfo.id
                : iosInfo?.identifierForVendor
          },
        ),
        headers: head);

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      print('reset info :.....$userName....: $jsonResponse');
      if (jsonResponse["status"]) {
        print(jsonResponse["description"]);
        Get.offAll(()=>ConfirmOTP(userName));

      }
    } else {
      print("User reset info :.....$userName");
      print(response.body);
      print(response.reasonPhrase);
    }
  }

  //
  Future saveInstallationForPromoters(String promoterIdN) async {
    print('from url =............== $promoterIdN');

    var headers = {
      'Authorization': 'bearer ${user.accessToken}',
      'Content-Type': 'application/json'
    };
    var request = http.Request(
        'POST', Uri.parse(baseURL + '/api/AddPromoterInstallation'));
    request.body = json.encode({"PromoterID": promoterIdN});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print('save installation for p done ---');
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }

  Future<void> storeUserLoginPreference(
      token, username, password, id, phone, userGuid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString('token', token);

    await prefs.setString('userName', username);
    await prefs.setString('password', password);
    await prefs.setString('id', id);
    await prefs.setString('phoneNumber', phone);
    await prefs.setString('lastToken', token);
    await prefs.setString('lastPhone', phone);
    await prefs.setString('guidUser', userGuid);
  }

  Future<void> getUserLoginPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    user.name = await prefs.getString('username');
    user.id = await prefs.getString('id');
    user.phone = await prefs.getString('phoneNumber');
  }
}
