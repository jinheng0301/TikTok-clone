import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tiktokerrr/constants.dart';
import 'package:tiktokerrr/controllers/profile_controller.dart';
import 'package:tiktokerrr/views/widgets/custom_Icon.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int pageIndex = 0;
  final ProfileController profileController = Get.put(ProfileController());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    profileController.updateUserId(authController.user.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[pageIndex], // variable pages in constants.dart
      bottomNavigationBar: BottomNavigationBar(
        onTap: (value) {
          setState(() {
            pageIndex = value;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: backgroundColor,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.white,
        currentIndex: pageIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              size: 30,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.search,
              size: 30,
            ),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: CustomIcon(),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.message,
              size: 30,
            ),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: profileController.user['profilePhoto'] != null
                ? CircleAvatar(
                  radius: 15,
                    backgroundImage: NetworkImage(
                      profileController.user['profilePhoto'],
                    ),
                  )
                : Icon(
                    Icons.person,
                    size: 30,
                  ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
