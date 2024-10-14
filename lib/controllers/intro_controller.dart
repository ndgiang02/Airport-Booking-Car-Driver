import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../constant/show_dialog.dart';
import '../../service/api.dart';

class IntroController extends GetxController {

  var introContent = ''.obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    getIntroduction();
  }

  Future<dynamic> getIntroduction() async {
    try {
      ShowDialog.showLoader('please_wait'.tr);
      final response = await http.get(
        Uri.parse(API.introduction),
        headers: API.header,
      );
      Map<String, dynamic> responseBody = json.decode(response.body);
      if (response.statusCode == 200) {
        introContent.value = responseBody['data']['intro'];
        ShowDialog.closeLoader();
        return responseBody;
      } else {
        ShowDialog.closeLoader();
        ShowDialog.showToast(
            'Something want wrong. Please try again later'.tr);
        throw Exception('Failed to load album'.tr);
      }
    } on TimeoutException catch (e) {
      ShowDialog.closeLoader();
      ShowDialog.showToast(e.message.toString());
    } on SocketException catch (e) {
      ShowDialog.closeLoader();
      ShowDialog.showToast(e.message.toString());
    } on Error catch (e) {
      ShowDialog.closeLoader();
      ShowDialog.showToast(e.toString());
    } catch (e) {
      ShowDialog.closeLoader();
      ShowDialog.showToast(e.toString());
    }
    return null;
  }
}