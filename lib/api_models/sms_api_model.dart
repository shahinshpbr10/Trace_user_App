// To parse this JSON data, do
//
//     final smaApiModel = smaApiModelFromJson(jsonString);

import 'dart:convert';

SmaApiModel smaApiModelFromJson(String str) => SmaApiModel.fromJson(json.decode(str));

String smaApiModelToJson(SmaApiModel data) => json.encode(data.toJson());

class SmaApiModel {
  String? responseCode;
  String? result;
  String? responseMsg;
  String? smsType;
  String? otpAuth;

  SmaApiModel({
    this.responseCode,
    this.result,
    this.responseMsg,
    this.smsType,
    this.otpAuth,
  });

  factory SmaApiModel.fromJson(Map<String, dynamic> json) => SmaApiModel(
    responseCode: json["ResponseCode"],
    result: json["Result"],
    responseMsg: json["ResponseMsg"],
    smsType: json["SMS_TYPE"],
    otpAuth: json["otp_auth"],
  );

  Map<String, dynamic> toJson() => {
    "ResponseCode": responseCode,
    "Result": result,
    "ResponseMsg": responseMsg,
    "SMS_TYPE": smsType,
    "otp_auth": otpAuth,
  };
}
