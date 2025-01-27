import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:http/http.dart' as http;

import '../api_models/sms_api_model.dart';
import '../config/confiq.dart';


class SmstypeApiController extends GetxController implements GetxService {

  SmaApiModel? smaApiModel;
  bool isLoading = true;
  smsApi(context) async {

    Map<String,String> userHeader = {"Content-type": "application/json", "Accept": "application/json"};
    var response = await http.get(Uri.parse(config().baseUrl + config().smstypeapi),headers: userHeader);

    print("++++++++++ sms type ++++++++++:-- ${response.body}");

    var data = jsonDecode(response.body);
    if(response.statusCode == 200){
      if(data["Result"] == "true"){
        smaApiModel = smaApiModelFromJson(response.body);
        isLoading = false;
        update();
      }
      else{
        Get.back();
        Fluttertoast.showToast(msg: "${data["Result"]}");
      }
    }
    else{
      Get.back();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Something went Wrong....!!!")));
    }
  }
}