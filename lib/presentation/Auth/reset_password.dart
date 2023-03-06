
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:timer_count_down/timer_count_down.dart';
import '../../../Assistants/globals.dart';
import '../../business_logic/controllers/confirm_number_controller.dart';
import '../../business_logic/controllers/lang_controller.dart';
import '../../business_logic/controllers/reset_password_controller.dart';

class ResetPassword extends StatefulWidget {
  final String phoneNum;
  ResetPassword(this.phoneNum);

  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {

  final resetPasswordController = Get.put(ResetPasswordController());
  final confirmNumberController = Get.put(ConfirmNumberController());
  final LangController langController = Get.find();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    confirmNumberController.countdownController.pause();


  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent.withOpacity(0.0),
        elevation: 0.0,
        foregroundColor: Colors.black45,

      ),
      body: SafeArea(
        child: Container(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // MESSAGE
                  SizedBox(height: 16,),
                  Container(
                    child: Text(
                      "The confirmation code has been sent to ${widget.phoneNum} via SMS",
                      style: TextStyle(
                        fontSize: 22,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 16,),


                  //pin field autofill
                  Obx(
                        () => Padding(
                          padding: const EdgeInsets.symmetric(horizontal:18.0),
                          child: PinFieldAutoFill(
                      textInputAction: TextInputAction.done,
                      controller: confirmNumberController.otpEditingController,
                      decoration: UnderlineDecoration(
                          textStyle: const TextStyle(fontSize: 16, color: Colors.blue),
                          colorBuilder: const FixedColorBuilder(
                            Colors.transparent,
                          ),
                          bgColorBuilder: FixedColorBuilder(
                            Colors.grey.withOpacity(0.2),
                          ),
                      ),
                      currentCode: confirmNumberController.messageOtpCode.value,
                      onCodeSubmitted: (code) {},
                      onCodeChanged: (code) {
                        confirmNumberController.messageOtpCode.value = code!;
                        confirmNumberController.countdownController.pause();
                          if (code.length == 6) {
                            // To perform some operation
                          }
                      },
                    ),
                        ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal:18.0),
                    child: Countdown(
                      controller: confirmNumberController.countdownController,
                      seconds: 15,
                      interval: const Duration(milliseconds: 1500),
                      build: (context, currentRemainingTime) {
                        if (currentRemainingTime == 0.0) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GestureDetector(
                              onTap: ()async {
                                // write logic here to resend OTP
                                await SmsAutoFill().listenForCode();

                                print(confirmNumberController.appSignature);
                                confirmNumberController.countdownController.start();
                                confirmNumberController.makeCodeConfirmationRequest(false);
                              },
                              child: Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.only(
                                    left: 14, right: 14, top: 14, bottom: 14),
                                decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                    border: Border.all(color: Colors.blue, width: 1),
                                    color: Colors.blue),
                                width: context.width,
                                child: const Text(
                                  "Resend OTP",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                          );
                        } else {
                          return Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.only(
                                left: 14, right: 14, top: 14, bottom: 14),
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.all(
                                Radius.circular(10),
                              ),
                              border: Border.all(color: Colors.blue, width: 1),
                            ),
                            width: context.width,
                            child:langController.appLocal =="en"? Text(
                                "Wait |${currentRemainingTime.toString().length == 4 ? " ${currentRemainingTime.toString().substring(0, 2)}" : " ${currentRemainingTime.toString().substring(0, 1)}"}",
                                style: const TextStyle(fontSize: 16)):Text(
                                "${currentRemainingTime.toString().length == 4 ? " ${currentRemainingTime.toString().substring(0, 2)}" : " ${currentRemainingTime.toString().substring(0, 1)} انتظر | "}",
                                style: const TextStyle(fontSize: 16)),
                          );
                        }
                      },
                    ),
                  ),

                  SizedBox(height: 64,),
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
                          controller: resetPasswordController.passwordController,
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
                              hintText: "Code",
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
                          controller: resetPasswordController.passwordConfirmController,
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
                              hintText: "Code",
                              hintStyle: TextStyle(color: Colors.white),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              )),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: routes_color,
        onPressed: () async{
          validatePassword(resetPasswordController.passwordConfirmController.text);
        },
        child: Icon(Icons.forward),
      ),
    );
  }

  void validatePassword(String value)async {
    RegExp regex =
    RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');
    if (value.isEmpty) {
      _showDialogBoxWrongPassword();
    } else {
      if (!regex.hasMatch(value)) {
        _showDialogBoxWrongPassword();
      } else {

        await resetPasswordController.resetPassword(widget.phoneNum.replaceAll("+", ""),confirmNumberController.messageOtpCode.value);
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
}
