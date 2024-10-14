import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class NotificationController extends GetxController {

  var isNotificationDrawerOpen = false.obs;

  void toggleNotification() {
    isNotificationDrawerOpen.value = !isNotificationDrawerOpen.value;
  }

  var notifications = <Map<String, String>>[].obs;

  void showNotification(RemoteMessage message) {
    String title = message.notification?.title ?? 'Thông báo khuyến mãi';
    String body = message.notification?.body ?? 'Bạn có một khuyến mãi mới!';

    notifications.add({'title': title, 'body': body});

    Get.snackbar(
      title,
      body,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Get.theme.snackBarTheme.backgroundColor ?? Colors.black.withOpacity(0.8),
      colorText: Get.theme.snackBarTheme.actionTextColor ?? Colors.white,
      duration: const Duration(seconds: 5),
      margin: const EdgeInsets.all(10),
      borderRadius: 10,
    );
  }

}