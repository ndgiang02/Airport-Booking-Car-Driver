import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter/material.dart';

class ShowDialog {


  static showToast(
      String? message, {
        EasyLoadingToastPosition position = EasyLoadingToastPosition.bottom,
        Color backgroundColor = Colors.black,
        Color textColor = Colors.white,
        double fontSize = 14.0,
        Duration duration = const Duration(seconds: 2),
        double cornerRadius = 8.0,
      }) {
    EasyLoading.instance
      ..loadingStyle = EasyLoadingStyle.custom
      ..backgroundColor = backgroundColor
      ..textColor = textColor
      ..textStyle = TextStyle(fontSize: fontSize)
      ..displayDuration = duration
      ..toastPosition = position;

    EasyLoading.showToast(
      message ?? '',
      toastPosition: position,
    );
  }

  static showLoader(
      String message, {
        Color backgroundColor = Colors.black,
        Color textColor = Colors.white,
        double fontSize = 14.0,
      }) {
    EasyLoading.instance
      ..loadingStyle = EasyLoadingStyle.custom
      ..backgroundColor = backgroundColor
      ..textColor = textColor
      ..textStyle = TextStyle(fontSize: fontSize);

    EasyLoading.show(status: message);
  }

  static closeLoader() {
    EasyLoading.dismiss();
  }

  static configure() {
    EasyLoading.instance
      ..loadingStyle = EasyLoadingStyle.custom
      ..indicatorType = EasyLoadingIndicatorType.fadingCircle
      ..maskColor = Colors.black.withOpacity(0.5)
      ..userInteractions = false
      ..dismissOnTap = false;
  }
}
