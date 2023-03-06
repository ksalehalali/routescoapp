import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:http/http.dart' as http;

import '../../Assistants/globals.dart';
import '../../presentation/Auth/login.dart';

class ResetPasswordController extends GetxController {
  final codeController = new TextEditingController();
  final passwordController = new TextEditingController();
  final passwordConfirmController = new TextEditingController();

  int endTime = DateTime.now().millisecondsSinceEpoch + 1000 * 120;




  Future<void> resetPassword(phoneNum , String code) async{
    var head = {
      "Accept": "application/json",
      "content-type":"application/json"
    };

    if (code.isEmpty || passwordController.text.isEmpty ||  passwordConfirmController.text.isEmpty ) {
      Fluttertoast.showToast(
          msg: "Please fill all the required information",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.white70,
          textColor: Colors.black,
          fontSize: 16.0);
    } else if(passwordController.text != passwordConfirmController.text) {
      Fluttertoast.showToast(
          msg: "Passwords do not match",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.white70,
          textColor: Colors.black,
          fontSize: 16.0);
    } else {
      var response = await http.post(Uri.parse(baseURL + "/api/EditePassword"), body: jsonEncode(
        {
          "UserName": "${phoneNum}",
          "Code": code,
          "Password": "${passwordController.text}",
        },
      ), headers: head
      ).timeout(const Duration(seconds: 20), onTimeout:() {
        Fluttertoast.showToast(
            msg: "The connection has timed out, Please try again!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.white70,
            textColor: Colors.black,
            fontSize: 16.0
        );
        throw TimeoutException('The connection has timed out, Please try again!');
      });
      if(response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        if(jsonResponse["status"]){
          codeController.clear();
          passwordController.clear();
          passwordConfirmController.clear();
          codeController.clear();

          Get.to(LoginScreen());
          Fluttertoast.showToast(
              msg: "Done!",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.white70,
              textColor: Colors.black,
              fontSize: 16.0);
        } else{
          Fluttertoast.showToast(
              msg: "${jsonResponse["description"]}",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.white70,
              textColor: Colors.black,
              fontSize: 16.0);
        }
      }
    }
  }


}
