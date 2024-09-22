import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotiController extends GetxController {
  var notificationTitle = "".obs;
  var notificationBody = "".obs;
  var notificationData = {}.obs;

  @override
  void onInit() {
    super.onInit();

    _registerDeviceToken();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _handleForegroundNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationTap(message);
    });
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  void _registerDeviceToken() async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        print("FCM Token: $token");
      }
    } catch (e) {
      print("Error getting FCM token: $e");
    }
  }

  // Xử lý thông báo khi app đang ở foreground
  void _handleForegroundNotification(RemoteMessage message) {
    if (message.notification != null) {
      notificationTitle.value = message.notification?.title ?? "";
      notificationBody.value = message.notification?.body ?? "";

      // Hiển thị thông báo với GetX Snackbar
      Get.snackbar(
        notificationTitle.value,
        notificationBody.value,
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 10),
        onTap: (_) {
          Get.toNamed('/home', arguments: message.data);
        },
      );
    }

    if (message.data.isNotEmpty) {
      notificationData.value = message.data;
      print('Data: ${message.data}');
    }
  }

  void _handleNotificationTap(RemoteMessage message) {
    if (message.data.isNotEmpty) {
      notificationData.value = message.data;
      print('Notification opened with data: ${message.data}');
      Get.toNamed('/tripDetails', arguments: message.data);
    }
  }
}
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}
