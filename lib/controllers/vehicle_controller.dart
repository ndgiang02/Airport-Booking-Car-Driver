import 'dart:async';
import 'dart:io';

import 'package:driverapp/models/vehicle_model.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../constant/show_dialog.dart';
import '../service/api.dart';

class VehicleController extends GetxController {

  var isLoading = true.obs;
  var vehicle = Rxn<VehicleModel>();

  @override
  void onInit() {
    super.onInit();
    fetchVehicle();
  }

  Future<void> fetchVehicle() async {
    try {
      ShowDialog.showLoader('please_wait'.tr.tr);
      final response = await http.get(
        Uri.parse(API.getVehicle),
        headers: API.header,
      );
      Map<String, dynamic> responseBody = json.decode(response.body);
      if (responseBody['status'] == true) {
        ShowDialog.closeLoader();
        vehicle.value = VehicleModel.fromJson(responseBody);
      } else {
        ShowDialog.closeLoader();
        ShowDialog.showToast('Failed to load vehicle data'.tr);
      }
    } on TimeoutException catch (e) {
      ShowDialog.closeLoader();
      ShowDialog.showToast(e.message.toString());
    } on SocketException catch (e) {
      ShowDialog.closeLoader();
      ShowDialog.showToast(e.message.toString());
    } on Error catch (e) {
      ShowDialog.closeLoader();
      ShowDialog.showToast(e.toString());
    } catch (e) {
      ShowDialog.closeLoader();
      ShowDialog.showToast(e.toString());
    }
  }

}
