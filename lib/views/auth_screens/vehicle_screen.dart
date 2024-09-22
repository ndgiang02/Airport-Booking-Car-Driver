import 'dart:convert';
import 'dart:developer';

import 'package:driverapp/constant/constant.dart';
import 'package:driverapp/views/dashboard.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constant/show_dialog.dart';
import '../../controllers/signup_controller.dart';
import '../../utils/preferences/preferences.dart';
import '../../utils/themes/button.dart';
import '../../utils/themes/contant_colors.dart';
import '../../utils/themes/textfield_theme.dart';
import 'login_screen.dart';

class VehicleScreen extends StatelessWidget {

  VehicleScreen({super.key});

  static final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final SignUpController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConstantColors.background,
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(login_background),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "sign_up".tr.toUpperCase(),
                            style: const TextStyle(
                                letterSpacing: 0.60,
                                fontSize: 22,
                                color: Colors.black,
                                fontWeight: FontWeight.w600),
                          ),
                          SizedBox(
                              width: 80,
                              child: Divider(
                                color: ConstantColors.blue1,
                                thickness: 3,
                              )),
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Obx(() => DropdownButtonFormField<int>(
                                  value: controller
                                              .selectedVehicleTypeId.value ==
                                          0
                                      ? null
                                      : controller.selectedVehicleTypeId.value,
                                  hint: const Text('Select Vehicle Type'),
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 12),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: ConstantColors
                                              .textFieldBoarderColor,
                                          width: 2),
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: ConstantColors
                                              .textFieldFocusColor,
                                          width: 2),
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                  ),
                                  items: controller.vehicleTypes
                                      .map((type) => DropdownMenuItem<int>(
                                            value: type['id'] as int,
                                            child: Text(type['name'] as String),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    controller.selectedVehicleTypeId.value =
                                        value!;
                                  },
                                )),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: TextFieldTheme.boxBuildTextField(
                              hintText: 'brand'.tr,
                              controller: controller.brand,
                              textInputType: TextInputType.text,
                              maxLength: 13,
                              validators: (String? value) {
                                if (value!.isNotEmpty) {
                                  return null;
                                } else {
                                  return 'required'.tr;
                                }
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: TextFieldTheme.boxBuildTextField(
                              hintText: 'model'.tr,
                              controller: controller.model,
                              textInputType: TextInputType.text,
                              maxLength: 13,
                              validators: (String? value) {
                                if (value!.isNotEmpty) {
                                  return null;
                                } else {
                                  return 'required'.tr;
                                }
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: TextFieldTheme.boxBuildTextField(
                              hintText: 'color'.tr,
                              controller: controller.color,
                              textInputType: TextInputType.text,
                              maxLength: 13,
                              validators: (String? value) {
                                if (value!.isNotEmpty) {
                                  return null;
                                } else {
                                  return 'required'.tr;
                                }
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: TextFieldTheme.boxBuildTextField(
                              hintText: 'license_plate'.tr,
                              controller: controller.plate,
                              textInputType: TextInputType.text,
                              maxLength: 13,
                              validators: (String? value) {
                                if (value!.isNotEmpty) {
                                  return null;
                                } else {
                                  return 'required'.tr;
                                }
                              },
                            ),
                          ),
                          Padding(
                              padding: const EdgeInsets.only(top: 40),
                              child: ButtonThem.buildButton(
                                context,
                                title: 'sign_up'.tr,
                                btnHeight: 45,
                                btnColor: ConstantColors.primary,
                                txtColor: Colors.white,
                                onPress: () async {
                                  FocusScope.of(context).unfocus();
                                  if (_formKey.currentState!.validate()) {
                                    Map<String, String> bodyParams = {
                                      'name':
                                          controller.nameController.text.trim(),
                                      'email': controller.emailController.text
                                          .trim(),
                                      'password':
                                          controller.passwordController.text,
                                      'mobile': controller.phoneController.text
                                          .trim(),
                                      'license_no': controller.no.text.trim(),
                                      'brand': controller.brand.text.trim(),
                                      'vehicle_type_id':
                                      controller.selectedVehicleTypeId.value.toString(),
                                      'license_plate':
                                          controller.plate.text.trim(),
                                      'model':controller.model.text.trim(),
                                      'color':controller.color.text.trim(),
                                      'user_type': 'driver',
                                    };

                                    await controller
                                        .signUp(bodyParams)
                                        .then((value) {
                                      if (value != null) {
                                        if (value.status == true) {
                                        /*  Preferences.setInt(Preferences.userId, value.data!.user!.id!);
                                          Preferences.setString(Preferences.user, jsonEncode(value));
                                          Preferences.setString(Preferences.userName, value.data!.user!.name!);
                                          Preferences.setString(Preferences.userEmail, value.data!.user!.email!);*/
                                          controller.clearData();
                                          Get.offAll(() => LoginScreen(),
                                              duration: const Duration(
                                                  milliseconds: 400),
                                              transition:
                                                  Transition.rightToLeft);
                                        } else {
                                          ShowDialog.showToast(value.message);
                                        }
                                      }
                                    });
                                  }
                                },
                              )),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {
                    Get.back();
                  },
                  child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.white,
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(
                          Icons.arrow_back_ios_rounded,
                          color: Colors.black,
                        ),
                      )),
                ),
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(login_background),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text.rich(
              textAlign: TextAlign.center,
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Already have an account?'.tr,
                    style: const TextStyle(
                        color: Colors.black, fontWeight: FontWeight.w500),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Get.offAll(LoginScreen(),
                            duration: const Duration(
                                milliseconds:
                                    400), //duration of transitions, default 1 sec
                            transition:
                                Transition.rightToLeft); //transition effect);
                      },
                  ),
                  TextSpan(
                    text: ' \u200B\u200B\u200B',
                    style: TextStyle(color: Colors.blue, fontSize: 20),
                  ),
                  TextSpan(
                    text: 'login'.tr,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: ConstantColors.primary),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Get.offAll(() =>LoginScreen(),
                            duration: const Duration(
                                milliseconds:
                                    400), //duration of transitions, default 1 sec
                            transition:
                                Transition.rightToLeft); //transition effect);
                      },
                  ),
                ],
              ),
            )),
      ),
    );
  }
}
