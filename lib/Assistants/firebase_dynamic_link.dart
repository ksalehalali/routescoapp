import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../business_logic/controllers/start_up_controller.dart';
import '../constants/current_data.dart';


FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

class FirebaseDynamicLinkService{

  static Future<void> initDynamicLink(BuildContext context)async {
    final StartUpController startUpController = Get.find();
final PendingDynamicLinkData? initialLink = await FirebaseDynamicLinks.instance.getInitialLink();

    if (initialLink != null) {
      final Uri deepLink = initialLink.link;
      // Example of using the dynamic link to push the user to a different screen
      print("deep link data forground ::: ${deepLink.data}");

      print('----forground link---- id :: ${deepLink.queryParameters['id']}');
      if(deepLink.queryParameters['id'] != null){

        startUpController.promoterId.value = deepLink.queryParameters['id']!;
        promoterId = deepLink.queryParameters['id']!;
      }
    }

    //on terminate app
    FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) {
      print("deep link data terminate ::: ${dynamicLinkData.link}");
      print('----terminate link---- id :: ${dynamicLinkData.link.queryParameters['id']}');
      if(dynamicLinkData.link.queryParameters['id'] != null){

                startUpController.promoterId.value = dynamicLinkData.link.queryParameters['id']!;
                promoterId = dynamicLinkData.link.queryParameters['id']!;
      }
    }).onError((error) {
      // Handle errors
      print('dynamic link error $error');
    });

   }
}