import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:tiktokerrr/constants.dart';
import 'package:tiktokerrr/controllers/profile_controller.dart';
import 'package:tiktokerrr/views/screens/auth_screens/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;
  const ProfileScreen({Key? key, required this.uid}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileController _profileController = Get.put(ProfileController());

  @override
  void initState() {
    super.initState();
    _profileController.updateUserId(widget.uid);
  }

  Future<void> _showDialogBox() async {
    return PanaraConfirmDialog.show(
      context,
      title: 'Log out',
      message: 'Log out mou?',
      confirmButtonText: 'Confirm!',
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
      textColor: Colors.amber,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use Obx instead of GetBuilder for better performance with Rx
    return Obx(() {
      if (_profileController.isLoading.value ||
          _profileController.user.isEmpty) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: LoadingAnimationWidget.newtonCradle(
              color: Colors.yellow,
              size: 40,
            ),
          ),
        );
      }

      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black12,
          leading: Icon(Icons.person_add_alt),
          actions: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Icon(Icons.more_horiz),
            ),
          ],
          title: Text(
            _profileController.user['name'],
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  SizedBox(height: 20),
                  // Profile Photo
                  ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: _profileController.user['profilePhoto'],
                      fit: BoxFit.cover,
                      height: 100,
                      width: 100,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[800],
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[800],
                        child:
                            Icon(Icons.person, size: 50, color: Colors.white),
                      ),
                      memCacheHeight: 200, // Optimize memory usage
                      memCacheWidth: 200,
                    ),
                  ),
                  SizedBox(height: 15),
                  // Stats Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStatColumn(
                        _profileController.user['following'],
                        'Following',
                      ),
                      _buildDivider(),
                      _buildStatColumn(
                        _profileController.user['followers'],
                        'Followers',
                      ),
                      _buildDivider(),
                      _buildStatColumn(
                        _profileController.user['likes'],
                        'Likes',
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  // Follow/Sign Out Button
                  Container(
                    width: 140,
                    height: 47,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black12),
                    ),
                    child: InkWell(
                      onTap: () {
                        if (widget.uid == authController.user.uid) {
                          _showDialogBox();
                        } else {
                          _profileController.followUser();
                        }
                      },
                      child: Center(
                        child: Text(
                          widget.uid == authController.user.uid
                              ? 'Sign out'
                              : _profileController.user['isFollowing']
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
                  SizedBox(height: 10),
                ],
              ),
            ),
            // Video Grid - Using SliverGrid for better performance
            SliverPadding(
              padding: EdgeInsets.all(5),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7, // Better aspect ratio for videos
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final thumbnails =
                        _profileController.user['thumbnails'] as List;
                    if (index >= thumbnails.length) return null;

                    String thumbnail = thumbnails[index];

                    return CachedNetworkImage(
                      imageUrl: thumbnail,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[900],
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[900],
                        child: Icon(Icons.error, color: Colors.white),
                      ),
                      memCacheHeight: 400, // Optimize memory usage
                      memCacheWidth: 300,
                      maxHeightDiskCache: 400,
                      maxWidthDiskCache: 300,
                    );
                  },
                  childCount:
                      (_profileController.user['thumbnails'] as List).length,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStatColumn(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      color: Colors.black54,
      width: 1,
      height: 15,
      margin: const EdgeInsets.symmetric(horizontal: 15),
    );
  }

  @override
  void dispose() {
    // Clean up controller if needed
    super.dispose();
  }
}
