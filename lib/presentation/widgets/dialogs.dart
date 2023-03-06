import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:myfatoorah_flutter/model/initpayment/SDKInitiatePaymentResponse.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../Assistants/globals.dart';
import '../../constants/current_data.dart';
import '../../data/models/payment_saved_model.dart';


class ProgressDialog extends StatelessWidget {
  String? message;

  ProgressDialog({Key? key, this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.blue[100],
      child: Container(
        margin: EdgeInsets.all(15.0),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            children: [
              const SizedBox(
                width: 6.0,
              ),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
              ),
              const SizedBox(
                width: 26.0,
              ),
              Text(
                message!,
                style: const TextStyle(fontSize: 12.0, color: Colors.black),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class DialogShowPayment extends StatelessWidget {
  String? message;

  DialogShowPayment({Key? key, this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: routes_color4,
      child: Container(
        height: 370,
        margin: const EdgeInsets.all(8.0),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6.0),
        ),
        child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'Your Trip Payed',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(
                  height: 22.0,
                ),
                const SizedBox(
                  height: 8.0,
                ),
                const Text(
                  'Payment Id',
                  style: TextStyle(fontSize: 13),
                ),
                Text(
                  paymentSaved.id!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                ),
                const SizedBox(
                  height: 12.0,
                ),
                const Text(
                  'Route',
                  style: TextStyle(fontSize: 14),
                ),
                Text(
                  trip.routeName,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 12.0,
                ),
                const Text(
                  'ticket price cut:',
                  style: TextStyle(fontSize: 13),
                ),
                Text(
                  paymentSaved.value!.toStringAsFixed(3),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 8.0,
                ),
                const Text(
                  'your balance :',
                  style: TextStyle(fontSize: 13),
                ),
                Text(
                  user.totalBalance!.toStringAsFixed(3),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                Center(
                    child: Icon(
                  Icons.done,
                  size: 66,
                  color: Colors.green[800],
                ))
              ],
            )),
      ),
    );
  }
}

class CustomDialog extends StatelessWidget {
  PaymentSaved? payment;
  bool failedPay;
  final bool fromPaymentLists;

  CustomDialog({Key? key, this.payment, required this.fromPaymentLists,required this.failedPay})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          15.0,
        ),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }

  dialogContent(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding:
              const EdgeInsets.only(top: 66.0, bottom: 16.0, left: 15.0, right: 15.0),
          margin: const EdgeInsets.only(top: 34.0),
          decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(17.0),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black,
                    blurRadius: 10.0,
                    offset: Offset(0.0, 0.0))
              ]),
          child: fromPaymentLists == true
              ? Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,

                    children: [
                       Center(
                        child: Text(
                          'Your Trip Paid',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green[700],),
                        ),
                      ),
                      const SizedBox(
                        height: 22.0,
                      ),
                      const SizedBox(
                        height: 8.0,
                      ),
                      const Text(
                        'Payment Id',
                        style: TextStyle(fontSize: 13),
                      ),
                      Text(
                        paymentSaved.id!,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                      ),
                      const SizedBox(
                        height: 12.0,
                      ),
                      const Text(
                        'Route',
                        style: TextStyle(fontSize: 14),
                      ),
                      Text(
                        trip.routeName,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 12.0,
                      ),
                      const Text(
                        'ticket price cut:',
                        style: TextStyle(fontSize: 13),
                      ),
                      Text(
                        paymentSaved.value!.toStringAsFixed(3),
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 8.0,
                      ),
                      const Text(
                        'your balance :',
                        style: TextStyle(fontSize: 13),
                      ),
                      Text(
                        user.totalBalance!.toStringAsFixed(3),
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                      Center(
                          child: Icon(
                        Icons.done,
                        size: 66,
                        color: Colors.green[800],
                      )),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: SizedBox(
                          height: 30,
                          width: 50,
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Close'),
                          ),
                        ),
                      )
                    ],
                  ))
              : failedPay ==false ?Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Paid',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.green[800],
                      ),
                    ),
                    const SizedBox(
                      height: 16.0,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Payment Id',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(
                          height: 4.0,
                        ),
                        Text(
                          payment!.id!,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(
                          height: 16.0,
                        ),
                        Text(
                          'Route ${payment!.routeName!}',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(
                          height: 16.0,
                        ),
                        const Text(
                          'User',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(
                          height: 4.0,
                        ),
                        Text(
                          payment!.userName!,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(
                          height: 16.0,
                        ),
                        // Text(
                        //   'your balance ',
                        //   style: TextStyle(
                        //       fontSize: 18, fontWeight: FontWeight.w700),
                        // ),
                        // SizedBox(
                        //   height: 4.0,
                        // ),
                        // Text(
                        //   user.totalBalance!.toStringAsFixed(3),
                        //   style: TextStyle(
                        //       fontSize: 16, fontWeight: FontWeight.bold),
                        // ),
                        // SizedBox(
                        //   height: 20.0,
                        // ),
                        const Text(
                          'Date',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(
                          height: 4.0,
                        ),
                        Text(
                          DateFormat('yyyy-MM-dd  HH:mm :ss')
                              .format(DateTime.parse(payment!.createdDate!)),
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(
                          height: 16.0,
                        ),
                        const Text(
                          'Value',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(
                          height: 4.0,
                        ),
                        Text(
                          payment!.value!.toStringAsFixed(3),
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(
                          height: 1.0,
                        ),
                        Center(
                          child: QrImage(
                            data: "{\"userId\":\"${user.id!}\",\"paymentId\":\"${payment!.id}\"}",
                            version: QrVersions.auto,
                            size: 170.0,
                          ),
                        ),
                      ],
                    ),

                  ],
                ):Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Field',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.red,
                ),
              ),
              const SizedBox(
                height: 22.0,
              ),
              SizedBox(
                width: Get.width -120,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [

                    SizedBox(
                      height: 24.0,
                    ),
                    Text(
                      'Wrong Data , please try again',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700,color: Colors.red),
                    ),
                    SizedBox(
                      height: 4.0,
                    ),
                    // Text(
                    //   paymentSaved.value!.toStringAsFixed(3),
                    //   style: TextStyle(
                    //       fontSize: 14, fontWeight: FontWeight.w700),
                    // ),
                    SizedBox(
                      height: 16.0,
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: SizedBox(
                  height: 30,
                  width: 50,
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Close'),
                  ),
                ),
              )
            ],
          ),
        ),
        Positioned(
            top: 0.0,
            left: 16.0,
            right: 16.0,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              radius: 44,
              child:failedPay==false? SvgPicture.asset(
                "assets/icons/done.svg",
                width: 100,
                height: 100,
                color: Colors.green[700],
              ):SvgPicture.asset(
                "assets/icons/feild.svg",
                width: 100,
                height: 100,
                //color: routes_color,
              ),
            ))
      ],
    );
  }
}
