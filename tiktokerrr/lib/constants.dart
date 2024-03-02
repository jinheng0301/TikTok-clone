import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:tiktokerrr/controllers/auth_controller.dart';
import 'package:tiktokerrr/views/screens/navigation_bar_main_screens/add_video_screen.dart';
import 'package:tiktokerrr/views/screens/navigation_bar_main_screens/messages_screen.dart';
import 'package:tiktokerrr/views/screens/navigation_bar_main_screens/profile_screen.dart';
import 'package:tiktokerrr/views/screens/navigation_bar_main_screens/search_screen.dart';
import 'package:tiktokerrr/views/screens/navigation_bar_main_screens/video_screen.dart';

// COLORS
const backgroundColor = Colors.black;
var buttonColor = Colors.red[400];
const borderColor = Colors.grey;

// FIREBASE
var firebaseAuth = FirebaseAuth.instance;
var firebaseStorage = FirebaseStorage.instance;
var firestore = FirebaseFirestore.instance;

// CONTROLLER
var authController = AuthController.instance;

// SCREENS
List pages = [
  VideoScreen(),
  SearchScreen(),
  AddVideoScreen(),
  MessagesScreen(),
  ProfileScreen(uid: authController.user.uid),
];
