import 'dart:io';
import 'dart:math';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:routescoapp/presentation/Auth/sign_up.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../Assistants/globals.dart';
import '../../business_logic/controllers/login_controller.dart';
import '../../business_logic/controllers/profile_pic_controller.dart';
import '../../business_logic/controllers/sign_up_controller.dart';
import '../../business_logic/controllers/start_up_controller.dart';
import '../../business_logic/cubit/internet_bloc/internet_bloc.dart';
import '../../business_logic/cubit/internet_bloc/internet_state.dart';
import 'confirm_number.dart';


class LoginScreen extends StatefulWidget {
  static const String idScreen = "LoginScreen";

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final profilePicController = Get.put(ProfilePicController());
  final LoginController loginController =  Get.find();
  final SignUpController signUpController= Get.find();
  final startUpController = Get.put(StartUpController());

  bool chooseCamera = false;
  PhoneNumber number = PhoneNumber(isoCode: 'KW');
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  IosDeviceInfo? iosInfo;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    //time
    print(DateFormat('yyyy-MM-dd-HH:mm-ss').format(DateTime.now()));


    return BlocListener<InternetBloc, InternetState>(
        listener: (context, state) {
      if (state is Connected) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
          Text(state.msg, style: TextStyle(color: Colors.white)),
          duration: Duration(seconds: 1),
          backgroundColor: Colors.green,
        ));
        startUpController.fetchUserLoginPreference();

      } else if (state is NotConnected) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              state.msg,
            )));
      }
    },
    child: Container(
      decoration: BoxDecoration(
        image: DecorationImage(
            image: AssetImage("assets/images/background/WhatsApp Image 2022-10-02 at 12.55.00 PM.jpeg"), fit: BoxFit.cover),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,

        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.35
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Container(
                  margin: EdgeInsets.only(left: 35, right: 35),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // USERNAME TEXT FIELD
                      InkWell(
                        onTap: ()async{
                          iosInfo = await deviceInfo.iosInfo;
                          print(iosInfo?.utsname.nodename);
                          print(iosInfo?.utsname.machine);
                          print(iosInfo?.utsname.release);
                          print(iosInfo?.utsname.sysname);
                          print(iosInfo?.utsname.version);
                          print(iosInfo?.localizedModel);
                          print(iosInfo?.model);
                          print(iosInfo?.systemVersion);

                          print(iosInfo?.identifierForVendor);

                          print(iosInfo?.localizedModel);
                          print(iosInfo?.model);
                          print(iosInfo?.systemVersion);

                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 18.0),
                          child: Text(
                            'Login',
                            style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.w500
                            ),
                          ),
                        ),
                      ),
//                              SizedBox(width: 28,),
                      Container(
                        padding: EdgeInsets.only(left: 8.0),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            width: 1.0,
                          ),
                        ),
                        child: InternationalPhoneNumberInput(
                          onInputChanged: (PhoneNumber number) {
                            print(number.phoneNumber);
                            loginController.phoneNum.value = number.phoneNumber!;
                            signUpController.phoneNum.value = number.phoneNumber!;

                          },
                          onInputValidated: (bool value) {
                            print(value);
                          },
                          selectorConfig: SelectorConfig(
                            selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                          ),
                          maxLength: 8,
                          ignoreBlank: false,
                          autoValidateMode: AutovalidateMode.disabled,
                          selectorTextStyle: TextStyle(color: Colors.black),
                          textStyle: TextStyle(color: Colors.black),
                          inputDecoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.transparent,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.transparent,
                              ),
                            ),
                          ),
                          initialValue: number,
