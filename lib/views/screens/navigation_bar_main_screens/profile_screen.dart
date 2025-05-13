import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:tiktokerrr/constants.dart';
import 'package:tiktokerrr/controllers/profile_controller.dart';
import 'package:tiktokerrr/views/screens/auth_screens/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  late final String uid;
  ProfileScreen({required this.uid});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileController _profileController = Get.put(ProfileController());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _profileController.updateUserId(widget.uid);
  }

  Future<void> _showDialogBox() async {
    return PanaraConfirmDialog.show(
      context,
      title: 'Log out',
      message: 'Log out mou?',
      confirmButtonText: 'Conlan7firm!',
      onTapConfirm: () async {
        authController.signOut();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => LoginScreen(),
          ),
        );
      },
      cancelButtonText: 'Bukanlah balik!',
      onTapCancel: () {
        Navigator.of(context).pop();
      },
      padding: EdgeInsets.all(10),
      panaraDialogType: PanaraDialogType.warning,
      barrierDismissible: false,
      // Optional: Prevents dialog from closing when tapped outside
      textColor: Colors.amber,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(
      builder: (controller) {
        if (controller.user.isEmpty) {
          return Center(
            child: LoadingAnimationWidget.newtonCradle(
              color: Colors.yellow,
              size: 40,
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.black12,
            leading: Icon(
              Icons.person_add_alt,
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Icon(
                  Icons.more_horiz,
                ),
              ),
            ],
            title: Text(
              controller.user['name'],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: SafeArea(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: controller.user['profilePhoto'],
                          fit: BoxFit.cover,
                          height: 100,
                          width: 100,
                          placeholder: (context, url) =>
                              CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Text(
                            controller.user['following'],
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Following',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        color: Colors.black54,
                        width: 1,
                        height: 15,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 15,
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            controller.user['followers'],
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Followers',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        color: Colors.black54,
                        width: 1,
                        height: 15,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 15,
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            controller.user['likes'],
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Likes',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  Container(
                    width: 140,
                    height: 47,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black12,
                      ),
                    ),
                    child: InkWell(
                      onTap: () {
                        if (widget.uid == authController.user.uid) {
                          _showDialogBox();
                        } else {
                          // whenever we click the button,
                          // we should follow the user
                          controller.followUser();
                        }
                      },
                      child: Center(
                        child: Text(
                          widget.uid == authController.user.uid
                              ? 'Sign out'
                              : controller.user['isFollowing']
                                  ? 'Unfollow'
                                  : 'Follow',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // video list
                  GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1,
                      crossAxisSpacing: 5,
                    ),
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: controller.user['thumbnails'].length,
                    itemBuilder: (context, index) {
                      String thumbnail = controller.user['thumbnails'][index];

                      return CachedNetworkImage(
                        imageUrl: thumbnail,
                        fit: BoxFit.contain,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
