import 'package:driverapp/views/activities_screen/activities_screen.dart';
import 'package:driverapp/views/home_screens/home_screen.dart';
import 'package:driverapp/views/introduction/introduction.dart';
import 'package:driverapp/views/vehicle_screen/vehicle_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../utils/preferences/preferences.dart';
import '../views/auth_screens/login_screen.dart';
import '../views/dashboard.dart';
import '../views/localization_screens/localization_screen.dart';
import '../views/manage_screen/profile_screen.dart';
import '../views/my_wallet_screen/my_wallet_screen.dart';
import '../views/support_screens/support_screen.dart';
import '../views/termpolicy_screen/term_policy_screen.dart';

class DashBoardController extends GetxController {
  RxBool isActive = true.obs;

  @override
  void onInit() {
    updateToken();
    super.onInit();
  }

  updateToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    if (token != null) {}
  }

  getDrawerItem() {
    drawerItems = [
      DrawerItem(
        'home'.tr,
        CupertinoIcons.car_detailed,
      ),
      DrawerItem('history'.tr, Icons.history_toggle_off),
      DrawerItem('my_profile'.tr, Icons.person_outline),
      DrawerItem('vehicle_info'.tr, Icons.car_rental_sharp),
      DrawerItem('wallet'.tr, Icons.account_balance_wallet_outlined),
      DrawerItem('select_language'.tr, Icons.language),
      DrawerItem('contact_us'.tr, Icons.rate_review_outlined),
      DrawerItem('term_policy'.tr, Icons.design_services),
      DrawerItem('intro'.tr, Icons.interpreter_mode_rounded),
      DrawerItem('sign_out'.tr, Icons.logout),
    ];
  }

  RxInt selectedDrawerIndex = 0.obs;
  var drawerItems = [];
  onSelectItem(int index) {
    if (index == 9) {
      Preferences.clearKeyData(Preferences.isLogin);
      Preferences.clearKeyData(Preferences.user);
      Preferences.clearKeyData(Preferences.userId);
      Get.offAll(() => LoginScreen());
    } else {
      selectedDrawerIndex.value = index;
    }
    getDrawerItem();
    Get.back();
  }

  getDrawerItemWidget(int pos) {
    if (pos >= drawerItems.length || pos < 0) {
      return const Text("Error");
    }
    switch (pos) {
      case 0:
        return const HomeScreen();
      case 1:
        return ActivitiesScreen();
      case 2:
        return MyProfileScreen();
      case 3:
        return const VehicleScreen();
      case 4:
        return const MyWalletScreen();
      case 5:
        return const LocalizationScreen();
      case 6:
        return const SupportScreen();
      case 7:
        return const TermsOfServiceScreen();
      case 8:
        return const IntroScreen();
      default:
        return Text('error'.tr);
    }
  }
}
