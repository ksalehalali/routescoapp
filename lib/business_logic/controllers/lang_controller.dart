import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'local_storage_lang.dart';

class LangController extends GetxController {
  var appLocal = 'en';
  bool isRTL = false;
  void changeLang(String code) {
    LocalStorage localStorage = LocalStorage();
    localStorage.saveLangToDisk(code);
    var local = Locale(code);
    Get.updateLocale(local);
    langCode = code;
    appLocal =code;
    print(langCode);
    update();
  }
  var langCode = '';

  @override
  void onInit() async {
    // TODO: implement onInit
    super.onInit();
    LocalStorage localStorage = LocalStorage();
    appLocal = await localStorage.langSelected == null ? 'en': await localStorage.langSelected;
    Get.updateLocale(Locale(appLocal));
    changeDIR(appLocal);
    update();
  }

  //
void changeDIR(String dir){
    if(dir =='ar'){
      isRTL = true;
    }else{
      isRTL = false;

    }
}



@override
  // TODO: implement onStart
  get onStart => super.onStart;

}
