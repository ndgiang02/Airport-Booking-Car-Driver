import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:get/get.dart';
import '../../../models/trip_model.dart';
import 'package:http/http.dart' as http;

import '../constant/show_dialog.dart';
import '../service/api.dart';
import '../utils/preferences/preferences.dart';

class ActivitiesController extends GetxController {
  var historyTrips = <Trip>[].obs;
  int? customerId = Preferences.getInt(Preferences.userId);

  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    getTrip();
  }

  Future<void> getTrip() async {
    try {
      ShowDialog.showLoader('please_wait'.tr);
      final response = await http.get(
        Uri.parse(API.getTrip),
        headers: API.header,
      );

      Map<String, dynamic> responseBody = json.decode(response.body);
      log('getTrip: $responseBody');

      ShowDialog.closeLoader();
      if (response.statusCode == 200) {
        if (responseBody['data'] != null && responseBody['data'] is List) {
          var tripList = (responseBody['data'] as List)
              .map((trip) => Trip.fromJson(trip as Map<String, dynamic>))
              .toList();
          historyTrips.assignAll(tripList);
        } else {
          String errorMessage = responseBody['message'];
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
    return;
  }

  void updateIndex(int index) {}
}
