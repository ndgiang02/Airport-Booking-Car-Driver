import 'package:driverapp/views/dashboard.dart';
import 'package:get/get.dart';
import '../utils/preferences/preferences.dart';
import '../views/auth_screens/login_screen.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    await Future.delayed(Duration(seconds: 2));

   bool isLoggedIn = Preferences.getBoolean(Preferences.isLogin);
    if (isLoggedIn) {
      Get.off(() => Dashboard()) ;
    } else {
      Get.off(() => LoginScreen());
    }
  }
}
