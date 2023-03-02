import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/strings.dart';
import '../../presentation/Auth/login.dart';

class RegistrationWebService {
  var isLoginLoading = false;
  var loginIcon = new Container(
      child: Icon(
    Icons.arrow_forward,
  ));

  final usernameController = new TextEditingController();
  final passwordController = new TextEditingController();
  String phoneNum = "";
  var user;
  late AndroidDeviceInfo androidInfo ;
  late IosDeviceInfo iosInfo;
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  // @override
  // void onInit() {
  //   // TODO: implement onInit
  //   super.onInit();
  //   getUserLoginPreference();
  // }
  // @override
  // void onClose() {
  //   super.onClose();
  //   usernameController.dispose();
  //   passwordController.dispose();
  // }


  //logout
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastToken', prefs.getString('token')!);
    await prefs.setString('lastPhone', prefs.getString('phoneNumber')!);

    isLoginLoading = false;
    user.accessToken = '';
    prefs.remove('token');
    prefs.remove('lastToken');
    prefs.remove('id');
    isLoginLoading = false;

    prefs.remove('phoneNumber');

    Get.offAll(() => Login());
  }

  //login
  Future<Map?> makeLoginRequest(String userName, password) async {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    print(" 0000000000 FCM token: " + fcmToken!);
    androidInfo = await deviceInfo.androidInfo;
    iosInfo = await deviceInfo.iosInfo;

    loginIcon = Container(
      child: CircularProgressIndicator(),
    );


    print("IIIINNNFFFOOO ${userName} : ${password}");

    var head = {
      "Accept": "application/json",
      "content-type": "application/json"
    };

    if (userName.isEmpty || password.isEmpty) {
      Fluttertoast.showToast(
          msg: "Please fill all the required information",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.white70,
          textColor: Colors.black,
          fontSize: 16.0);
      isLoginLoading = false;
      return null;
    } else {
      print("login data --=====$userName--$password-- $fcmToken");
      var response = await http
          .post(Uri.parse("$baseUrl/api/Login"),
              body: jsonEncode(
                {
                  "UserName": userName,
                  "Password": password,
                  "FCMToken": fcmToken,
                  "UnicNumber": Platform.isAndroid ==true ? androidInfo.id :iosInfo.identifierForVendor

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
        isLoginLoading = false;
        Get.offAll(() => Login());
        throw TimeoutException(
            'The connection has timed out, Please try again!');
      });

      print("response --- ${response.body}");
      if (response.statusCode == 500) {
        Fluttertoast.showToast(
            msg: "Error 500",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.white70,
            textColor: Colors.black,
            fontSize: 16.0);
        isLoginLoading = false;
        return null;
      } else if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        print('user info ::====::: $jsonResponse');
        if (jsonResponse["status"]) {
          print(jsonResponse["description"]);
          print('==================================');
          print("my new token is ::: ${jsonResponse["description"]['token']}");

          // TODO: store token in shared preferences then navigate to the following screen
          storeUserLoginPreference(
              jsonResponse["description"]["token"],
              jsonResponse["description"]["userName"],
              password,
              jsonResponse["description"]["id"],
              jsonResponse["description"]["phoneNumber"],
              jsonResponse["description"]["guidUser"]);

          // Get.offAll(MainScreen(indexOfScreen: 0,));
          phoneNum = "";

          passwordController.text = "";
          return jsonResponse["description"];
        } else {
          Fluttertoast.showToast(
              msg: "Username and password do not match!",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.white70,
              textColor: Colors.black,
              fontSize: 16.0);
          return null;
        }
      }
    }
    loginIcon = Container(
      child: Icon(
        Icons.arrow_forward,
      ),
    );

//    isLoginLoading.value = false;
  }

  Future makeAutoLoginRequest(username, password) async {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    print(" 0000000000 FCM token133: " + fcmToken!);

    var head = {
      "Accept": "application/json",
      "content-type": "application/json"
    };

    print("login info auto === $username -- $password -- $fcmToken");
    var response = await http.post(Uri.parse("$baseUrl/api/Login"),
            body: jsonEncode(
              {
                "UserName": username,
                "Password": password,
                "FCMToken": fcmToken,
                "UnicNumber": Platform.isAndroid ==true ? androidInfo.id :iosInfo.identifierForVendor

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
      isLoginLoading = false;

      Get.offAll(() => Login());

      throw TimeoutException('The connection has timed out, Please try again!');
    });
    var jsonResponse = json.decode(response.body);
    print(response);

    if (response.statusCode == 500) {
      Fluttertoast.showToast(
          msg: "Error 500",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.white70,
          textColor: Colors.black,
          fontSize: 16.0);
      isLoginLoading = false;
      Get.to(() => Login());
      return null;
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
          return jsonResponse["description"];

          /// Get.to(MainScreen(indexOfScreen: 0,));
        });
      } else {
        print(response);

        Fluttertoast.showToast(
            msg: "Username and password do not match!",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.white70,
            textColor: Colors.black,
            fontSize: 16.0);
        Timer(Duration(milliseconds: 200), () {
          Get.to(() => Login());
        });
        return null;
      }
    }else{
      print(response);
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
        'POST', Uri.parse(baseUrl + '/api/AddPromoterInstallation'));
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

  Future tryToAutoLogin(userName, password) async {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    print(" 0000000000 FCM token1: " + fcmToken!);

    var head = {
      "Accept": "application/json",
      "content-type": "application/json"
    };

    var response = await http
        .post(Uri.parse("$baseUrl/api/Login"),
            body: jsonEncode(
              {
                "UserName": userName,
                "Password": password,
                "FCMToken": fcmToken
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
      isLoginLoading = false;

      Get.offAll(() => Login());

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
      isLoginLoading = false;

      Get.to(() => Login());
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
        return Timer(const Duration(milliseconds: 200), () {
          // Get.to(MainScreen(indexOfScreen: 0,));
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
          Get.to(() => Login());
        });
      }
    }
  }
}
