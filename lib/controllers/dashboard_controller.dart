import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:driverapp/views/activities_screen/activities_screen.dart';
import 'package:driverapp/views/home_screens/home_screen.dart';
import 'package:driverapp/views/introduction/introduction.dart';
import 'package:driverapp/views/vehicle_screen/vehicle_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:vietmap_flutter_gl/vietmap_flutter_gl.dart';
import 'package:vietmap_flutter_plugin/vietmap_flutter_plugin.dart';

import '../constant/constant.dart';
import '../constant/show_dialog.dart';
import '../models/user_model.dart';
import '../service/api.dart';
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

  VietmapController? mapController;

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
        'Home'.tr,
        CupertinoIcons.car_detailed,
      ),
      DrawerItem('History'.tr, Icons.history_toggle_off),
      DrawerItem('my_profile'.tr, Icons.person_outline),
      DrawerItem('Vehicle information'.tr, Icons.car_rental_sharp),
      DrawerItem('My Earnings'.tr, Icons.account_balance_wallet_outlined),
      DrawerItem('select_language'.tr, Icons.language),
      DrawerItem('contact_us'.tr, Icons.rate_review_outlined),
      DrawerItem('term_service'.tr, Icons.design_services),
      DrawerItem('intro'.tr, Icons.interpreter_mode_rounded),
      DrawerItem('sign_out'.tr, Icons.logout),
    ];
  }

  Rx<UserModel> userModel = UserModel().obs;

  /*getUsrData() async {
    userModel.value = Constant.getUserData();
    getDrawerItem();
    Map<String, String> bodyParams = {
      'phone': userModel.value.data!.mobile.toString(),
      'user_type': "driver",
    };
    final responsePhone = await http.post(Uri.parse(API.getProfileByPhone), headers: API.header, body: jsonEncode(bodyParams));
    Map<String, dynamic> responseBodyPhone = json.decode(responsePhone.body);
    if (responsePhone.statusCode == 200 && responseBodyPhone['success'] == "success") {
      ShowDialog.closeLoader();
      UserModel? value = UserModel.fromJson(responseBodyPhone);
      Preferences.setString(Preferences.user, jsonEncode(value));
      userModel.value = value;
      isActive.value = userModel.value.data!.online == "yes" ? true : false;
    }
  }*/


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
      return Text("Error");
    }
    switch (pos) {
      case 0:
        return HomeScreen();
      case 1:
        return ActivitiesScreen();
      case 2:
        return MyProfileScreen();
      case 3:
        return  VehicleScreen();
      case 4:
        return MyWalletScreen();
      case 5:
        return LocalizationScreen();
      case 6:
        return const SupportScreen();
      case 7:
        return const TermsOfServiceScreen();
      case 8:
        return const IntroductionScreen();
      default:
        return Text("Error");
    }
  }

  /*Future<dynamic> setCurrentLocation(String latitude, String longitude) async {
    try {
      Map<String, dynamic> bodyParams = {
        'id_user': Preferences.getInt(Preferences.userId),
        'user_cat': userModel.value.userData!.userCat,
        'latitude': latitude,
        'longitude': longitude
      };
      final response = await http.post(Uri.parse(API.updateLocation), headers: API.header, body: jsonEncode(bodyParams));

      Map<String, dynamic> responseBody = json.decode(response.body);
      if (response.statusCode == 200) {
        return responseBody;
      }
    } on TimeoutException catch (e) {
      ShowDialog.showToast(e.message.toString());
    } on SocketException catch (e) {
      ShowDialog.showToast(e.message.toString());
    } on Error catch (e) {
      ShowDialog.showToast(e.toString());
    } catch (e) {
      ShowDialog.showToast(e.toString());
    }
    return null;
  }*/

  /* Future<dynamic> updateFCMToken(String token) async {
    try {
      Map<String, dynamic> bodyParams = {'user_id': Preferences.getInt(Preferences.userId), 'fcm_id': token, 'device_id': "", 'user_cat': userModel.value.userData!.userCat};
      final response = await http.post(Uri.parse(API.updateToken), headers: API.header, body: jsonEncode(bodyParams));

      Map<String, dynamic> responseBody = json.decode(response.body);
      if (response.statusCode == 200) {
        return responseBody;
      } else {}
    } on TimeoutException catch (e) {
      ShowDialog.showToast(e.message.toString());
    } on SocketException catch (e) {
      ShowDialog.showToast(e.message.toString());
    } on Error catch (e) {
      ShowDialog.showToast(e.toString());
    } catch (e) {
      ShowDialog.showToast(e.toString());
    }
    return null;
  }
*/


}
