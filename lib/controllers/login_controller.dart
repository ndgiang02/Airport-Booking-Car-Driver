import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../constant/show_dialog.dart';
import '../models/driver_model.dart';
import '../models/user_model.dart';
import '../models/vehicle_model.dart';
import '../service/api.dart';
import '../utils/preferences/preferences.dart';

class LoginController extends GetxController {

  var isObscure = true.obs;

  Future<UserModel?> loginAPI(Map<String, String> bodyParams) async {
    try {
      ShowDialog.showLoader("Please wait");

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
      ShowDialog.closeLoader();
      if (response.statusCode == 200) {
        if (responseBody['status'] == true) {

          UserModel userModel = UserModel.fromJson(responseBody);
          DriverModel driverModel = DriverModel.fromJson(responseBody['data']['driver']);

          log("User ID: ${userModel.data!.user!.id!}");
          log("Driver License No: ${driverModel.licenseNo}");
          log("Vehicle Brand: ${driverModel.vehicle!.brand}");

          await Preferences.setString('driver', jsonEncode(driverModel.toJson()));

          return userModel;
        } else {
          String errorMessage =
              responseBody['message'] ?? 'Login failed. Please try again.';
          ShowDialog.showToast(errorMessage);
        }
      } else {
        ShowDialog.showToast(
            '${response.statusCode}. Please try again later.');
      }
    } on TimeoutException {
      ShowDialog.closeLoader();
      ShowDialog.showToast('Request timed out. Please try again.');
    } on SocketException {
      ShowDialog.closeLoader();
      ShowDialog.showToast(
          'No internet connection. Please check your network.');
    } catch (e) {
      ShowDialog.closeLoader();
      ShowDialog.showToast('An unexpected error occurred: $e');
    }
    return null;
  }
}
