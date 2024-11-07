import 'dart:developer';

import 'package:driverapp/controllers/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vietmap_flutter_gl/vietmap_flutter_gl.dart';
import '../../constant/constant.dart';
import '../../constant/show_dialog.dart';
import '../../service/navigation.dart';
import '../../utils/themes/button.dart';
import '../../utils/themes/contant_colors.dart';
import '../../utils/themes/dialog_box.dart';
import '../../utils/themes/text_style.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<HomeScreen> {
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
        myLocationTrackingMode: MyLocationTrackingMode.Tracking,
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
          child: controller.tripData.isNotEmpty
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
        return buildCompletedTrip();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget buildConfirm() {
    return DraggableScrollableSheet(
      minChildSize: 0.15,
      initialChildSize: 0.3,
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
                          '${controller.tripData['from_address'] != null && controller.tripData['from_address'].length > 45 ? controller.tripData['from_address'].substring(0, 45) + '...' : controller.tripData['from_address'] ?? 'N/A'}',
                          style: CustomTextStyles.normal,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.directions_car,
                                size: 16, color: Colors.green),
                            const SizedBox(width: 4),
                            Text(
                              _getTripTypeDisplay(
                                  controller.tripData['trip_type']),
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
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: ButtonThem.buildIconButton(context,
                        iconSize: 16.0,
                        icon: Icons.arrow_back_ios,
                        iconColor: Colors.black,
                        btnHeight: 40,
                        btnWidthRatio: 0.25,
                        title: 'cancel'.tr,
                        btnColor: ConstantColors.cyan,
                        txtColor: Colors.black, onPress: () async {
                      String? trip = controller.tripData['trip_id'];
                      String? clusterId = controller.tripData['cluster_id'];
                      if (clusterId != null && clusterId.isNotEmpty) {
                        await controller
                            .rejectClusterTrip(clusterId)
                            .then((value) {
                          if (value != null) {
                            if (value['status'] == true) {
                              ShowDialog.showToast(
                                  'Trip rejected successfully'.tr);
                            } else {
                              ShowDialog.showToast(value['message']);
                            }
                          }
                        });
                      } else {
                        await controller.rejectTrip(trip!).then((value) {
                          if (value != null) {
                            if (value['status'] == true) {
                              controller.currentSheetIndex.value = -1;
                              ShowDialog.showToast(
                                  'Trip rejected successfully'.tr);
                            } else {
                              ShowDialog.showToast(value['message']);
                            }
                          }
                        });
                      }
                      Get.back();
                    }),
                  ),
                  Expanded(
                    child: ButtonThem.buildButton(
                      context,
                      btnHeight: 40,
                      title: "confirmed".tr,
                      btnColor: ConstantColors.primary,
                      txtColor: Colors.white,
                      onPress: () async {
                        String? trip = controller.tripData['trip_id'];
                        String? clusterId = controller.tripData['cluster_id'];
                        if (clusterId != null && clusterId.isNotEmpty) {
                          await controller
                              .acceptClusterTrip(clusterId)
                              .then((value) {
                            if (value != null) {
                              if (value['status'] == true) {
                                controller.updateClusterInfo(value['data']);
                                controller.drawClusterRoute(
                                    _mapController!, controller.pickupPoints);
                                controller.currentSheetIndex.value = 1;
                              } else {
                                ShowDialog.showToast(value['message']);
                              }
                            }
                          });
                        } else {
                          await controller.acceptTrip(trip!).then((value) {
                            if (value != null) {
                              if (value.status == true) {
                                controller.updateInfo(value);
                                controller.drawClusterRoute(
                                    _mapController!, controller.pickupPoints);
                                controller.currentSheetIndex.value = 1;
                              } else {
                                ShowDialog.showToast(value.message);
                              }
                            }
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildStartTrip() {
    return DraggableScrollableSheet(
      initialChildSize: 0.33,
      minChildSize: 0.33,
      maxChildSize: 0.5,
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
          child: Column(
            children: [
              Expanded(
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
                                'confirmed pickup'.tr,
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
                                icon: Icon(Icons.navigation,
                                    color: Colors.blue[700]),
                                onPressed: () {
                                  openMaps(
                                    pickup: controller.location.value!,
                                    destination: controller.pickupPoints.last,
                                    stops: controller.pickupPoints,
                                  );
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
                      ListView.builder(
                        shrinkWrap: true,
                        controller: scrollController,
                        itemCount: controller.tripDetails.length,
                        itemBuilder: (context, index) {
                          var passenger = controller.tripDetails[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: InkWell(
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(20)),
                                  ),
                                  builder: (BuildContext context) {
                                    return Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: tripDetail(index),
                                    );
                                  },
                                );
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundColor:
                                        Colors.blueAccent.withOpacity(0.1),
                                        child: const Icon(Icons.person,
                                            color: Colors.blueAccent),
                                      ),
                                      const SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            passenger['name'],
                                            style: CustomTextStyles.normal,
                                          ),
                                          Text(
                                            passenger['from_address'].length > 25
                                                ? '${passenger['from_address'].substring(0, 25)}...'
                                                : passenger['from_address'],
                                            style: CustomTextStyles.body.copyWith(
                                              fontSize: 12,
                                              color: Colors.grey[700],
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.green.withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: IconButton(
                                          icon: const Icon(Icons.phone,
                                              color: Colors.green),
                                          iconSize: 20,
                                          onPressed: () {
                                            final phoneNumber =
                                            passenger['mobile'];
                                            final encodedPhoneNumber = phoneNumber
                                                .replaceFirst("+", "%2B");
                                            launchUrl(Uri.parse(
                                                "tel://$encodedPhoneNumber"));
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
                                          icon: const Icon(Icons.message,
                                              color: Colors.blue),
                                          iconSize: 20,
                                          onPressed: () async {
                                            String phoneNumber =
                                            passenger['mobile'];
                                            Uri smsUri =
                                            Uri.parse('sms:$phoneNumber');

                                            if (await canLaunchUrl(smsUri)) {
                                              await launchUrl(smsUri);
                                            } else {
                                              log('Could not launch $smsUri');
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ButtonThem.buildCustomButton(
                label: 'confirm'.tr,
                onPressed: () async {
                  String? trip = controller.tripData['trip_id'];
                  String? clusterId = controller.tripData['cluster_id'];
                  if (clusterId != null && clusterId.isNotEmpty) {
                    await controller.startClusterTrip(clusterId).then((value) {
                      if (value != null) {
                        if (value['status'] == true) {
                          controller.drawClusterRoute(
                              _mapController!, controller.destinationPoints);
                          controller.currentSheetIndex.value = 2;
                        } else {
                          ShowDialog.showToast(value['message']);
                        }
                      }
                    });
                  } else {
                    await controller.startTrip(trip!).then((value) {
                      if (value != null) {
                        if (value['status'] == true) {
                          controller.drawRoute(
                              _mapController!,
                              controller.pickupPoints.first,
                              controller.destinationPoints.last,
                              stops: controller.stops);
                          controller.currentSheetIndex.value = 2;
                        } else {
                          ShowDialog.showToast(value['message']);
                        }
                      }
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildCompletedTrip() {
    return DraggableScrollableSheet(
      initialChildSize: 0.35,
      minChildSize: 0.35,
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
          child: Column(
            children: [
              Expanded(
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
                                'activities'.tr,
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
                                icon: Icon(Icons.navigation,
                                    color: Colors.blue[700]),
                                onPressed: () {
                                  openMaps(
                                    pickup: controller.location.value!,
                                    destination:
                                        controller.destinationPoints.last,
                                  );
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
                      ListView.builder(
                        shrinkWrap: true,
                        controller: scrollController,
                        itemCount: controller.tripDetails.length,
                        itemBuilder: (context, index) {
                          var passenger = controller.tripDetails[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: InkWell(
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(20)),
                                  ),
                                  builder: (BuildContext context) {
                                    return Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: tripDetail(index),
                                    );
                                  },
                                );
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundColor:
                                            Colors.blueAccent.withOpacity(0.1),
                                        child: const Icon(Icons.person,
                                            color: Colors.blueAccent),
                                      ),
                                      const SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            passenger['name'],
                                            style: CustomTextStyles.normal,
                                          ),
                                          Text(
                                            passenger['to_address'],
                                            style: CustomTextStyles.body.copyWith(
                                              fontSize: 12,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.green.withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: IconButton(
                                          icon: const Icon(Icons.phone,
                                              color: Colors.green),
                                          iconSize: 20,
                                          onPressed: () {
                                            final phoneNumber =
                                                passenger['mobile'];
                                            final encodedPhoneNumber = phoneNumber
                                                .replaceFirst("+", "%2B");
                                            launchUrl(Uri.parse(
                                                "tel://$encodedPhoneNumber"));
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
                                          icon: const Icon(Icons.message,
                                              color: Colors.blue),
                                          iconSize: 20,
                                          onPressed: () async {
                                            String phoneNumber =
                                                passenger['mobile'];
                                            Uri smsUri =
                                                Uri.parse('sms:$phoneNumber');

                                            if (await canLaunchUrl(smsUri)) {
                                              await launchUrl(smsUri);
                                            } else {
                                              log('Could not launch $smsUri');
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      if (controller.tripData['stops'] != null &&
                          controller.tripData['stops'].isNotEmpty)
                        Expanded(
                          child: ListView.builder(
                            controller: scrollController,
                            itemCount: controller.stops.length,
                            itemBuilder: (context, index) {
                              final stop = controller.stops[index];
                              return buildLocationRow(
                                label: '${'stopover'.tr} ${index + 1}',
                                address: stop.address!,
                                icon: Icons.stop_circle,
                                iconColor: Colors.orange,
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ButtonThem.buildCustomButton(
                  label: 'confirm'.tr,
                  onPressed: () async {
                    String? trip = controller.tripData['trip_id'];
                    String? clusterId = controller.tripData['cluster_id'];
                    void showPaymentDialog() {
                      if (mounted) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return CustomDialogBox(
                              title: controller.tripData['payment'] == 'cash'
                                  ? 'cash'.tr
                                  : 'wallet'.tr,
                              descriptions: controller.tripData['payment'] ==
                                      'cash'
                                  ? '${controller.tripData['total_amount']} VND'
                                  : '0 VND',
                              onPress: () {
                                controller.clearData();
                                _mapController?.clearLines();
                                _mapController?.clearSymbols();
                                Get.back();
                              },
                              img: Image.asset(
                                'assets/images/green_checked.png',
                                scale: 0.6,
                              ),
                            );
                          },
                        );
                      }
                    }

                    if (clusterId != null && clusterId.isNotEmpty) {
                      await controller
                          .completeClusterTrip(clusterId)
                          .then((value) {
                        if (value != null) {
                          if (value['status'] == true) {
                            showPaymentDialog();
                          } else {
                            ShowDialog.showToast(value['message']);
                          }
                        }
                      });
                    } else {
                      await controller.completeTrip(trip!).then((value) {
                        if (value != null) {
                          if (value['status'] == true) {
                            showPaymentDialog();
                          } else {
                            ShowDialog.showToast(value['message']);
                          }
                        }
                      });
                    }
                  }),
            ],
          ),
        );
      },
    );
  }

  Widget tripDetail(int index) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.blue[700]),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              Text('trip detail'.tr, style: CustomTextStyles.header),
              const SizedBox(width: 48),
            ],
          ),
          const Divider(
            color: Colors.blueAccent,
            thickness: 1,
            height: 25,
          ),
          buildInfoRow(
            icon: Icons.person,
            label: 'name'.tr,
            value: controller.tripDetails[index]['name'] ?? 'N/A',
            valueColor: Colors.black,
          ),
          const SizedBox(height: 15),
          buildInfoRow(
            icon: Icons.my_location,
            label: 'from'.tr,
            value: controller.tripDetails[index]['from_address'] ?? 'N/A',
            valueColor: Colors.black,
          ),
          const SizedBox(height: 15),
          buildInfoRow(
            icon: Icons.location_on,
            label: 'to'.tr,
            value: controller.tripDetails[index]['to_address'] ?? 'N/A',
            valueColor: Colors.blueGrey,
          ),
          const SizedBox(height: 15),
          buildInfoRow(
            icon: Icons.attach_money,
            label: 'estimated'.tr,
            value: '${controller.tripDetails[index]['amount']} VND',
            valueColor: Colors.red[700],
          ),
          const SizedBox(height: 15),
          if (controller.stops.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'stoporder'.tr,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                ...controller.stops.map((stop) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: buildInfoRow(
                        icon: Icons.stop_circle,
                        label: '',
                        value: stop.address!,
                        valueColor: Colors.orange[700],
                      ),
                    )),
              ],
            ),
        ],
      ),
    );
  }

  Widget buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.blue, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (label.isNotEmpty)
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  color: valueColor ?? Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildLocationRow({
    required String label,
    required String address,
    required IconData icon,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$label: $address',
                style: CustomTextStyles.body
                    .copyWith(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getTripTypeDisplay(String tripType) {
    switch (tripType) {
      case 'airport_private':
        return 'airport_private'.tr;
      case 'airport_sharing':
        return 'airport_sharing'.tr;
      case 'long_trip':
        return 'longtrip'.tr;
      default:
        return 'Loại chuyến đi không xác định'.tr;
    }
  }
}
