
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


void changeStatusNavOptions(Color color ,Brightness brightness){
  SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: color,
        statusBarIconBrightness: brightness,
        systemNavigationBarColor: color,
        systemNavigationBarDividerColor: Colors.yellow,
        systemNavigationBarContrastEnforced: true,
        systemStatusBarContrastEnforced: true,
        statusBarBrightness: brightness,
        systemNavigationBarIconBrightness: brightness,
      )
  );
}