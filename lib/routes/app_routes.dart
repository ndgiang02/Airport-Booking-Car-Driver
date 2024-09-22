import 'package:driverapp/bindings/activities_binding/activities_binding.dart';
import 'package:driverapp/bindings/booking_binding/booking_binding.dart';
import 'package:driverapp/bindings/home_binding/home_binding.dart';
import 'package:driverapp/bindings/notification_binding/notification_binding.dart';
import 'package:driverapp/views/auth_screens/signup_screen.dart';
import 'package:driverapp/views/dashboard.dart';
import 'package:driverapp/views/home_screens/home_screen.dart';
import 'package:driverapp/views/manage_screen/profile_screen.dart';
import 'package:driverapp/views/notifition_screen/notification_detail.dart';
import 'package:driverapp/views/notifition_screen/notifition_screen.dart';
import 'package:driverapp/views/splash_screen/splash_screen.dart';
import 'package:get/get.dart';


import '../bindings/profile_binding/profile_binding.dart';
import '../bindings/signup_binding/signup_binding.dart';
import '../views/activities_screen/activities_screen.dart';

class AppRoutes {

  static const String loginScreen = '/login';

  static const String registerScreen = '/register';

  static const String dashBoard = '/dashBoard';

  static const String homeScreen = '/home';

  static const String profileScreen = '/profile';

  static const String activitiesScreen = '/activities';

  static const String notificationScreen = '/notifications';

  static const String notificationDetail = '/notificationdetail';

  static const String manageScreen = '/manage';

  static const String localizationScreen = '/localization';

  static const String airportScreen = '/airport';

  static const String longtripScreen = '/longtrip';

  static const String test = '/test';

  static const String initialRoute = '/initialRoute';

  static List<GetPage> pages = [
    GetPage(
      name: initialRoute,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: registerScreen,
      page: () => SignUpScreen(),
      bindings: [
        SignupBinding(),
      ],
    ),
    GetPage(
      name: homeScreen,
      page: () => HomeScreen(),
      bindings: [
        HomeBinding(),
      ],
    ),
    GetPage(
      name: activitiesScreen,
      page: () => ActivitiesScreen(),
      bindings: [
        ActivitiesBinding(),
      ],
    ),
    GetPage(
      name: notificationScreen,
      page: () => NotificationScreen(),
      bindings: [
        NotificationBinding(),
      ],
    ),
    GetPage(
      name: dashBoard,
      page: () =>  Dashboard(),
      bindings: [
        BookingBinding(),
      ],
    ),
    GetPage(
      name: profileScreen,
      page: () =>  MyProfileScreen(),
      bindings: [
        MyProfileBinding(),
      ],
    ),
    GetPage(
      name: notificationDetail,
      page: () => NotificationDetailScreen(notification: Get.arguments),
      bindings: [
        NotificationBinding(),
      ],
    ),

  ];
}