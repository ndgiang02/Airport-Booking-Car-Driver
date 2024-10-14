import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/intro_controller.dart';

class IntroScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    final IntroController controller = Get.put(IntroController());

    return Scaffold(
      body: Obx(() {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Text(
                controller.introContent.value,
                style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black),
                textAlign: TextAlign.left,
              ),
            ),
          );
      }),
    );
  }
}
