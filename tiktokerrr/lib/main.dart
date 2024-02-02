import 'package:flutter/material.dart';
import 'package:tiktokerrr/constants.dart';
import 'package:tiktokerrr/views/login_screen.dart';
import 'package:tiktokerrr/views/signup_screen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  await WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'tik tok',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: backgroundColor,
      ),
      home: SignUpScreen(),
    );
  }
}
