import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:sms_autofill/sms_autofill.dart';
import '../../../Assistants/globals.dart';

import '../../business_logic/controllers/confirm_number_controller.dart';
import '../../business_logic/controllers/sign_up_controller.dart';
import 'confirm_otp.dart';
import 'login.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {

  final SignUpController signUpController= Get.find();


  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

//  final TextEditingController controller = TextEditingController();
  PhoneNumber number = PhoneNumber(isoCode: 'KW');
  final confirmNumberController = Get.put(ConfirmNumberController());

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
            image: AssetImage("assets/images/background/WhatsApp Image 2022-10-02 at 12.55.00 PM.jpeg"), fit: BoxFit.cover),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Stack(
          children: [

            SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.26),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: 35, right: 35),
                      child: Column(
                        children: [

                          InternationalPhoneNumberInput(
                            onInputChanged: (PhoneNumber number) {
                              print(number.phoneNumber);
                              signUpController.phoneNum.value = number.phoneNumber!;
                              confirmNumberController.phoneNum.value = number.phoneNumber!;
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
                            selectorTextStyle: TextStyle(color: Colors.black87),
                            textStyle: TextStyle(color: Colors.black87),
                            inputDecoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.black87,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.black,
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
                          SizedBox(
                            height: 22,
                          ),
                          // PASSWORD
                          Container(
                            width: MediaQuery.of(context).size.width * 0.75,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  child: Text(
                                    "Password",
                                  ),
                                ),
                                SizedBox(height: 8,),
                                TextField(
                                  cursorColor: routes_color,
                                  controller: signUpController.passwordController,
                                  keyboardType: TextInputType.visiblePassword,
                                  obscureText: true,
                                  enableSuggestions: false,
                                  autocorrect: false,
                                  decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                          color: Colors.black,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                          color: Colors.black,
                                        ),
                                      ),
                                     // hintText: "Code",
                                      hintStyle: TextStyle(color: Colors.white),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      )),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 16,),
                          // CONFIRM PASSWORD
                          Container(
                            width: MediaQuery.of(context).size.width * 0.75,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  child: Text(
                                    "Password Confirm",
                                  ),
                                ),
                                SizedBox(height: 8,),
                                TextField(
                                  cursorColor: routes_color,
                                  controller: signUpController.confirmPasswordController,
                                  keyboardType: TextInputType.visiblePassword,
                                  obscureText: true,
                                  enableSuggestions: false,
                                  autocorrect: false,
                                  decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                          color: Colors.black,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                          color: Colors.black,
                                        ),
                                      ),
                                    //  hintText: "Code",
                                      hintStyle: TextStyle(color: Colors.white),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      )),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // SIGN UP TEXT
                              Text(
                                'Sign Up',
                                style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 27,
                                    fontWeight: FontWeight.w700),
                              ),
                              // SIGN UP BUTTON
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: Color(0xff4c505b),
                                child:  Obx(() => IconButton(
                                  color: Colors.white,
                                  onPressed: () async{
                                    if(signUpController.phoneNum.value.replaceAll("+", "").length>=10 ){
                                     validatePassword(signUpController.passwordController.text);
                                    }else{
                                      Get.snackbar("Wrong phone number", "Please enter a valid phone number");
                                    }

                                  },
                                  icon: !signUpController.isSignUpLoading.value ?
                                  Icon(Icons.arrow_forward,
                                  ):
                                  Container(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 40,
                          ),
                          // NAV LOGIN BUTTON
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                onPressed: () {
                                  Get.to(LoginScreen());
                                },
                                child: Text(
                                  'Sign In',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      color: Colors.black87,
                                      fontSize: 18),
                                ),
                                style: ButtonStyle(),
                              ),
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  void validatePassword(String value)async {
    RegExp regex =
    RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');
    if (value.isEmpty) {
      _showDialogBoxWrongPassword();
    } else if(signUpController.passwordController.text != signUpController.confirmPasswordController.text){
      Get.snackbar("Password not matched", "Wrong password");
      return;
    } else {
      if (!regex.hasMatch(value)) {
        _showDialogBoxWrongPassword();
        return;
      } else {
        await SmsAutoFill().listenForCode();
        bool signUp = await signUpController.makeSignUpRequest(context);

        print(confirmNumberController.appSignature);
       if(signUp) {
         Get.offAll(()=>ConfirmOTP(signUpController.phoneNum.value));
       }
      }
    }
  }

  _showDialogBoxWrongPassword() => showCupertinoDialog<String>(
    context: context,
    builder: (BuildContext context) => CupertinoAlertDialog(
      title: Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: const Text('Wrong Password'),
      ),
      content:  Text('Password must contain :\n > A uppercase character\n > A lowercase character\n > A number\n > A special character( ! @ # \$ & * ~ )\n > Minimum 8 characters ',textAlign: TextAlign.left ,style: TextStyle()),
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
}