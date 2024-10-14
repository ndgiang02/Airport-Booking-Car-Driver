import 'package:driverapp/constant/constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/forgotpassword_controller.dart';
import '../../utils/themes/button.dart';
import '../../utils/themes/contant_colors.dart';
import '../../utils/themes/textfield_theme.dart';
import '../../constant/show_dialog.dart';
import 'forgotpwotpscreen.dart';

class ForgotPasswordScreen extends StatelessWidget {

  ForgotPasswordScreen({super.key});

  final controller = Get.put(ForgotPasswordController());

  static final _formKey = GlobalKey<FormState>();
  static final _emailTextEditController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "forgot_password".tr.toUpperCase(),
                        style: const TextStyle(letterSpacing: 0.60, fontSize: 22, color: Colors.black, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                          width: 80,
                          child: Divider(
                            color: ConstantColors.blue1,
                            thickness: 3,
                          )),
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Text(
                          "Enter the email address we will send an OTP to create new password.".tr,
                          textAlign: TextAlign.start,
                          style: TextStyle(letterSpacing: 1.0, color: ConstantColors.hintTextColor, fontWeight: FontWeight.w600),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 30),
                        child: Form(
                          key: _formKey,
                          child: TextFieldTheme.boxBuildTextField(
                            hintText: 'email'.tr,
                            controller: _emailTextEditController,
                            textInputType: TextInputType.emailAddress,
                            validators: (String? value) {
                              if (value!.isNotEmpty) {
                                return null;
                              } else {
                                return 'required'.tr;
                              }
                            },
                          ),
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: ButtonThem.buildButton(
                            context,
                            title: 'send'.tr,
                            btnHeight: 50,
                            btnColor: ConstantColors.primary,
                            txtColor: Colors.white,
                            onPress: () {
                              FocusScope.of(context).unfocus();
                              if (_formKey.currentState!.validate()) {
                                Map<String, String> bodyParams = {
                                  'email': _emailTextEditController.text.trim(),
                                };
                                controller.sendEmail(bodyParams).then((value) {
                                  if (value != null) {
                                    debugPrint("$value");
                                    if (value == true) {
                                      Get.to(ForgotPasswordOtpScreen(email: _emailTextEditController.text.trim()),
                                          duration: const Duration(milliseconds: 400),
                                          transition: Transition.rightToLeft);
                                    } else {
                                      ShowDialog.showToast("Please try again later".tr);
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
