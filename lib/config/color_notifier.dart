import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ColorNotifier extends ChangeNotifier {
  Color background = Colors.white;
  Color theamcolorelight = const Color(0xff7D2AFF);
  Color textColor = Colors.black;
  Color containercolore = Colors.white;
}

extension StringExtension on String {
  String tr() {
    return this; // Replace with your translation logic
  }
}