import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constant/constant.dart';
import '../../controllers/vehicle_controller.dart';
import '../../utils/themes/contant_colors.dart';

class VehicleScreen extends StatefulWidget {
  const VehicleScreen({super.key});

  @override
  State<VehicleScreen> createState() => _VehicleScreenState();
}

class _VehicleScreenState extends State<VehicleScreen> {

  final VehicleController controller = Get.put(VehicleController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[300],
        body: Obx(() {
         if (controller.vehicle.value == null) {
            return  Center(child: Text('no vehicle data'.tr));
          } else {
            final vehicle = controller.vehicle.value!;
            return SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    buildShowDetails(
                      title: 'vehicle_type'.tr,
                      subtitle: vehicle.data!.vehicleType!.name!,
                      iconData: Icons.type_specimen_sharp,
                      isEditIcon: false,
                      onPress: () {},
                    ),
                    buildShowDetails(
                      subtitle: vehicle.data!.brand!,
                      title: "brand".tr,
                      iconData: Icons.directions_car_filled,
                      isEditIcon: false,
                      onPress: () {},
                    ),
                    buildShowDetails(
                      subtitle: vehicle.data!.model!,
                      title: 'model'.tr,
                      iconData: Icons.model_training,
                      isEditIcon: false,
                      onPress: () {},
                    ),
                    buildShowDetails(
                      subtitle: vehicle.data!.licensePlate!,
                      title: "license_plate".tr,
                      iconData: Icons.library_books_outlined,
                      isEditIcon: false,
                      onPress: () {},
                    ),
                  ],
                ),
              ),
            );
          }
        }));
  }

  buildShowDetails({
    required String title,
    required String subtitle,
    required bool isEditIcon,
    required IconData iconData,
    required Function()? onPress,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Container(
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(10))),
        child: ListTile(
          leading: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Container(
                    decoration: BoxDecoration(
                        color: ConstantColors.primary.withOpacity(0.08),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8))),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(iconData, size: 20, color: Colors.black),
                    )),
              ),
            ],
          ),
          title: Text(
            title,
            style: const TextStyle(fontSize: 16, color: Colors.black),
          ),
          subtitle: Text(subtitle),
          onTap: onPress,
          trailing: Visibility(
            visible: isEditIcon,
            child: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    icEdit,
                    width: 20,
                    height: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
