import 'package:driverapp/views/manage_screen/profile_screen.dart';
import 'package:get/get.dart';

class MyProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MyProfileScreen());
  }
}