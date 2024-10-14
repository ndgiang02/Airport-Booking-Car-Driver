import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../constant/show_dialog.dart';
import '../models/transactions.dart';
import '../service/api.dart';

class WalletController extends GetxController {
  var balance = 0.0.obs;
  var transactions = <Transaction>[].obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchWalletData();
  }

  Future<void> fetchWalletData() async {
    try {
      ShowDialog.showLoader('please_wait'.tr);
      final response = await http.get(
        Uri.parse(API.wallet),
        headers: API.header,
      );
      Map<String, dynamic> responseBody =  json.decode(response.body);

      log('$responseBody');

      if (responseBody['status'] == true) {
        ShowDialog.closeLoader();
        balance.value = responseBody['balance'];
        transactions.value = (responseBody['transactions'] as List)
            .map((json) => Transaction.fromJson(json))
            .toList();
      } else {
        ShowDialog.closeLoader();
        ShowDialog.showToast('Failed to load wallet data'.tr);
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
  }

}