import 'dart:developer';

import 'package:driverapp/routes/app_routes.dart';
import 'package:driverapp/service/firebase.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:vietmap_flutter_plugin/vietmap_flutter_plugin.dart';

import 'package:driverapp/utils/preferences/preferences.dart';
import 'constant/constant.dart';
import 'firebase_options.dart';
import 'localization/app_localization.dart';

void configureEasyLoading() {
  EasyLoading.instance
    ..loadingStyle = EasyLoadingStyle.custom
    ..backgroundColor = Colors.white38.withOpacity(0.8)
    ..textColor = Colors.black
    ..indicatorColor = Colors.white
    ..textStyle = const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)
    ..toastPosition = EasyLoadingToastPosition.center
    ..radius = 10.0
    ..maskColor = Colors.black.withOpacity(0.5)
    ..userInteractions = false
    ..dismissOnTap = true;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Preferences.initPref();


  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    log('Firebase initialized successfully');
  } catch (e) {
    log('Error initializing Firebase: $e');
  }
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  Vietmap.getInstance(Constant.VietMapApiKey);
  String? languageCode = Preferences.getString(Preferences.languageCodeKey);
  configureEasyLoading();
  if (languageCode.isEmpty) {
    languageCode = 'vi';
    Preferences.setString(Preferences.languageCodeKey, languageCode);
  }

  final Locale locale =
      languageCode == 'vi' ? const Locale('vi', 'VN') : const Locale('en', 'US');

  runApp(MyApp(
    locale: locale,
  ));

  final FirebaseService firebaseService = FirebaseService();
  firebaseService.initialize();
}

class MyApp extends StatelessWidget {
  final Locale locale;

  const MyApp({super.key, required this.locale});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.white38,
    ));
    return GetMaterialApp(
        title: 'Driver',
        theme: ThemeData(
          fontFamily: 'SFPro',
        ),
        debugShowCheckedModeBanner: false,
        locale: Get.deviceLocale,
        fallbackLocale: const Locale('vi', 'VN'),
        translations: AppTranslations(),
        builder: EasyLoading.init(),
        initialRoute: AppRoutes.initialRoute,
        getPages: AppRoutes.pages,
    );
  }
}
