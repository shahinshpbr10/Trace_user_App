// ignore_for_file: avoid_print

import 'package:onesignal_flutter/onesignal_flutter.dart';

import 'confiq.dart';

// Future<void> initPlatformState() async {
//   OneSignal.shared.setAppId(config().oneSignel);
//   OneSignal.shared
//       .promptUserForPushNotificationPermission()
//       .then((accepted) {});
//   OneSignal.shared.setPermissionObserver((OSPermissionStateChanges changes) {
//     print("Accepted OSPermissionStateChanges : $changes");
//   });
//   // print("--------------__uID : ${getData.read("UserLogin")["id"]}");
// }


Future<void> initPlatformState({context}) async {

  // OneSignal.shared.setAppId(Config.oneSignel).then((value) {
  //   print("accepted123:------  ");
  // });
  // OneSignal.shared.promptUserForPushNotificationPermission().then((accepted) {
  //   print("accepted:------   $accepted");
  // });
  // OneSignal.shared.setPermissionObserver((OSPermissionStateChanges changes) {
  //   print("Accepted OSPermissionStateChanges : $changes");
  // });

  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize(config().oneSignel);
  OneSignal.Notifications.requestPermission(true).then((value) {
    print("signal value:- ${value}");
  },);

}