import 'dart:convert';
import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/confiq.dart';
import '../config/push_notification_function.dart';

class SignupApiController extends GetxController implements GetxService {
  // MsgApiModel? msgApiModel;

  Future signupapi({required String name, required String email, required String mobile, required String password, required String ccode,required String rcode,required String agettype}) async {

    Map body = {
      'name' : name,
      'email' : email,
      'mobile' : mobile,
      'password' : password,
      'ccode' : ccode,
      'rcode' : rcode,
      'user_type' : agettype,
    };

    print('+++++++++++++++++++++++++++$body');

    try{
      var response = await http.post(Uri.parse('${config().baseUrl}/api/reg_user.php'), body: jsonEncode(body), headers: {
        'Content-Type': 'application/json',
      });

      print('+++++++++++++++++++++++responsebody${response.body}');

      if(response.statusCode == 200){
        var data = jsonDecode(response.body.toString());
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString("loginData", jsonEncode(data["UserLogin"]));
        prefs.setString("currency", jsonEncode(data["currency"]));
        initPlatformState();
        print('++++++++++++++++++++++++++dataaa+$data');

        return data;
      }else {
        print('failed');
      }
    }catch(e){
      print(e.toString());
    }
  }

}