//                            textFieldController: controller,
                          formatInput: false,
                          keyboardType:
                          TextInputType.numberWithOptions(signed: true, decimal: true),
                          inputBorder: OutlineInputBorder(),
                          onSaved: (PhoneNumber number) {
                            print('On Saved: $number');
                          },
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                        // PASSWORD TEXT FIELD
                      TextField(
                        controller: loginController.passwordController,
                        style: TextStyle(),
                        obscureText: true,
                        decoration: InputDecoration(
                          fillColor: Colors.transparent,
                          filled: true,
                          hintText: "Password",
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: routes_color, width: 1.0),
                            borderRadius: BorderRadius.circular(10),
                          ),

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      // LOGIN PROCEED
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [

                          CircleAvatar(
                            radius: 30,
                            backgroundColor: routes_color,
                            child: Obx(() => IconButton(
                                color: Colors.white,
                                onPressed: () async{
                                  //FirebaseDynamicLinkService.createDynamicLink(false, 'user.id');

                                  // TODO: login API
                                 bool connected = await loginController.isConnected();
                                 if (connected) {
                                  validatePassword(loginController.passwordController.text,context);
                                 }else{
                                   _showDialogBoxNoneConnection();
                                 }

                                },
                                icon: !loginController.isLoginLoading.value ?
                                Container(
                                    child: Icon(
                                      Icons.arrow_forward,
                                    )
                                ):
                                Container(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                ),
                                //icon: loginController.loginIcon.value
                            ),
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height:screenSize.height *0.1.h-60,
                      ),

                      // SIGN UP / FORGOT PASSWORD SECTION
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () {

                              Navigator.push(
                                this.context,
                                MaterialPageRoute(builder: (context) => new SignUp()),
                              );
                            },
                            child: Text(
                              'Sign Up',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  color: routes_color,
                                  fontSize: 18),
                            ),
                            style: ButtonStyle(),
                          ),
                          // FORGOT PASSWORD
                          TextButton(
                              onPressed: () {
                                Get.to(ConfirmNumber());
                              },
                              child: Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  color: routes_color,
                                  fontSize: 18,
                                ),
                              )),
                        ],
                      ),
                      SizedBox(
                        height:screenSize.height *0.1.h-20,
                      ),
                      //pay offline button
                      // Align(
                      //   alignment:Alignment.bottomCenter,
                      //   child: OutlinedButton.icon(
                      //     style: ButtonStyle(
                      //       backgroundColor:MaterialStateProperty.all(routes_color.withOpacity(0.9)),
                      //       foregroundColor: MaterialStateProperty.all(Colors.white),
                      //       padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 12.h,horizontal: 16.w)),
                      //
                      //     ) ,
                      //     onPressed: ()async{
                      //       createQRCodeToPay();
                      //         // Fluttertoast.showToast(
                      //         //     msg: "msg_offline".tr,
                      //         //     toastLength: Toast.LENGTH_SHORT,
                      //         //     gravity: ToastGravity.CENTER,
                      //         //     timeInSecForIosWeb: 1,
                      //         //     backgroundColor: Colors.white70,
                      //         //     textColor: Colors.black,
                      //         //     fontSize: 16.0.sp);
                      //
                      //     }, label: Text(
                      //     "Pay offline_btn".tr,
                      //     style: TextStyle(
                      //         fontSize: 13.sp,
                      //         letterSpacing: 0,
                      //         fontWeight: FontWeight.bold
                      //
                      //     ),
                      //   ), icon: Icon(Icons.qr_code), ),
                      // ),

                      SizedBox(
                        height: 30.h,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    ));
  }


  _showDialogBoxNoneConnection() => showCupertinoDialog<String>(
    context: context,
    builder: (BuildContext context) => CupertinoAlertDialog(
      title: const Text('No Connection'),
      content: const Text('Please check your internet connectivity'),
      actions: <Widget>[
        TextButton(
          onPressed: () async {
            Navigator.pop(context, 'Cancel');

          },
          child: const Text('OK'),
        ),
      ],
    ),
  );

  _showDialogBoxWrongPassword() => showCupertinoDialog<String>(
    context: context,
    builder: (BuildContext context) => CupertinoAlertDialog(
      title: Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: const Text('Wrong Password'),
      ),
      content:  Text('Password must contain :\n > A uppercase character\n > A lowercase character\n > A number\n > A special character\n > Minimum 8 characters ',textAlign: TextAlign.left ,style: TextStyle()),
      actions: <Widget>[
        TextButton(
          onPressed: () async {
            Navigator.pop(context, 'Cancel');

          },
          child: const Text('OK'),
        ),
      ],
    ),
  );

  void validatePassword(String value,BuildContext context)async {
    RegExp regex =
    RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');
    if (value.isEmpty) {
      _showDialogBoxWrongPassword();
    } else {
      if (!regex.hasMatch(value)) {
        _showDialogBoxWrongPassword();
      } else {
        loginController.isLoginLoading.value = true;
        await loginController.makeLoginRequest(context);
      }
    }
  }

  Future createQRCodeToPay()async{

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String codeDate = DateFormat('yyyy-MM-dd-HH:mm-ss').format(DateTime.now());

    print("{\"lastToken\":\"${prefs.getString('lastToken')}\",\"paymentCode\":\"$codeDate${prefs.getString('lastPhone')!}\"}");

    return Get.dialog(Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            15.0,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          height:360.h,
          color: Colors.white,
          child: Center(
            child: QrImage(
              data: "{\"lastToken\":\"${prefs.getString('lastToken')}\",\"paymentCode\":\"$codeDate${prefs.getString('lastPhone')!}\",\"userName\":\"${prefs.getString('userName')!}\"}",
              version: QrVersions.auto,
              size: 250.0.sp,
            ),
          ),
        )
    ));
  }
}
