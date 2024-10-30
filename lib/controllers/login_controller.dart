import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../constant/show_dialog.dart';
import '../models/driver_model.dart';
import '../models/user_model.dart';
import '../service/api.dart';
import '../utils/preferences/preferences.dart';

class LoginController extends GetxController {

  var isObscure = true.obs;

  Future<UserModel?> loginAPI(Map<String, String> bodyParams) async {
    try {
      ShowDialog.showLoader('please_wait'.tr);

      String? deviceToken = await FirebaseMessaging.instance.getToken();
      if (deviceToken != null) {
        bodyParams['device_token'] = deviceToken;
      }
      final response = await http.post(
        Uri.parse(API.userLogin),
        headers: API.authheader,
        body: jsonEncode(bodyParams),
      );
      Map<String, dynamic> responseBody = json.decode(response.body);
      if (response.statusCode == 200) {
        if (responseBody['status'] == true) {
          ShowDialog.closeLoader();
          String accessToken = responseBody['data']['token'].toString();
          Preferences.setString(Preferences.token, accessToken);
          API.header['Authorization'] = 'Bearer $accessToken';
          UserModel userModel = UserModel.fromJson(responseBody);
          DriverModel driverModel = DriverModel.fromJson(responseBody['data']['driver']);
          await Preferences.setString('driver', jsonEncode(driverModel.toJson()));
          ShowDialog.showToast('login successful'.tr);
          return userModel;
        } else {
          String errorMessage =
              responseBody['message'] ?? 'Login failed. Please try again.'.tr;
          ShowDialog.showToast(errorMessage);
        }
      } else {
        ShowDialog.showToast(
            '${response.statusCode}. Please try again later.'.tr);
      }
    } on TimeoutException {
      ShowDialog.closeLoader();
      ShowDialog.showToast('Request timed out. Please try again.'.tr);
    } on SocketException {
      ShowDialog.closeLoader();
      ShowDialog.showToast(
          'No internet connection. Please check your network.'.tr);
    } catch (e) {
      ShowDialog.closeLoader();
      ShowDialog.showToast('An unexpected error occurred: $e');
    }
    return null;
  }
}
