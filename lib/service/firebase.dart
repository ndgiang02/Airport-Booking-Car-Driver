import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../controllers/notification_controller.dart';


class FirebaseService {


  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final HomeController tripController = Get.put(HomeController());
  final NotificationController notificationController = Get.put(NotificationController());

  void initialize() {
    _firebaseMessaging.getToken().then((token) {
      log("FCM Token: $token");
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _handleIncomingNotification(message);
    });
  }

  void _handleIncomingNotification(RemoteMessage message) {
    log('FCM DATA : $message');
    log('Received FCM data: ${message.data}');
    if (message.data.isNotEmpty) {
      if (message.data['type'] == 'trip_request') {
        tripController.updateTripData(message.data);
        String title = message.notification?.title ?? 'Thông báo chuyến đi';
        String body = message.notification?.body ?? 'Bạn đã có một chuyến đi mới';
        Get.snackbar(
          title,
          body,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.blueAccent.withOpacity(0.8),
          colorText: Colors.white,
          duration: Duration(seconds: 5),
          margin: EdgeInsets.all(10),
          borderRadius: 10,
        );
      } else if (message.data['type'] == 'promotion') {
        notificationController.showNotification(message);
      }
    }
  }
}
