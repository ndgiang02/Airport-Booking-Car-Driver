import 'package:driverapp/controllers/booking_controller.dart';
import 'package:get/get.dart';

import '../../controllers/book_controller.dart';


class BookingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => BookController());
  }
}