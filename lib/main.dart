import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:routescoapp/presentation/Auth/login.dart';
import 'business_logic/bloc/location_bloc_bloc.dart';
import 'business_logic/controllers/lang_controller.dart';
import 'business_logic/controllers/location_controller.dart';
import 'business_logic/controllers/login_controller.dart';
import 'business_logic/controllers/sign_up_controller.dart';
import 'business_logic/cubit/internet_bloc/internet_bloc.dart';

import 'data/web_services/location_web_service.dart';
import 'data/web_services/registeration_web_service.dart';
import 'localization/localization.dart';
import 'presentation/screens/home/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final langController =
      Get.putAsync(() async => LangController(), permanent: true);
  final locationController = Get.put(LocationController());
  final loginController =
  Get.putAsync(() async => LoginController(), permanent: true);
  final signUpController =
  Get.putAsync(() async => SignUpController(), permanent: true);


  runApp(ServiceApp());
}

class ServiceApp extends StatelessWidget {
  ServiceApp({Key? key}) : super(key: key);
  RegistrationWebService registrationWebService = RegistrationWebService();
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(390, 815),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return RepositoryProvider<RegistrationWebService>(
                  create: (context) => RegistrationWebService(),
                  child: MultiBlocProvider(
                    providers: [

                      BlocProvider<LocationBloc>(
                        create: (context) => LocationBloc( locationWebService: LocationWebService())..add(GetCurrentLocation()),
                      ),
                      BlocProvider<InternetBloc>(
                        create: (context) => InternetBloc(),
                      ),
                    ],
                    child:GetMaterialApp(
                      locale: const Locale('en'),
                      fallbackLocale: Locale('en'),
                      translations: Localization(),
                      initialRoute: LoginScreen.idScreen,
                      routes: {
                        HomeScreen.idScreen: (context)=> HomeScreen(),
                        LoginScreen.idScreen: (context)=> LoginScreen(),

                      },
                      debugShowCheckedModeBanner: false,
                      theme: ThemeData(fontFamily: 'Poppins'),
                      home:  HomeScreen(),
                  ))
            );});
  }
}
