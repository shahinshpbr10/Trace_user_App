// ignore_for_file: camel_case_types, file_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:tracebusapp/view/home/view/home_page.dart';
import 'package:tracebusapp/view/home/view/payment_history_page.dart';
import 'package:tracebusapp/view/my_account_page/accountpage.dart';

import '../../config/light_and _dark.dart';
import '../home/controller/home_controller.dart';





class Bottom_Navigation extends StatefulWidget {
  const Bottom_Navigation({super.key});

  @override
  State<Bottom_Navigation> createState() => _Bottom_NavigationState();
}

class _Bottom_NavigationState extends State<Bottom_Navigation> {

  // int _selectedIndex = 0;
  static const List _widgetOptions = [
    HomePage(),

  PaymentHistoryPage(),  MyAccountScreen(),
  ];
  HomeController homeController = Get.put(HomeController());


  void _onItemTapped(int index) {
    setState(() {
      homeController.selectpage = index;
    });
  }
  ColorNotifier notifier = ColorNotifier();
  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    return GetBuilder<HomeController>(
        builder: (homeController) {
          return Scaffold(
            bottomNavigationBar: BottomNavigationBar(
              unselectedItemColor: notifier.textColor,
              type: BottomNavigationBarType.fixed,
              selectedFontSize: 12,
              unselectedFontSize: 12,
              backgroundColor: notifier.background,
              elevation: 0,
              items:  <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: homeController.selectpage == 0 ?  Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Image(image: const AssetImage('assets/Bottom Fill Home.png'),height: 22,width: 22,color: notifier.theamcolorelight),
                  ):  const Padding(
                    padding: EdgeInsets.only(bottom: 5),
                    child: Image(image: AssetImage('assets/Botom home.png'),height: 20,width: 20,),
                  ),
                  label: 'Home'.tr,
                ),

                BottomNavigationBarItem(
                  icon: homeController.selectpage == 2 ?  Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Image(image: const AssetImage('assets/Bottom Fill Wallet.png'),height: 19,width: 19,color: notifier.theamcolorelight),
                  ):const Padding(
                    padding: EdgeInsets.only(bottom: 5),
                    child: Image(image: AssetImage('assets/Bottom Wallet.png'),height: 22,width: 22,),
                  ),
                  label: 'My Payments'.tr,
                ),
                BottomNavigationBarItem(
                  icon:homeController.selectpage == 3 ?  Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Image(image: const AssetImage('assets/Bottom Fill Account.png'),height: 20,width: 20,color: notifier.theamcolorelight),
                  ):const Padding(
                    padding: EdgeInsets.only(bottom: 5),
                    child: Image(image: AssetImage('assets/Bottom Account.png'),height: 20,width: 20,),
                  ),
                  label: 'Account'.tr,
                ),
              ],
              currentIndex: homeController.selectpage,
              selectedItemColor: notifier.theamcolorelight,
              onTap: _onItemTapped,
            ),
            body: Center(
              child: _widgetOptions.elementAt(homeController.selectpage),
            ),

          );
        }
    );
  }
}
