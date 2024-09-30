import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:driverapp/models/trip_model.dart';
import 'package:driverapp/models/tripstop_model.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:vietmap_flutter_gl/vietmap_flutter_gl.dart';

import '../constant/constant.dart';
import '../constant/show_dialog.dart';
import '../service/api.dart';

class HomeController extends GetxController {
  var tripData = {}.obs;
  var currentSheetIndex = 0.obs;
  var isLoading = true.obs;
  var polylinePoints = <LatLng>[].obs;
  var stops = <TripStop>[].obs;

  var isAvailable = false.obs;
  var latitude = 0.0.obs;
  var longitude = 0.0.obs;
  var isUpdating = false.obs;

  var pickupLatLong = Rxn<LatLng>();
  var destinationLatLong = Rxn<LatLng>();
  var currentLatLng = Rxn<LatLng>();
  var location = Rxn<LatLng>();


  updateInfo(TripModel trip) {
    pickupLatLong.value = LatLng(trip.data!.fromLat!, trip.data!.fromLng!);
    destinationLatLong.value = LatLng(trip.data!.toLat!, trip.data!.toLng!);
    stops.addAll(trip.data!.tripStops!);
    stops.sort((a, b) => a.stopOrder!.compareTo(b.stopOrder!));
  }

  Future<void> drawRoute(VietmapController mapController, LatLng? start, LatLng? end,  {List<TripStop>? stops} ) async {

    if (start == null || end == null) {
      log('Insufficient data to draw the route.');
      return;
    }

    List<LatLng> routePoints = [start];

    if (stops != null && stops.isNotEmpty) {
      stops.sort((a, b) => a.stopOrder!.compareTo(b.stopOrder!));
      routePoints.addAll(stops.map((stop) => LatLng(stop.latitude!, stop.longitude!)));
    }

    routePoints.add(end);
    await fetchRouteData(routePoints);
    addPolyline(mapController);
  }



  void updateTripData(Map<String, dynamic> data) {
    tripData.value = data;
    currentSheetIndex.value = 0;
  }

 /* Timer? confirmTimer;

  void startConfirmationTimer() {
    confirmTimer?.cancel();
    confirmTimer = Timer(const Duration(seconds: 20), () {
      cancelTrip();
    });
  }

  void cancelTrip() {
    confirmTimer?.cancel();
    currentSheetIndex.value = -1;
    tripData.value = {};
  }*/

  @override
  void onInit() {
    super.onInit();
    _startLocationUpdates();
  }

  Future<TripModel?> acceptTrip(String tripId) async {
    try {
      ShowDialog.showLoader("Please wait");
      final response = await http.post(Uri.parse(API.acceptTrip),
        headers: API.header,
        body: jsonEncode({
          'trip_id': tripId,
        }),
      );
      Map<String, dynamic> responseBody = json.decode(response.body);

      log('Accept Trip : $responseBody');

      ShowDialog.closeLoader();
      if (response.statusCode == 200) {
        if (responseBody['status'] == true) {
          return TripModel.fromJson(responseBody);
        } else {
          String errorMessage = responseBody['message'];
          ShowDialog.showToast(errorMessage);
        }
      } else {
        ShowDialog.showToast('${response.statusCode}. Please try again later.');
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
      location.value = LatLng(latitude.value, longitude.value);
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
    } finally {
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
            LatLng(position.latitude, position.longitude),
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

  Future<void> fetchRouteData(List<LatLng> points) async {
    final url = Uri.parse(
        '${Constant.baseUrl}/route?api-version=1.1&apikey=${Constant.VietMapApiKey}&point=${points.map((p) => '${p.latitude},${p.longitude}').join('&point=')}&points_encoded=false&vehicle=car');
    try {
      final response = await http.get(url);

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

        } else {
          throw Exception('No paths found in the response');
        }
      } else {
        throw Exception('Failed to load route data: Status code ${response.statusCode}');
      }
    } catch (e) {
      log('Error fetching route data: $e');
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

      for (var stop in stops) {
        await mapController.addSymbol(
          SymbolOptions(
            geometry:  LatLng(stop.latitude!, stop.longitude!),
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
