import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../constant/show_dialog.dart';
import '../models/user_model.dart';
import '../service/api.dart';
import '../utils/preferences/preferences.dart';

class SignUpController extends GetxController {

  void clearData() {
    nameController.clear();
    phoneController.clear();
    emailController.clear();
    passwordController.clear();
    conformPasswordController.clear();

    brand.clear();
    color.clear();
    no.clear();
    plate.clear();
    selectedVehicleTypeId.value = 0;
  }

  var isObscure = true.obs;

  var selectedVehicleTypeId = 0.obs;

  final vehicleTypes = [
    {'id': 1, 'name': 'HATCHBACK'},
    {'id': 2, 'name': 'SEDAN'},
    {'id': 3, 'name': 'MPV'},
    {'id': 4, 'name': 'SUV'},
    {'id': 5, 'name': 'VAN'}
  ];

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final conformPasswordController = TextEditingController();

  final brand = TextEditingController();
  final color = TextEditingController();
  final no = TextEditingController();
  final plate = TextEditingController();
  final model = TextEditingController();


  Future<UserModel?> signUp(Map<String, String> bodyParams) async {
    try {
      ShowDialog.showLoader("Please wait");

      final response = await http.post(
        Uri.parse(API.userSignUP),
        headers: API.authheader,
        body: jsonEncode(bodyParams),
      );

      Map<String, dynamic> responseBody = json.decode(response.body);

      if (response.statusCode == 201) {
        if (responseBody['status'] == true) {
          ShowDialog.closeLoader();
          if (responseBody.containsKey('data') &&
              responseBody['data'].containsKey('token')) {
            Preferences.setString(
                Preferences.token, responseBody['data']['token'].toString());
            API.header['token'] = Preferences.getString(Preferences.token);
          }
          return UserModel.fromJson(responseBody);
        } else {
          String errorMessage =
              responseBody['message'] ?? 'Register failed. Please try again.';
          ShowDialog.showToast(errorMessage);
        }
      } else {
        ShowDialog.closeLoader();
        ShowDialog.showToast('Invalid response format from server.');
      }
    } on TimeoutException catch (e) {
      ShowDialog.closeLoader();
      ShowDialog.showToast('Request timed out. Please try again.');
    } on SocketException catch (e) {
      ShowDialog.closeLoader();
      ShowDialog.showToast(
          'No internet connection. Please check your network.');
    } on FormatException catch (e) {
      ShowDialog.closeLoader();
      ShowDialog.showToast('Invalid response format: ${e.message}');
    } catch (e) {
      ShowDialog.closeLoader();
      ShowDialog.showToast('An unexpected error occurred: $e');
    }
    return null;
  }


}
