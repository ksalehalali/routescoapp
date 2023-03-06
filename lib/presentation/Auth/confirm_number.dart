
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import '../../../Assistants/globals.dart';
import '../../business_logic/controllers/confirm_number_controller.dart';


class ConfirmNumber extends StatefulWidget {
  @override
  _ConfirmNumberState createState() => _ConfirmNumberState();
}

class _ConfirmNumberState extends State<ConfirmNumber> {

  final confirmNumberController = Get.put(ConfirmNumberController());
  PhoneNumber number = PhoneNumber(isoCode: 'KW');

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        foregroundColor: Colors.black87,
      ),
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              Container(
                child: Text(
                  "Reset your password",
                  style: TextStyle(
                    fontSize: 30
                  ),
                ),
              ),
              SizedBox(height: 22,),
              Container(
                child: Text(
                  "Type in your phone number and we will send you a code to reset your password",
                  style: TextStyle(
                      fontSize: 20
                  ),
                ),
              ),
              SizedBox(height: 24,),
              InternationalPhoneNumberInput(
                onInputChanged: (PhoneNumber number) {
                  print(number.phoneNumber);
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
                selectorTextStyle: TextStyle(color: Colors.black),
                textStyle: TextStyle(color: Colors.black),
                inputDecoration: InputDecoration(
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
                ),
                initialValue: number,
//                textFieldController: controller,
                formatInput: false,
                keyboardType:
                TextInputType.numberWithOptions(signed: true, decimal: true),
                inputBorder: OutlineInputBorder(),
                onSaved: (PhoneNumber number) {
                  print('On Saved: $number');
                },
              ),
             Spacer(),
              InkWell(
                onTap: (){
                  confirmNumberController.makeCodeConfirmationRequest(false);

                },
                child: Container(
                  width: screenSize.width *0.8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: routes_color5
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Center(
                      child: Text(
                        "Continue_txt".tr,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  ),
                ),
              SizedBox(height: screenSize.height*0.1,)
            ],
          ),
        ),
      ),
    );
  }
}
