import 'package:flutter/material.dart';
import 'package:tiktokerrr/constants.dart';
import 'package:tiktokerrr/controllers/auth_controller.dart';
import 'package:tiktokerrr/views/screens/home_screen.dart';
import 'package:tiktokerrr/views/screens/login_screen.dart';
import 'package:tiktokerrr/views/screens/signup_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyBRMEJ30MFASnvmS-PFPRskoasllF1i2RA',
      appId: '1:708553469404:android:ac238f5f2ca72c06f7f319',
      messagingSenderId: '708553469404',
      projectId: 'tiktok-clone-c61ea',
      storageBucket: 'tiktok-clone-c61ea.appspot.com'
    ),
  ).then(
    (value) => Get.put(
      AuthController(),
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'tik tok',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: backgroundColor,
      ),
      home: HomeScreen(),
    );
  }
}
