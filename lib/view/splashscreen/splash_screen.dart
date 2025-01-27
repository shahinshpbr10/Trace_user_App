
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';





class Splase_Screen extends StatefulWidget {
  const Splase_Screen({super.key});

  @override
  State<Splase_Screen> createState() => _Splase_ScreenState();
}

class _Splase_ScreenState extends State<Splase_Screen> {

  bool? isLogin;
  @override
  void initState() {
    super.initState();
    getDataFromLocal().then((value) {
      if(isLogin!){
        Timer(const Duration(seconds: 3), () {
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) =>   const Placeholder(),), (route) => false);
        });
      } else{
        Timer(const Duration(seconds: 3), () {
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) =>  const Placeholder(),), (route) => false);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return   const Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(image: AssetImage('assets/SplaseScreenImage.png'),height: 150,width: 150),
            Text('Trace',style: TextStyle(color: Color(0xff7D2AFF),fontSize: 25,fontFamily: 'SofiaProBold'),),
            SizedBox(height: 8,),
            Text(
              "Manage • Track • Travel",
              style: TextStyle(color: Color(0xff7D2AFF),fontSize: 15,fontFamily: 'SofiaProBold'),
            ),

          ],
        ),
      ),
    );
  }


  Future getDataFromLocal() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isLogin = prefs.getBool("isLogin") ?? true;
    });
  }

}