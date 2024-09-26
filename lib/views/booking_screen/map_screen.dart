import 'dart:developer';

import 'package:driverapp/controllers/book_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:vietmap_flutter_gl/vietmap_flutter_gl.dart';

import '../../constant/constant.dart';
import '../../constant/show_dialog.dart';
import '../../models/vehicle_model.dart';
import '../../utils/preferences/preferences.dart';
import '../../utils/themes/button.dart';
import '../../utils/themes/dialog_box.dart';
import '../../utils/themes/text_style.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final bookController = Get.put(BookController());

  String apiKey = Constant.VietMapApiKey;

  VietmapController? _mapController;

  final CameraPosition _kInitialPosition =
      const CameraPosition(target: LatLng(10.762317, 106.654551), zoom: 10);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /* appBar: AppBar(
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(width: 8),
                Text(
                  'booking'.tr,
                  style: CustomTextStyles.header,
                ),
              ],
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.lightBlueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),*/
      body: Stack(
        children: [
          VietmapGL(
              dragEnabled: true,
              compassEnabled: false,
              trackCameraPosition: true,
              myLocationRenderMode: MyLocationRenderMode.COMPASS,
              myLocationTrackingMode: MyLocationTrackingMode.TrackingGPS,
              minMaxZoomPreference: const MinMaxZoomPreference(0, 24),
              rotateGesturesEnabled: false,
              styleString:
                  '${Constant.baseUrl}/maps/light/styles.json?apikey=$apiKey',
              initialCameraPosition: _kInitialPosition,
              onMapCreated: (VietmapController controller) async {
                _mapController = controller;
              },
              onMapIdle: _setPickupMaker),
          Obx(() {
            if (bookController.isMapDrawn.value) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                showConfirmationBottomSheet(context);
              });
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Future<void> _setPickupMaker() async {
    final LatLng? pickup = bookController.pickupLatLong.value;

    if (pickup == null ||
        _mapController == null ||
        bookController.isRouteDrawn.value) {
      return;
    }
    await _mapController?.addSymbol(
      SymbolOptions(
        geometry: pickup,
        iconImage: ic_pickup,
        iconSize: 1.5,
      ),
    );

    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(pickup.latitude, pickup.longitude),
        zoom: 14,
      )),
    );
  }

  Future<void> _drawRoute() async {
    if (_mapController == null) return;
    final LatLng? pickup = bookController.pickupLatLong.value;
    final LatLng? destination = bookController.destinationLatLong.value;

    if (pickup == null || destination == null) {
      log('Insufficient data to draw the route.');
      return;
    }
    List<LatLng> routePoints = [pickup];

    if (bookController.stopoverLatLng.isNotEmpty) {
      routePoints.addAll(bookController.stopoverLatLng);
    }
    routePoints.add(destination);
    await bookController.fetchRouteData(routePoints);
    bookController.addPolyline(_mapController);
    bookController.isRouteDrawn.value = true;
  }

  void showConfirmationBottomSheet(BuildContext context) {
    showModalBottomSheet(
      barrierColor: Colors.transparent,
      backgroundColor: Colors.white,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
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
                        'confirmed_pickup'.tr,
                        style: CustomTextStyles.header,
                      ),
                      SizedBox(height: 5),
                      Text(
                        'confirm or change'.tr,
                        style: CustomTextStyles.normal,
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      Get.back();
                    },
                  ),
                ],
              ),
              const Divider(
                color: Colors.blue,
                thickness: 1,
                height: 20,
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.yellow[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        bookController.pickupController.value.text.length > 35
                            ? bookController.pickupController.value.text
                                    .substring(0, 35) +
                                '...'
                            : bookController.destinationController.value.text,
                        style: CustomTextStyles.regular,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ButtonThem.buildCustomButton(
                label: 'confirmed_pickup'.tr,
                onPressed: () async {
                  await _drawRoute();
                  bookController.isRouteDrawn.value = true;
                  bookController.isMapDrawn.value = false;
                  Get.back();
                  tripOptionBottomSheet(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void tripOptionBottomSheet(BuildContext context) {
    showModalBottomSheet(
      barrierColor: Colors.transparent,
      backgroundColor: Colors.white,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Obx(() {
          String title = 'Lựa chọn chuyến đi';
          String buttonText = 'Xác nhận chuyến đi';

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        Get.back();
                      },
                    ),
                  ],
                ),
                const Divider(
                  color: Colors.blue,
                  thickness: 1,
                  indent: 16,
                  endIndent: 16,
                  height: 10,
                ),
                // Round Trip Option
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Round Trip",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Switch(
                      activeColor: Colors.cyan,
                      inactiveTrackColor: Colors.grey.shade50,
                      value: bookController.isRoundTrip.value,
                      onChanged: (bool value) {
                        bookController.setRoundTrip(value);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Passenger Option
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Passenger",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    DropdownButton<int>(
                      value: bookController.selectedPassengerCount.value,
                      iconEnabledColor: Colors.green,
                      iconDisabledColor: Colors.grey,
                      items: List.generate(10, (index) {
                        return DropdownMenuItem<int>(
                          value: index + 1,
                          child: Text('${index + 1}'),
                        );
                      }),
                      icon: const Icon(
                        Icons.person,
                        color: Colors.cyan,
                      ),
                      onChanged: (value) {
                        if (value != null) {
                          bookController.selectedPassengerCount.value = value;
                        }
                      },
                      borderRadius:
                          const BorderRadius.all(Radius.circular(8.0)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          DateTime initialDateTime = bookController
                                  .scheduledTime.value ??
                              DateTime.now().add(const Duration(minutes: 30));
                          DatePicker.showDateTimePicker(
                            context,
                            showTitleActions: true,
                            minTime: DateTime.now(),
                            maxTime: DateTime(2101),
                            onConfirm: (dateTime) {
                              bookController.setScheduledTime(dateTime);
                            },
                            currentTime: initialDateTime,
                            locale: LocaleType.vi,
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Ngày giờ bắt đầu',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 12.0),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.cyan,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.access_time,
                                      size: 20.0, color: Colors.cyan),
                                  const SizedBox(width: 8.0),
                                  Expanded(
                                    child: Text(
                                      bookController.scheduledTime.value == null
                                          ? DateFormat('HH:mm dd-MM')
                                              .format(DateTime.now())
                                          : DateFormat('HH:mm dd-MM').format(
                                              bookController
                                                  .scheduledTime.value!),
                                      style: const TextStyle(fontSize: 16.0),
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (bookController.isRoundTrip.value)
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            DateTime initialDateTime = bookController
                                    .returnTime.value ??
                                DateTime.now().add(const Duration(minutes: 30));
                            DatePicker.showDateTimePicker(
                              context,
                              showTitleActions: true,
                              minTime: DateTime.now(),
                              maxTime: DateTime(2101),
                              onConfirm: (dateTime) {
                                bookController.setReturnTime(dateTime);
                              },
                              currentTime: initialDateTime,
                              locale: LocaleType.vi,
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Ngày giờ về',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 12.0),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.cyan,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.access_time,
                                        size: 20.0, color: Colors.cyan),
                                    const SizedBox(width: 8.0),
                                    Expanded(
                                      child: Text(
                                        bookController.returnTime.value == null
                                            ? DateFormat('HH:mm dd-MM')
                                                .format(DateTime.now())
                                            : DateFormat('HH:mm dd-MM').format(
                                                bookController
                                                    .returnTime.value!),
                                        style: const TextStyle(fontSize: 16.0),
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
               /* ButtonThem.buildCustomButton(
                  label: buttonText,
                  onPressed: () async {
                    if (bookController.scheduledTime.value == null) {
                      ShowDialog.showToast("Vui lòng chọn ngày giờ bắt đầu");
                    } else if (bookController.isRoundTrip.value &&
                        bookController.returnTime.value == null) {
                      ShowDialog.showToast("Vui lòng chọn ngày giờ về");
                    } else {
                      bookController.fetchVehicleTypes().then((value) {
                        if (value != null) {
                          log('$value');
                          if (value.status == true) {
                            Get.back();
                            chooseVehicleBottomSheet(context, value);
                          } else {
                            ShowDialog.showToast(value.message);
                          }
                        }
                      });
                    }
                  },
                )*/
                // Confirm Button
              ],
            ),
          );
        });
      },
    );
  }

 /* chooseVehicleBottomSheet(
      BuildContext context, VehicleModel vehicleCategoryModel) {
    showModalBottomSheet(
      barrierColor: Colors.transparent,
      backgroundColor: Colors.white,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'choose vehicle'.tr,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      Get.back();
                    },
                  ),
                ],
              ),
              const Divider(
                color: Colors.blue,
                thickness: 1,
                height: 20,
              ),
              // Distance Row
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Distance
                    Row(
                      children: [
                        const Icon(
                          Icons.social_distance_outlined,
                          size: 24,
                          color: Colors.blueAccent,
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'distance'.tr,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            Obx(() => Text(
                                  "${bookController.distance.value.toStringAsFixed(2)} ${Constant.distanceUnit}",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                )),
                          ],
                        ),
                      ],
                    ),

                    // Duration
                    Row(
                      children: [
                        const Icon(
                          Icons.timer_sharp,
                          size: 24,
                          color: Colors.redAccent,
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'duration'.tr,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            Obx(() => Text(
                                  "${bookController.duration.value.toStringAsFixed(2)} ${Constant.durationUnit}",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                )),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(
                color: Colors.blue,
                thickness: 1,
                height: 20,
              ),
              SizedBox(
                height: 150,
                child: ListView.builder(
                  itemCount: vehicleCategoryModel.data!.length,
                  itemBuilder: (context, index) {
                    int tripPrice = bookController.calculateTripPrice(
                      distance: bookController.distance.value,
                      startingPrice: double.parse(vehicleCategoryModel.data![index].startingPrice!),
                      ratePerKm: double.parse(vehicleCategoryModel.data![index].ratePerKm!),
                    );
                    return Obx(
                      () => InkWell(
                        onTap: () {
                          *//*bookController.vehicleData =
                              vehicleCategoryModel.data![index];
                          bookController.selectedVehicle.value =
                              vehicleCategoryModel.data![index].id.toString();
                          bookController.totalAmount.value = tripPrice;*//*
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Container(
                            decoration: BoxDecoration(
                              color: bookController.selectedVehicle.value ==
                                      vehicleCategoryModel.data![index].id
                                          .toString()
                                  ? Colors.cyan.withOpacity(0.2)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: bookController.selectedVehicle.value ==
                                        vehicleCategoryModel.data![index].id
                                            .toString()
                                    ? Colors.cyan
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: ListTile(
                              leading: AspectRatio(
                                aspectRatio: 1,
                                child: ClipOval(
                                  child: Image.network(
                                    vehicleCategoryModel.data![index].imageUrl ??
                                        'assets/images/meme.jpg',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              *//*Image.network(
                                  vehicleCategoryModel.data![index].imageUrl ??
                                      'assets/images/meme.jpg', width: 60,
                                height: 60,
                                fit: BoxFit.cover,),*//*
                              title: Text(
                                vehicleCategoryModel.data![index].name
                                    .toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              trailing:  Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    NumberFormat('#,###').format(tripPrice),
                                    style: CustomTextStyles.normal,
                                  ),
                                  const SizedBox(width: 4),
                                  Image.asset(
                                    'assets/icons/dong.png',
                                    width: 12,
                                    height: 12,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              ButtonThem.buildCustomButton(
                label: 'confirmed'.tr,
                onPressed: () async {
                  if (bookController.selectedVehicle.value == '') {
                    ShowDialog.showToast('select a vehicle'.tr);
                    return;
                  }
                  Get.back();
                  paymentBottomSheet(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }*/

  void paymentBottomSheet(BuildContext context) {
    showModalBottomSheet(
      barrierColor: Colors.transparent,
      backgroundColor: Colors.white,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'payment info'.tr,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      Get.back();
                    },
                  ),
                ],
              ),
              const Divider(
                color: Colors.blue,
                thickness: 1,
                height: 20,
              ),
              Text(
                'payment method'.tr,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: GestureDetector(
                        onTap: () {
                          bookController.paymentMethod.value = 'cash';
                        },
                        child: Obx(
                          () => Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color:
                                  bookController.paymentMethod.value == 'cash'
                                      ? Colors.green.withOpacity(0.5)
                                      : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.money, color: Colors.green),
                                SizedBox(height: 8),
                                Text('cash'.tr),
                              ],
                            ),
                          ),
                        )),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                        onTap: () {
                          bookController.paymentMethod.value = 'wallet';
                        },
                        child: Obx(
                          () => Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color:
                                  bookController.paymentMethod.value == 'wallet'
                                      ? Colors.green.withOpacity(0.5)
                                      : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.account_balance_wallet,
                                    color: Colors.green),
                                SizedBox(height: 8),
                                Text('wallet'.tr),
                              ],
                            ),
                          ),
                        )),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ButtonThem.buildCustomButton(
                label: 'book_now'.tr,
                onPressed: () async {
                  if (bookController.paymentMethod.value == '') {
                    ShowDialog.showToast('Please select a Payment method'.tr);
                    return;
                  }
                  bookController.isMapDrawn.value = false;
                  List<Map<String, dynamic>> stops = [];

                  for (int i = 0;
                      i < bookController.stopoverControllers.length;
                      i++) {
                    stops.add({
                      'stop_address':
                          bookController.stopoverControllers[i].text,
                      'stop_lat': bookController.stopoverLatLng[i].latitude,
                      'stop_lng': bookController.stopoverLatLng[i].longitude,
                      'stop_order': i + 1,
                    });
                  }

                  Map<String, dynamic> bodyParams = {
                    'customer_id':
                        Preferences.getInt(Preferences.userId).toString(),
                    'from_address': bookController.pickupController.text,
                    'from_lat': bookController.pickupLatLong.value!.latitude,
                    'from_lng': bookController.pickupLatLong.value!.longitude,
                    'to_address': bookController.destinationController.text,
                    'to_lat': bookController.destinationLatLong.value!.latitude,
                    'to_lng':
                        bookController.destinationLatLong.value!.longitude,
                    'scheduled_time':
                        bookController.scheduledTime.value?.toIso8601String(),
                    'return_time':
                        bookController.returnTime.value?.toIso8601String(),
                    'round_trip': bookController.isRoundTrip.value ? 1 : 0,
                    'km': bookController.distance.toString(),
                    'total_amount': bookController.totalAmount.value.toString(),
                    'payment': bookController.paymentMethod.value,
                    'trip_type': "airport",
                    'stops': stops,
                  };
                  bookController.bookRide(bodyParams).then((value) {
                    if (value != null) {
                      if (value['status'] == true) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return CustomDialogBox(
                              title: "",
                              descriptions: 'successfully'.tr,
                              onPress: () {
                                bookController.clearData();
                                Get.back();
                               /* BottomNavigationController
                                    bottomNavigationController = Get.find();
                                bottomNavigationController.changeIndex(2);Get
                                Get.offAll(() => NavigationPage());*/
                              },
                              img: Image.asset(
                                  'assets/images/green_checked.png'),
                            );
                          },
                        );
                      }
                    } else {
                      log('Error: Received null response');
                    }
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
