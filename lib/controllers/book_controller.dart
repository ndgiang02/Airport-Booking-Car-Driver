import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:vietmap_flutter_gl/vietmap_flutter_gl.dart';
import 'package:vietmap_flutter_plugin/vietmap_flutter_plugin.dart';

import '../constant/constant.dart';
import '../constant/show_dialog.dart';
import '../models/vehicle_model.dart';
import '../service/api.dart';

class BookController extends GetxController {
  var isLoading = true.obs;
  RxString selectedVehicle = "".obs;
  RxDouble distance = 0.0.obs;
  RxDouble duration = 0.0.obs;
  RxInt totalAmount = 0.obs;
  RxInt selectedPassengerCount = 1.obs;

  var step = 'pickup'.obs;

  var isPickupConfirmed = false.obs;
  var isDestinationConfirmed = false.obs;
  var isRouteDrawn = false.obs;

  var pickupLatLong = Rxn<LatLng>();
  var destinationLatLong = Rxn<LatLng>();
  var polylinePoints = <LatLng>[].obs;
  var suggestions = <dynamic>[].obs;

  Location location = Location();
  List<LatLng> stopoverLatLng = [];
  var isMapDrawn = false.obs;
  //late VehicleData? vehicleData;
  var isRoundTrip = false.obs;
  var scheduledTime = Rx<DateTime?>(null);
  var returnTime = Rx<DateTime?>(null);

  final TextEditingController pickupController = TextEditingController();
  final TextEditingController destinationController = TextEditingController();
  final RxList<TextEditingController> stopoverControllers =
      <TextEditingController>[].obs;

  var pickupText = ''.obs;
  var destinationText = ''.obs;
  var stopoverTexts = <RxString>[].obs;
  RxString focusedField = "".obs;
  var paymentMethod = ''.obs;

  @override
  void onInit() {
    super.onInit();
    //fetchVehicleTypes();
    pickupController.addListener(() {
      pickupText.value = pickupController.text;
    });
    destinationController.addListener(() {
      destinationText.value = destinationController.text;
    });
  }

  @override
  void onClose() {
    pickupController.dispose();
    destinationController.dispose();
    for (var controller in stopoverControllers) {
      controller.dispose();
    }
    super.onClose();
  }

  void clearData() {
    pickupController.clear();
    destinationController.clear();
    stopoverControllers.clear();
    stopoverLatLng.clear();
    stopoverTexts.clear();
    pickupLatLong.value = null;
    destinationLatLong.value = null;
    scheduledTime.value = null;
    returnTime.value = null;
    isRoundTrip.value = false;
    distance.value = 0.0;
    duration.value = 0.0;
    totalAmount.value = 0;
    selectedVehicle.value = "";
    selectedPassengerCount.value = 1;
    step.value = 'pickup';
    isPickupConfirmed.value = false;
    isDestinationConfirmed.value = false;
    isRouteDrawn.value = false;
    polylinePoints.clear();
    suggestions.clear();
    isMapDrawn.value = false;
    //vehicleData = null;
    paymentMethod.value = 'cash';
    pickupText.value = '';
    destinationText.value = '';
    focusedField.value = '';
  }

  void addStopover() {
    var controller = TextEditingController();
    var text = ''.obs;
    controller.addListener(() {
      text.value = controller.text;
    });
    stopoverControllers.add(controller);
    stopoverTexts.add(text);
  }

  void removeStopover(int index) {
    stopoverControllers[index].dispose();
    stopoverControllers.removeAt(index);
    stopoverTexts.removeAt(index);
  }

  void setRoundTrip(bool value) {
    isRoundTrip.value = value;
  }

  void setScheduledTime(DateTime? dateTime) {
    scheduledTime.value = dateTime;
  }

  void setReturnTime(DateTime? dateTime) {
    returnTime.value = dateTime;
  }


