import 'dart:async';
import 'package:arts/screens/auth-ui/welcome-screen.dart';
import 'package:arts/screens/user-panel/main-screen.dart';
import 'package:arts/services/notification_service.dart';
import 'package:arts/utils/app-constant.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key); // Use Key? for nullable 

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  NotificationService notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    getToken();

    Timer(Duration(seconds: 3), () {
      if (user != null) {
        Get.offAll(() => MainScreen());
      } else {
        Get.offAll(() => WelcomeScreen());
      }
    });
  }

  getToken() async {
    String userDeviceToken = await notificationService.getDeviceToken();
    print("token => $userDeviceToken");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstant.appScendoryColor,
      appBar: AppBar(
        backgroundColor: AppConstant.appScendoryColor,
        elevation: 0,
      ),
      body: Container(
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: Get.width,
                alignment: Alignment.center,
                child: Lottie.asset('assets/images/splash-icon.json'),
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
              width: Get.width,
              alignment: Alignment.center,
              child: Text(
                AppConstant.appPoweredBy,
                style: TextStyle(
                  color: AppConstant.appTextColor,
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
