import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:vietmap_flutter_gl/vietmap_flutter_gl.dart';

import '../constant/show_dialog.dart';
import '../models/trip_model.dart';
import '../service/api.dart';


class HomeController extends GetxController {

  Rx<TripModel> tripModel = TripModel().obs;

  var tripData = {}.obs;

  var showBottomSheet = false.obs;

  void updateTripData(Map<String, dynamic> data) {
    tripData.value = data;
    showBottomSheet.value = true;
  }

  void closeBottomSheet() {
    showBottomSheet.value = false;
  }


  @override
  void onInit() {
    super.onInit();
    _startLocationUpdates();
  }

  void clearTripData() {
    tripData.value = {};
  }

  var isAvailable = false.obs;
  var latitude = 0.0.obs;
  var longitude = 0.0.obs;
  var isUpdating = false.obs;

  Future<dynamic> updateDriverStatus(bodyParams) async {
    try {
      ShowDialog.showLoader("Please wait");
      final response = await http.post(Uri.parse(API.updateStatus),
          headers: API.header, body: jsonEncode(bodyParams));
      Map<String, dynamic> responseBody = json.decode(response.body);
      if (response.statusCode == 200) {
        ShowDialog.closeLoader();
        return responseBody;
      } else {
        ShowDialog.closeLoader();
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
    return null;
  }

  Future<void> _startLocationUpdates() async {
      Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 3,
        ),
      ).listen((Position position) {
        latitude.value = position.latitude;
        longitude.value = position.longitude;
        Map<String, dynamic> bodyParams = {
          'latitude': position.latitude,
          'longitude': position.longitude
        };
        updateDriverLocation(bodyParams);
      });
  }

  Future<void> updateDriverLocation(bodyParams) async {
      if (isUpdating.value) return;
      isUpdating.value = true;
      try {
        final response = await http.post(Uri.parse(API.updateLocation),
            headers: API.header, body: jsonEncode(bodyParams));
        Map<String, dynamic> responseBody = json.decode(response.body);
        if (response.statusCode == 200) {
          ShowDialog.closeLoader();
          //return responseBody;
        } else {
          ShowDialog.closeLoader();
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
      finally {
        isUpdating.value = false;
      }
    }

  Future<LatLng?> currentLocation(VietmapController? controller) async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return Future.error('Location services are disabled.');
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return Future.error('Location permissions are denied');
        }
      }
      if (permission == LocationPermission.deniedForever) {
        return Future.error(
            'Location permissions are permanently denied, we cannot request permissions.');
      }
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      LatLng currentLatLng = LatLng(position.latitude, position.longitude);
      if (controller != null) {
        controller.animateCamera(
          CameraUpdate.newLatLngZoom(
            currentLatLng,
            14.0,
          ),
        );
      }
      return currentLatLng;
    } catch (e) {
      log('Error getting location: $e');
      return null;
    }
  }
  
}
