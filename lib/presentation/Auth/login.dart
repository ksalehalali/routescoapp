import 'dart:io';
import 'dart:math';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../business_logic/cubit/internet_bloc/internet_bloc.dart';
import '../../business_logic/cubit/internet_bloc/internet_state.dart';
import '../../business_logic/cubit/register_bloc/register_cubit.dart';
import '../../business_logic/cubit/register_bloc/register_state.dart';
import '../../constants/my_colors.dart';
import 'confirm_number.dart';

class Login extends StatelessWidget {
  bool chooseCamera = false;

  PhoneNumber number = PhoneNumber(isoCode: 'KW');
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  String phoneNum = "";
  bool isConnected = false;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    //time
    print(DateFormat('yyyy-MM-dd-HH:mm-ss').format(DateTime.now()));

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
            image: AssetImage(
                "assets/images/background/WhatsApp Image 2022-10-02 at 12.55.00 PM.jpeg"),
            fit: BoxFit.cover),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: Container(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.35),
              child: BlocListener<InternetBloc, InternetState>(
                listener: (context, state) {
                  if (state is Connected) {
                    print("is connected $isConnected");
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(state.msg,
                          style: TextStyle(color: Colors.white)),
                      duration: Duration(seconds: 1),
                      backgroundColor: Colors.green,
                    ));
                  } else if (state is NotConnected) {
                    print("is connected $isConnected");

                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                      state.msg,
                    )));
                  }
                },
                child: BlocConsumer<RegistrationBloc, RegisterStates>(
                    listener: (BuildContext context, state) {},
                    builder: (BuildContext context, state) {
                      RegistrationBloc cubit = RegistrationBloc.get(context);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.only(left: 35, right: 35),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // USERNAME TEXT FIELD
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 18.0),
                                  child: Text(
                                    'Login',
                                    style: TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.w500),
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
                                      phoneNum = number.phoneNumber!
                                          .replaceAll("+", "");
                                    },
                                    onInputValidated: (bool value) {
                                      print(value);
                                    },
                                    selectorConfig: const SelectorConfig(
                                      selectorType:
                                          PhoneInputSelectorType.BOTTOM_SHEET,
                                    ),
                                    maxLength: 8,
                                    ignoreBlank: false,
                                    autoValidateMode: AutovalidateMode.disabled,
                                    selectorTextStyle:
                                        const TextStyle(color: Colors.black),
                                    textStyle: TextStyle(color: Colors.black),
                                    inputDecoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                          color: Colors.transparent,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                          color: Colors.transparent,
                                        ),
                                      ),
                                    ),
                                    initialValue: number,
//                            textFieldController: controller,
                                    formatInput: false,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            signed: true, decimal: true),
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
                                  controller: passwordController,
                                  style: TextStyle(),
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    fillColor: Colors.transparent,
                                    filled: true,
                                    hintText: "Password",
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: routes_color, width: 1.0),
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
                                      child: IconButton(
                                        color: Colors.white,
                                        onPressed: () async {
                                          print("is connected $isConnected");

                                          if (!isConnected == true) {
                                            RegExp regex = RegExp(
                                                r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');
                                            if (passwordController
                                                .text.isEmpty) {
                                              _showDialogBoxWrongPassword(
                                                  context);
                                            } else {
                                              if (!regex.hasMatch(
                                                  passwordController.text)) {
                                                _showDialogBoxWrongPassword(
                                                    context);
                                              } else {
                                                var login = cubit.login(
                                                    phoneNum,
                                                    passwordController.text);
                                              }
                                            }
                                          } else {}
                                        },
                                        icon: !isConnected
                                            ? const Icon(
                                                Icons.arrow_forward,
                                              )
                                            : Container(
                                                height: 20,
                                                width: 20,
                                                child:
                                                    const CircularProgressIndicator(
                                                  color: Colors.white,
                                                ),
                                              ),
                                        //icon: loginController.loginIcon.value
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: screenSize.height * 0.1.h - 60,
                                ),

                                // SIGN UP / FORGOT PASSWORD SECTION
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    BlocBuilder<RegistrationBloc,
                                        RegisterStates>(
                                      builder: (context, state) {
                                        if (state is TryingLogin) {
                                          return const CircularProgressIndicator();
                                        } else if (state is LoggedIn) {
                                          return Text(
                                              "--${state.userInfo['role'][0]}");
                                        } else {
                                          return Container();
                                        }
                                      },
                                    ),

                                    TextButton(
                                      onPressed: () {
                                        // Navigator.push(this.context,
                                        //   MaterialPageRoute(builder: (context) => new SignUp()),
                                        // );
                                      },
                                      style: ButtonStyle(),
                                      child: Text(
                                        'Sign Up',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            decoration:
                                                TextDecoration.underline,
                                            color: routes_color,
                                            fontSize: 18),
                                      ),
                                    ),
                                    // FORGOT PASSWORD
                                    TextButton(
                                        onPressed: () {
                                          // Get.to(ConfirmNumber());
                                        },
                                        child: Text(
                                          'Forgot Password?',
                                          style: TextStyle(
                                            decoration:
                                                TextDecoration.underline,
                                            color: routes_color,
                                            fontSize: 18,
                                          ),
                                        )),
                                  ],
                                ),
                                SizedBox(
                                  height: screenSize.height * 0.1.h - 20,
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
                      );
                    }),
              )),
        ),
      ),
    );
  }

  _showDialogBoxWrongPassword(BuildContext context) =>
      showCupertinoDialog<String>(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: const Padding(
            padding: EdgeInsets.only(bottom: 12.0),
            child: Text('Wrong Password'),
          ),
          content: const Text(
              'Password must contain :\n > A uppercase character\n > A lowercase character\n > A number\n > A special character\n > Minimum 8 characters ',
              textAlign: TextAlign.left,
              style: TextStyle()),
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

  void validatePassword(String value, BuildContext context) async {}

  Future createQRCodeToPay() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String codeDate = DateFormat('yyyy-MM-dd-HH:mm-ss').format(DateTime.now());

    print(
        "{\"lastToken\":\"${prefs.getString('lastToken')}\",\"paymentCode\":\"$codeDate${prefs.getString('lastPhone')!}\"}");

    return Get.dialog(Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            15.0,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          height: 360.h,
          color: Colors.white,
          child: Center(
            child: QrImage(
              data:
                  "{\"lastToken\":\"${prefs.getString('lastToken')}\",\"paymentCode\":\"$codeDate${prefs.getString('lastPhone')!}\",\"userName\":\"${prefs.getString('userName')!}\"}",
              version: QrVersions.auto,
              size: 250.0.sp,
            ),
          ),
        )));
  }
}
