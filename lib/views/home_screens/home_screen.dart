import 'dart:developer';

import 'package:driverapp/controllers/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vietmap_flutter_gl/vietmap_flutter_gl.dart';
import '../../constant/constant.dart';
import '../../constant/show_dialog.dart';
import '../../utils/themes/button.dart';
import '../../utils/themes/text_style.dart';

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
        bottom: 300,
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
            controller.isAvailable.value = !controller.isAvailable.value;
            Map<String, dynamic> bodyParams = {
              'available': controller.isAvailable.value
            };
            controller.updateDriverStatus(bodyParams).then((value) {
              if (value != null) {
                if (value['status'] == true) {
                  controller.isAvailable.value = value['data']['available'];
                  log('${controller.isAvailable.value}');
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
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: controller.tripData.value.isNotEmpty
              ? _buildCurrentSheet(controller.currentSheetIndex.value)
              : const SizedBox.shrink(),
        );
      })
    ]));
  }

  Widget _buildCurrentSheet(int index) {
    switch (index) {
      case 0:
        return buildConfirm();
      case 1:
        return buildStartTrip();
      case 2:
        return buildComplete();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget buildConfirm() {
    return DraggableScrollableSheet(
      minChildSize: 0.15,
      initialChildSize: 0.25,
      maxChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'you_have_new_trip'.tr,
                        style: CustomTextStyles.header,
                      ),
                      const SizedBox(height: 5),
                    ],
                  ),
                ],
              ),
              const Divider(
                color: Colors.blue,
                thickness: 1,
                height: 20,
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.location_on, color: Colors.blue),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ' ${controller.tripData['from_address'] != null && controller.tripData['from_address'].length > 30 ? controller.tripData['from_address'].substring(0, 30) + '...' : controller.tripData['from_address'] ?? 'N/A'}',
                          style: CustomTextStyles.body
                              .copyWith(fontSize: 14, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.directions_car,
                                size: 16, color: Colors.green),
                            const SizedBox(width: 4),
                            Text(
                              controller.tripData['trip_type'],
                              style: CustomTextStyles.regular.copyWith(
                                  fontSize: 14, color: Colors.green[700]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Spacer(),
              ButtonThem.buildCustomButton(
                label: 'confirmed_pickup'.tr,
                onPressed: () async {
                  String trip = controller.tripData['trip_id'];
                  await controller.acceptTrip(trip).then((value) {
                    if (value != null) {
                      if (value.status == true) {
                        controller.updateInfo(value);
                        controller.drawRoute(
                            _mapController!,
                            controller.location.value,
                            controller.pickupLatLong.value);
                        controller.currentSheetIndex.value = 1;
                      } else {
                        ShowDialog.showToast(value.message);
                      }
                    }
                  });
                },
              )
            ],
          ),
        );
      },
    );
  }

  Widget buildStartTrip() {
    return DraggableScrollableSheet(
      initialChildSize: 0.43,
      minChildSize: 0.43,
      maxChildSize: 0.45,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 3,
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'confirmed_pickup'.tr,
                          style: CustomTextStyles.header.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Transform.rotate(
                        angle: 0.785398,
                        child: IconButton(
                          icon: Icon(Icons.navigation, color: Colors.blue[700]),
                          onPressed: () {
                        
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(
                  color: Colors.blueAccent,
                  thickness: 1,
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.blueAccent.withOpacity(0.1),
                            child: const Icon(Icons.person, color: Colors.blueAccent),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '${controller.tripData['customer_name']}',
                            style: CustomTextStyles.body.copyWith(
                              fontSize: 14,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.phone, color: Colors.green),
                                  iconSize: 25,
                                  onPressed: () {

                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.message, color: Colors.blue),
                                  iconSize: 25,
                                  onPressed: () {

                                  },
                                ),
                              ),
                            ],
                          ),

                        ],
                      ),
                    ],
                  ),
                ),
               const Spacer(),
                Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.location_on, color: Colors.blueAccent),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${controller.tripData['from_address']}',
                              style: CustomTextStyles.body.copyWith(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.directions_car,
                                    size: 18, color: Colors.green),
                                const SizedBox(width: 4),
                                Text(
                                  controller.tripData['trip_type'],
                                  style: CustomTextStyles.regular.copyWith(
                                      fontSize: 14, color: Colors.green[700]),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_vert_outlined, color: Colors.blue),
                        onPressed: () {

                        },
                      ),

                    ],
                  ),
                const SizedBox(height: 12),
                ButtonThem.buildCustomButton(
                  label: 'confirmed_pickup'.tr,
                  onPressed: () async {
                    controller.drawRoute(_mapController!, controller.pickupLatLong.value, controller.destinationLatLong.value);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  Widget buildComplete() {
    return DraggableScrollableSheet(
      initialChildSize: 0.3,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'confirmed_pickup'.tr,
                        style: CustomTextStyles.header,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'confirm or change'.tr,
                        style: CustomTextStyles.normal,
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      Navigator.of(context)
                          .pop();
                    },
                  ),
                ],
              ),
              const Divider(
                color: Colors.blue,
                thickness: 1,
                height: 20,
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.location_on, color: Colors.blue),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Điểm đón: ${controller.tripData['from_address']}',
                          style: CustomTextStyles.body
                              .copyWith(fontSize: 14, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.directions_car,
                                size: 16, color: Colors.green),
                            const SizedBox(width: 4),
                            Text(
                              controller.tripData['trip_type'],
                              style: CustomTextStyles.regular.copyWith(
                                  fontSize: 14, color: Colors.green[700]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              ButtonThem.buildCustomButton(
                label: 'confirmed_pickup'.tr,
                onPressed: () async {},
              )
            ],
          ),
        );
      },
    );
  }
}
