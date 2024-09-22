import 'dart:developer';

import 'package:driverapp/controllers/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vietmap_flutter_gl/vietmap_flutter_gl.dart';
import '../../constant/constant.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> {
  final HomeController controller = Get.put(HomeController());

  VietmapController? _mapController;

  final CameraPosition _kInitialPosition =
      const CameraPosition(target: LatLng(10.762317, 106.654551), zoom: 10);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: [
      VietmapGL(
        dragEnabled: true,
        compassEnabled: false,
        trackCameraPosition: true,
        myLocationEnabled: true,
        myLocationRenderMode: MyLocationRenderMode.COMPASS,
        myLocationTrackingMode: MyLocationTrackingMode.TrackingGPS,
        minMaxZoomPreference: const MinMaxZoomPreference(0, 24),
        rotateGesturesEnabled: false,
        styleString:
            '${Constant.baseUrl}/maps/light/styles.json?apikey=${Constant.VietMapApiKey}',
        initialCameraPosition: _kInitialPosition,
        onMapCreated: (VietmapController controller) async {
          _mapController = controller;
        },
      ),
      Positioned(
        bottom: 50,
        right: 20,
        child: GestureDetector(
          onTap: () async {
                await controller.currentLocation(_mapController);
          },
          child: Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 3,
                  spreadRadius: 1,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.my_location,
              size: 30,
              weight: 0.5,
            ),
          ),
        ),
      ),
      Positioned(
        top: 30,
        right: 20,
        child: GestureDetector(
          onTap: () {
            controller.isAvailable.value =! controller.isAvailable.value;
            Map<String, dynamic> bodyParams = {
              'available': controller.isAvailable.value
            };
            controller.updateDriverStatus(bodyParams).then((value) {
              if (value != null) {
                if (value['status'] == true) {
                  controller.isAvailable.value = value['data']['available'];
                  log('${ controller.isAvailable.value}');
                }
              } else {
                log('Error: Received null response');
              }
            });
          },
          child: Obx(
            () => Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: controller.isAvailable.value
                      ? Colors.green
                      : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 3,
                      spreadRadius: 1,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.power_settings_new,
                  size: 30,
                  weight: 0.5,
                )),
          ),
        ),
      ),
          Obx(() {
            if (controller.tripData.isNotEmpty) {
              return _buildTripConfirmationSheet(context);
            } else {
              return const SizedBox.shrink();
            }
          }),
    ]));
  }

  Widget _buildTripConfirmationSheet(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      height: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Yêu cầu chuyến đi mới',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text('Điểm đón: ${controller.tripData['from_address']}'),
          Text('Loại chuyến đi: ${controller.tripData['to_address']}'),
          Text('Tổng chi phí: ${controller.tripData['total_amount']} VND'),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {
                  controller.clearTripData();
                },
                child: const Text('Xác nhận'),
              ),
              ElevatedButton(
                onPressed: () {
                  controller.clearTripData();
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text('Từ chối'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

