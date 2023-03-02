import 'package:get_storage/get_storage.dart';

class LocalStorage {
  //write
  void saveLangToDisk(String lang)async{
    await GetStorage().write('lang', lang);

  }

  //read
Future<String> get langSelected async{
    return await GetStorage().read('lang') ==null ? 'en':GetStorage().read('lang');
}
}

