import 'package:get/get.dart';

import 'localization_data.dart';

class Localization extends Translations{
  @override
  // TODO: implement keys
  Map<String, Map<String, String>> get keys => {
    'en':en,
    'ar':ar,
    'hi':hi
  };

}