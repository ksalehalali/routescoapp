//
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get/get_core/src/get_main.dart';
// import 'package:routes/view/screens/Auth/login.dart';
// import 'package:sms_autofill/sms_autofill.dart';
// import 'package:timer_count_down/timer_count_down.dart';
// import '../../../Assistants/globals.dart';
// import '../../../controller/confirm_number_controller.dart';
// import '../../../controller/reset_password_controller.dart';
// import '../../../controller/sign_up_controller.dart';
//
// class ConfirmOTP extends StatefulWidget {
//   final String phoneNum;
//   ConfirmOTP(this.phoneNum);
//
//   @override
//   _ConfirmOTPState createState() => _ConfirmOTPState();
// }
//
// class _ConfirmOTPState extends State<ConfirmOTP> {
//
//   final confirmNumberController = Get.put(ConfirmNumberController());
//   final SignUpController signUpController= Get.find();
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.transparent.withOpacity(0.0),
//         elevation: 0.0,
//         foregroundColor: Colors.black45,
//
//       ),
//       body: SafeArea(
//         child: Container(
//           child: Center(
//             child: SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   // MESSAGE
//                   SizedBox(height: 16,),
//                   Container(
//                     child: Text(
//                       "The confirmation code has been sent to ${widget.phoneNum} via SMS",
//                       style: TextStyle(
//                         fontSize: 22,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                   ),
//                   SizedBox(height: 16,),
//
//                   Obx(
//                         () => Padding(
//                       padding: const EdgeInsets.symmetric(horizontal:18.0),
//                       child: PinFieldAutoFill(
//                         textInputAction: TextInputAction.done,
//                         controller: confirmNumberController.otpEditingController,
//                         decoration: UnderlineDecoration(
//                           textStyle: const TextStyle(fontSize: 16, color: Colors.blue),
//                           colorBuilder: const FixedColorBuilder(
//                             Colors.transparent,
//                           ),
//                           bgColorBuilder: FixedColorBuilder(
//                             Colors.grey.withOpacity(0.2),
//                           ),
//                         ),
//                         currentCode: confirmNumberController.messageOtpCode.value,
//                         onCodeSubmitted: (code) {},
//                         onCodeChanged: (code) {
//                           confirmNumberController.messageOtpCode.value = code!;
//                           confirmNumberController.countdownController.pause();
//                           signUpController.codeController.text= code;
//
//                           if (code.length == 6) {
//                             // To perform some operation
//                           }
//                         },
//                       ),
//                     ),
//                   ),
//                   const SizedBox(
//                     height: 20,
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal:18.0),
//                     child: Countdown(
//                       controller: confirmNumberController.countdownController,
//                       seconds: 15,
//                       interval: const Duration(milliseconds: 1500),
//                       build: (context, currentRemainingTime) {
//                         if (currentRemainingTime == 0.0) {
//                           return Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: GestureDetector(
//                               onTap: ()async {
//                                 // write logic here to resend OTP
//                                 await SmsAutoFill().listenForCode();
//                                 print(confirmNumberController.appSignature);
//                                 confirmNumberController.countdownController.start();
//                                 confirmNumberController.makeCodeConfirmationRequest(true);
//                               },
//                               child: Container(
//                                 alignment: Alignment.center,
//                                 padding: const EdgeInsets.only(
//                                     left: 14, right: 14, top: 14, bottom: 14),
//                                 decoration: BoxDecoration(
//                                     borderRadius: const BorderRadius.all(
//                                       Radius.circular(10),
//                                     ),
//                                     border: Border.all(color: Colors.blue, width: 1),
//                                     color: Colors.blue),
//                                 width: context.width,
//                                 child: const Text(
//                                   "Resend OTP",
//                                   style: TextStyle(
//                                       fontSize: 14,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.white),
//                                 ),
//                               ),
//                             ),
//                           );
//                         } else {
//                           return Container(
//                             alignment: Alignment.center,
//                             padding: const EdgeInsets.only(
//                                 left: 14, right: 14, top: 14, bottom: 14),
//                             decoration: BoxDecoration(
//                               borderRadius: const BorderRadius.all(
//                                 Radius.circular(10),
//                               ),
//                               border: Border.all(color: Colors.blue, width: 1),
//                             ),
//                             width: context.width,
//                             child: Text(
//                                 "Wait |${currentRemainingTime.toString().length == 4 ? " ${currentRemainingTime.toString().substring(0, 2)}" : " ${currentRemainingTime.toString().substring(0, 1)}"}",
//                                 style: const TextStyle(fontSize: 16)),
//                           );
//                         }
//                       },
//                     ),
//                   ),
//
//
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         backgroundColor: routes_color,
//         onPressed: () async{
//
//           bool confirm = await signUpController.makeCodeConfirmationRequest(context);
//           if(confirm){
//             signUpController.codeController.clear();
//             confirmNumberController.otpEditingController.clear();
//
//             Get.offAll(()=>Login());
//           }
//         },
//         child: Icon(Icons.forward),
//       ),
//     );
//   }
//
//   void validatePassword(String value)async {
//     RegExp regex =
//     RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');
//     if (value.isEmpty) {
//       _showDialogBoxWrongPassword();
//     } else {
//       if (!regex.hasMatch(value)) {
//         _showDialogBoxWrongPassword();
//       } else {
//
//         bool confirm = await signUpController.makeCodeConfirmationRequest(context);
//
//       }
//     }
//   }
//
//   _showDialogBoxWrongPassword() => showCupertinoDialog<String>(
//     context: context,
//     builder: (BuildContext context) => CupertinoAlertDialog(
//       title: Padding(
//         padding: const EdgeInsets.only(bottom: 12.0),
//         child: const Text('Wrong Password'),
//       ),
//       content:  Text('Password must contain :\n > A uppercase character\n > A lowercase character\n > A number\n > A special character\n > Minimum 8 characters ',textAlign: TextAlign.left ,style: TextStyle()),
//       actions: <Widget>[
//         TextButton(
//           onPressed: () async {
//             Navigator.pop(context, 'Cancel');
//
//           },
//           child: const Text('OK'),
//         ),
//       ],
//     ),
//   );
// }
