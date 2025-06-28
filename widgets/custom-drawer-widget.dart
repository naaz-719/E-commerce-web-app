// ignore_for_file: file_names, prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last, no_leading_underscores_for_local_identifiers

import 'package:arts/ai/ai_chatbot_screen.dart';
import 'package:arts/ai/ai_image_generator.dart';
import 'package:arts/screens/user-panel/all-orders-screen.dart';
import 'package:arts/screens/user-panel/all-products-screen.dart';
import 'package:arts/screens/user-panel/main-screen.dart';
import 'package:arts/utils/app-constant.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:arts/screens/auth-ui/welcome-screen.dart';

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({super.key});

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  String selectedLang = 'en'; // Default language

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: Get.height / 25),
      child: Drawer(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(20.0),
            bottomRight: Radius.circular(20.0),
          ),
        ),
        child: Wrap(
          runSpacing: 10,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
              child: ListTile(
                titleAlignment: ListTileTitleAlignment.center,
                title: Text(
                  "Sadaf Arts Studio",
                  style: TextStyle(color: AppConstant.appTextColor),
                ),
                subtitle: Text(
                  "Online Shopping",
                  style: TextStyle(color: AppConstant.appTextColor),
                ),
                leading: CircleAvatar(
                  radius: 22.0,
                  backgroundColor: AppConstant.appMainColor,
                  child: Text(
                    "S",
                    style: TextStyle(color: AppConstant.appTextColor),
                  ),
                ),
              ),
            ),
            Divider(
              indent: 10.0,
              endIndent: 10.0,
              thickness: 1.5,
              color: Colors.grey,
            ),
            drawerTile("Home".tr, Icons.home, () => MainScreen()),
            drawerTile("Products".tr, Icons.production_quantity_limits, () => AllProductsScreen()),
            drawerTile("Orders".tr, Icons.shopping_bag, () => AllOrdersScreen()),
            drawerTile("AI Service".tr, Icons.chat, () => AIChatbotScreen()),
            drawerTile("Customization".tr, Icons.mode_edit, () => const AiImageGenerator()),

            // Language Selection
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.translate, color: AppConstant.appTextColor),
                      SizedBox(width: 10),
                      Text(
                        "Language".tr,
                        style: TextStyle(color: AppConstant.appTextColor),
                      ),
                    ],
                  ),
                  DropdownButton<String>(
                    value: selectedLang,
                    dropdownColor: AppConstant.appScendoryColor,
                    iconEnabledColor: AppConstant.appTextColor,
                    items: <String>['en', 'hi', 'fr', 'es', 'de'].map((langCode) {
                      return DropdownMenuItem<String>(
                        value: langCode,
                        child: Text(
                          langCode.toUpperCase(),
                          style: TextStyle(color: AppConstant.appTextColor),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedLang = value!;
                        // Update the locale using GetX
                        Locale newLocale;
                        switch (selectedLang) {
                          case 'hi':
                            newLocale = const Locale('hi', 'IN');
                            break;
                          case 'fr':
                            newLocale = const Locale('fr', 'FR');
                            break;
                          case 'es':
                            newLocale = const Locale('es', 'ES');
                            break;
                          case 'de':
                            newLocale = const Locale('de', 'DE');
                            break;
                          default:
                            newLocale = const Locale('en', 'US');
                        }
                        Get.updateLocale(newLocale);
                      });
                    },
                  ),
                ],
              ),
            ),

            // Logout
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: ListTile(
                onTap: () async {
                  GoogleSignIn googleSignIn = GoogleSignIn();
                  FirebaseAuth _auth = FirebaseAuth.instance;
                  await _auth.signOut();
                  await googleSignIn.signOut();
                  Get.offAll(() => WelcomeScreen());
                },
                titleAlignment: ListTileTitleAlignment.center,
                title: Text(
                  "Logout".tr,
                  style: TextStyle(color: AppConstant.appTextColor),
                ),
                leading: Icon(
                  Icons.logout,
                  color: AppConstant.appTextColor,
                ),
                trailing: Icon(
                  Icons.arrow_forward,
                  color: AppConstant.appTextColor,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppConstant.appScendoryColor,
      ),
    );
  }

  Widget drawerTile(String title, IconData icon, Widget Function() navigateTo) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: ListTile(
        titleAlignment: ListTileTitleAlignment.center,
        title: Text(title, style: TextStyle(color: AppConstant.appTextColor)),
        leading: Icon(icon, color: AppConstant.appTextColor),
        trailing: Icon(Icons.arrow_forward, color: AppConstant.appTextColor),
        onTap: () {
          Get.back();
          Get.to(navigateTo());
        },
      ),
    );
  }
}
