import 'dart:convert';

import 'package:driverapp/views/auth_screens/signup_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../constant/constant.dart';
import '../../constant/show_dialog.dart';
import '../../controllers/phonenumber_controller.dart';
import '../../utils/preferences/preferences.dart';
import '../../utils/themes/button.dart';
import '../../utils/themes/contant_colors.dart';
import '../dashboard.dart';

class OtpScreen extends StatelessWidget {
  final String phoneNumber;
  final String verificationId;

  OtpScreen({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
  });

  final controller = Get.put(PhoneNumberController());
  final textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConstantColors.background,
      body: SafeArea(
        child: Container(
          height: Get.height,
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
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Text(
                          "Enter OTP".tr,
                          style: const TextStyle(letterSpacing: 0.60, fontSize: 22, color: Colors.black, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(
                            width: 80,
                            child: Divider(
                              color: ConstantColors.blue1,
                              thickness: 3,
                            )),
                        Padding(
                          padding: const EdgeInsets.only(top: 50),
                          child: PinCodeTextField(
                            length: 6,
                            appContext: context,
                            keyboardType: TextInputType.phone,
                            pinTheme: PinTheme(
                              fieldHeight: 50,
                              fieldWidth: 50,
                              activeColor: ConstantColors.textFieldBoarderColor,
                              selectedColor: ConstantColors.textFieldBoarderColor,
                              inactiveColor: ConstantColors.textFieldBoarderColor,
                              activeFillColor: Colors.white,
                              inactiveFillColor: Colors.white,
                              selectedFillColor: Colors.white,
                              shape: PinCodeFieldShape.box,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            enableActiveFill: true,
                            cursorColor: ConstantColors.primary,
                            controller: textEditingController,
                            onCompleted: (v) async {},
                            onChanged: (value) {
                              debugPrint(value);
                            },
                          ),
                        ),
                        Padding(
                            padding: const EdgeInsets.only(top: 40),
                            child: ButtonThem.buildButton(
                              context,
                              title: 'done'.tr,
                              btnHeight: 50,
                              btnColor: ConstantColors.primary,
                              txtColor: Colors.white,
                              onPress: () async {
                                FocusScope.of(context).unfocus();
                                if (textEditingController.text.length == 6) {
                                  ShowDialog.showLoader('Verify OTP'.tr);
                                  PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: verificationId.toString(), smsCode: textEditingController.text);
                                  await FirebaseAuth.instance.signInWithCredential(credential).then((value) async {
                                    Map<String, String> bodyParams = {
                                      'mobile': phoneNumber.toString(),
                                      'user_type': "driver",
                                    };
                                    await controller.checkUser(bodyParams).then((value) async {
                                      if (value == true) {
                                        Map<String, String> bodyParams = {
                                          'mobile': phoneNumber.toString(),
                                          'user_type': "driver",
                                        };
                                        await controller.loginByPhone(bodyParams).then((value) {
                                          if (value != null) {
                                            if (value.status == true) {
                                              Preferences.setInt(Preferences.userId, value.data!.user!.id!);
                                              Preferences.setString(Preferences.user, jsonEncode(value));
                                              Preferences.setString(Preferences.userName, value.data!.user!.name!);
                                              Preferences.setString(Preferences.userEmail, value.data!.user!.email!);
                                              Preferences.setBoolean(Preferences.isLogin, true);
                                              Get.offAll(() => Dashboard(),
                                                  duration: const Duration(milliseconds: 400),
                                                  transition: Transition.rightToLeft);
                                            }
                                          } else {
                                            ShowDialog.showToast(value?.message);
                                          }
                                        }
                                        );
                                      } else if(value == false){
                                        ShowDialog.closeLoader();
                                        Get.off(SignUpScreen());
                                      }
                                    });
                                  }).catchError((error) {
                                    ShowDialog.closeLoader();
                                    ShowDialog.showToast('Code is Invalid'.tr);
                                  });
                                } else {
                                  ShowDialog.showToast("Please Enter OTP".tr);
                                }
                              },
                            ))
                      ],
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
    );
  }
}
