import 'package:driverapp/utils/themes/text_style.dart';
import 'package:driverapp/views/activities_screen/trip_detail.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/activities_controller.dart';
import '../../models/trip_model.dart';

class ActivitiesScreen extends StatelessWidget {

  ActivitiesScreen({super.key});

  final ActivitiesController controller = Get.put(ActivitiesController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
          children: [
            Obx(() => Expanded(
              child: buildTripList(controller.historyTrips),
            )),
          ],
        ),
    );
  }

  Widget buildTripList(List<Trip> trips) {
    if (trips.isEmpty) {
      return  Center(child: Text('No information'.tr));
    }
    return ListView.builder(
      itemCount: trips.length,
      itemBuilder: (context, index) {
        final trip = trips[index];
        String formattedTime = DateFormat('HH:mm, dd/MM').format(trip.fromTime!);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Container(
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
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // First Row: Time and Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formattedTime,
                        style: CustomTextStyles.regular,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green[100]!,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          trip.tripStatus!.tr,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      // Icon
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.local_taxi,
                          color: Colors.blue[500],
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Addresses
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.circle, size: 10, color: Colors.blue),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    trip.fromAddress!,
                                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.circle, size: 10, color: Colors.orange),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    trip.toAddress!,
                                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Price
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            trip.totalAmount != null
                                ? NumberFormat('#,###').format(trip.totalAmount)
                                : '0.00',
                            style: CustomTextStyles.normal,
                          ),

                          const SizedBox(width: 2),
                          Image.asset(
                            'assets/icons/dong.png',
                            width: 16.0,
                            height: 16.0,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Third Row: Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _getTripTypeDisplay(trip.tripType!),
                        style: CustomTextStyles.normal,
                      ),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Get.to(() => const TripDetail(), arguments: trip);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 14),
                            ),
                            child:  Row(
                              children: [
                                Text('details'.tr, style: const TextStyle(color: Colors.black)),
                                const Icon(Icons.chevron_right_rounded, color: Colors.black),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