  Future<LatLng?> reverseGeocode(String refId) async {
    final url =
        '${Constant.baseUrl}/place/v3?apikey=${Constant.VietMapApiKey}&refid=$refId';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data != null && data['lat'] != null && data['lng'] != null) {
          double lat = data['lat'];
          double lng = data['lng'];
          return LatLng(lat, lng);
        }
      } else {
        debugPrint('Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
    return null;
  }

  Future<List<Map<String, String>>> getAutocompleteData(String value) async {
    LocationData position = await location.getLocation();
    final result = await Vietmap.autocomplete(VietMapAutoCompleteParams(
        textSearch: value,
        focusLocation: LatLng(position.latitude!, position.longitude!)));
    return result.fold(
          (failure) {
        debugPrint('Error: $failure');
        return [];
      },
          (autocompleteList) {
        var resultList = <Map<String, String>>[];
        for (var item in autocompleteList) {
          final refId = item.refId ?? '';
          final display = item.display ?? '';

          resultList.add({
            'ref_id': refId,
            'display': display,
          });
        }
        suggestions.value =
            resultList.where((item) => item['ref_id']!.isNotEmpty).toList();
        return resultList;
      },
    );
  }

/*  Future<VehicleCategoryModel?> fetchVehicleTypes() async {
    try {
      final response = await http.get(
        Uri.parse(API.fetchVehicle),
        headers: API.header,
      );
      Map<String, dynamic> responseBody = json.decode(response.body);

      log("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = responseBody;
        return VehicleCategoryModel.fromJson(jsonData);
      } else {
        log('Failed to load vehicle types');
        return null;
      }
    } catch (e) {
      log('Error: $e');
      return null;
    }
  }*/

  int calculateTripPrice({
    required double distance,
    required double startingPrice,
    required double ratePerKm,
    double firstDiscountThreshold = 15.0,
    double secondDiscountThreshold = 30.0,
    double firstDiscountPercentage = 10.0,
    double secondDiscountPercentage = 20.0,
  }) {
    double totalCost = 0.0;
    if (distance <= 0) {
      totalCost = startingPrice;
    } else {
      totalCost = startingPrice + (distance * ratePerKm);
      if (distance > firstDiscountThreshold && distance <= secondDiscountThreshold) {
        totalCost = totalCost * (1 - firstDiscountPercentage / 100);
      } else if (distance > secondDiscountThreshold) {
        totalCost = totalCost * (1 - secondDiscountPercentage / 100);
      }
    }
    int roundedCost = (totalCost / 1000).round() * 1000;

    return roundedCost;
  }


  Future<dynamic> bookRide(Map<String, dynamic> bodyParams) async {
    try {
      ShowDialog.showLoader("Please wait");
      final response = await http.post(Uri.parse(API.bookRides),
          headers: API.header, body: jsonEncode(bodyParams));
      Map<String, dynamic> responseBody = json.decode(response.body);
      if (response.statusCode == 201) {
        ShowDialog.closeLoader();
        return responseBody;
      } else {
        ShowDialog.closeLoader();
        ShowDialog.showToast('Something want wrong. Please try again later');
        throw Exception('Failed to load album');
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

  Future<Map<String, dynamic>?> currentLocation() async {
    try {
      LocationData position = await location.getLocation();
      pickupLatLong.value = LatLng(position.latitude!, position.longitude!);
      final result = await Vietmap.reverse(
          LatLng(position.latitude!, position.longitude!));
      return result.fold(
            (failure) {
          debugPrint('Error: $failure');
          return null;
        },
            (VietmapReverseModel) {
          return {
            'lat': VietmapReverseModel.lat.toString(),
            'lng': VietmapReverseModel.lng.toString(),
            'display': VietmapReverseModel.display ?? '',
          };
        },
      );
    } catch (e) {
      debugPrint('Error: $e');
      return null;
    }
  }

  Future<void> fetchRouteData(List<LatLng> points) async {
    final url = Uri.parse(
        '${Constant.baseUrl}/route?api-version=1.1&apikey=${Constant.VietMapApiKey}&point=${points.map((p) => '${p.latitude},${p.longitude}').join('&point=')}&points_encoded=false&vehicle=car');
    try {
      final response = await http.get(url);
      debugPrint('API Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final paths = data['paths'] as List<dynamic>;

        if (paths.isNotEmpty) {
          final firstPath = paths[0];
          final coordinates = firstPath['points']['coordinates'] as List<dynamic>;

          polylinePoints.value = coordinates.map((coordinate) {
            return LatLng(coordinate[1], coordinate[0]);
          }).toList();

          final distanceInMeters = (firstPath['distance'] as num).toDouble();
          final timeInMillis = (firstPath['time'] as num).toInt();

          distance.value = distanceInMeters / 1000.0;
          duration.value = timeInMillis / 60000.0;

          debugPrint("Distance: ${distance.value} km");
          debugPrint("Duration: ${duration.value} minutes");
        } else {
          throw Exception('No paths found in the response');
        }
      } else {
        throw Exception('Failed to load route data: Status code ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching route data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addPolyline(VietmapController? mapController) async {
    if (mapController != null && polylinePoints.isNotEmpty) {
      await mapController.addPolyline(
        PolylineOptions(
          geometry: polylinePoints,
          polylineColor: Colors.blue,
          polylineWidth: 5.0,
        ),
      );

      await mapController.addSymbol(
        SymbolOptions(
          geometry: polylinePoints.first,
          iconImage: ic_pickup,
          iconSize: 1.5,
        ),
      );

      for (int i = 0; i < stopoverLatLng.length; i++) {
        final LatLng stopover = stopoverLatLng[i];
        await mapController.addSymbol(
          SymbolOptions(
            geometry: stopover,
            iconImage: ic_stop,
            iconSize: 1.3,
          ),
        );
      }

      await mapController.addSymbol(
        SymbolOptions(
          geometry: polylinePoints.last,
          iconImage: ic_dropoff,
          iconSize: 1.5,
        ),
      );

      double? minLat, minLng, maxLat, maxLng;

      for (var point in polylinePoints) {
        if (minLat == null || point.latitude < minLat) {
          minLat = point.latitude;
        }
        if (minLng == null || point.longitude < minLng) {
          minLng = point.longitude;
        }
        if (maxLat == null || point.latitude > maxLat) {
          maxLat = point.latitude;
        }
        if (maxLng == null || point.longitude > maxLng) {
          maxLng = point.longitude;
        }
      }

      final bounds = LatLngBounds(
        southwest: LatLng(minLat!, minLng!),
        northeast: LatLng(maxLat!, maxLng!),
      );

      await mapController.setCameraBounds(
          west: minLng,
          north: maxLat,
          south: minLat,
          east: maxLng,
          padding: 100);

      await mapController.animateCamera(
        CameraUpdate.newLatLngBounds(bounds),
      );
    }
  }
}
