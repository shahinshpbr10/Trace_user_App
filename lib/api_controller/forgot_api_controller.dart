import 'dart:convert';
import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:http/http.dart' as http;

import '../config/confiq.dart';

class ForGotApiController extends GetxController implements GetxService {
  // MsgApiModel? msgApiModel;

  Future Forgot(String mobile,ccode,password) async {
    Map body = {
      'mobile' : mobile,
      'ccode' : ccode,
      'password' : password
    };
    print(body);
    try{
      var response = await http.post(Uri.parse('${config().baseUrl}/api/forget_password.php'), body: jsonEncode(body), headers: {
        'Content-Type': 'application/json',
      });

      print(response.body);
      if(response.statusCode == 200){
        var data = jsonDecode(response.body.toString());
        print(data);
        return data;
      }else {
        print('failed');
      }
    }catch(e){
      print(e.toString());
    }
  }

}