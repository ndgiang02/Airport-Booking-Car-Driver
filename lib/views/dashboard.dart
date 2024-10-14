import 'package:driverapp/utils/themes/text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constant/constant.dart';
import '../controllers/dashboard_controller.dart';
import '../controllers/notification_controller.dart';
import '../utils/preferences/preferences.dart';

class Dashboard extends StatelessWidget {

  String? name =  Preferences.getString(Preferences.userName);
  String? email =  Preferences.getString(Preferences.userEmail);

  DateTime backPress = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return GetX<DashBoardController>(
      init: DashBoardController(),
      builder: (controller) {
        controller.getDrawerItem();
        return WillPopScope(
          onWillPop: () async {
            final timeGap = DateTime.now().difference(backPress);
            final cantExit = timeGap >= const Duration(seconds: 2);
            backPress = DateTime.now();
            if (cantExit) {
              final snack = SnackBar(
                content: Text(
                  'Press Back button again to Exit'.tr,
                  style: const TextStyle(color: Colors.white),
                ),
                duration: const Duration(seconds: 2),
                backgroundColor: Colors.black,
              );
              ScaffoldMessenger.of(context).showSnackBar(snack);
              return false;
            } else {
              return true;
            }
          },
          child: Scaffold(
            appBar: AppBar(
              //backgroundColor: ConstantColors.background.withOpacity(0.2),
              elevation: 0,
              centerTitle: true,
              title:Text(
                controller.drawerItems[controller.selectedDrawerIndex.value].title.toString(),
                style: const TextStyle(color: Colors.black),
              ),
              leading: Builder(builder: (context) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () {
                      controller.getDrawerItem();
                      Scaffold.of(context).openDrawer();
                    },
                    child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Colors.white,
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 3,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          "assets/icons/ic_side_menu.png",
                          color: Colors.black,
                          width: 23,
                          height: 16,
                        )),
                  ),
                );
              }),
              actions: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () {
                      //notifController.toggleNotification();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 3,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.notifications),
                    ),
                  ),
                ),
              ],
            ),
            drawer: buildAppDrawer(context, controller),
            body: controller.getDrawerItemWidget(controller.selectedDrawerIndex.value),
          ),

        );
      },
    );
  }


  buildAppDrawer(BuildContext context, DashBoardController controller) {
    return Drawer(
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: controller.drawerItems.length + 2,
        itemBuilder: (context, index) {
          if (index == 0) {
            return UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: Colors.tealAccent.withOpacity(0.2),
              ),
              currentAccountPicture: ClipOval(
                child: Container(
                  color: Colors.black.withOpacity(0.2),
                  child: const Image(image: AssetImage(meme)),
                ),
              ),
              accountName: Text(
                name!,
                style: CustomTextStyles.header,
              ),
              accountEmail: Text(
                email!,
                style: CustomTextStyles.body,
              ),
            );
          }
          if (index == controller.drawerItems.length + 1) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                'V : ${Constant.appVersion.toString()}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            );
          }

          var item = controller.drawerItems[index - 1];
          return ListTile(
            leading: Icon(
              item.icon,
              color: index - 1 == controller.selectedDrawerIndex.value
                  ? Colors.blue
                  : Colors.black,
            ),
            title: Text(
              item.title,
              style: TextStyle(
                color: index - 1 == controller.selectedDrawerIndex.value
                    ? Colors.blue
                    : Colors.black,
              ),
            ),
            selected: index - 1 == controller.selectedDrawerIndex.value,
            selectedTileColor: Colors.blue.withOpacity(0.1),
            onTap: () => controller.onSelectItem(index - 1),
          );
        },
      ),
    );
  }

}


class DrawerItem {
  String title;
  IconData icon;
  TextStyle textStyle;

  DrawerItem(this.title, this.icon, {this.textStyle = const TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold)});
}


