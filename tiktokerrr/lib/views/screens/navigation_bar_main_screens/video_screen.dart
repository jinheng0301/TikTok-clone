import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tiktokerrr/constants.dart';
import 'package:tiktokerrr/controllers/video_controller.dart';
import 'package:tiktokerrr/views/screens/extend_screens/comment_screen.dart';
import 'package:tiktokerrr/views/screens/navigation_bar_main_screens/profile_screen.dart';
import 'package:tiktokerrr/views/widgets/circle_animation.dart';
import 'package:tiktokerrr/views/widgets/like_animation.dart';
import 'package:tiktokerrr/views/widgets/video_player_item.dart';

class VideoScreen extends StatefulWidget {
  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  final VideoController _videoController = Get.put(VideoController());
  bool isLikeAnimating = false;

  buildProfile(String profilePhoto) {
    return SizedBox(
      width: 60,
      height: 60,
      child: Stack(
        children: [
          Positioned(
            left: 5,
            child: Container(
              width: 50,
              height: 50,
              padding: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: ClipRRect(
                // we can get some border radius
                borderRadius: BorderRadius.circular(25),
                child: Image(
                  image: NetworkImage(
                    profilePhoto,
                    scale: 1.0,
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  buildMusicAlbum(String profilePhoto) {
    return SizedBox(
      width: 60,
      height: 60,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(11),
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Colors.grey,
                  Colors.white,
                ],
              ),
              borderRadius: BorderRadius.circular(25),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Image(
                image: NetworkImage(
                  profilePhoto,
                  scale: 1.0,
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      body: Obx(
        // get the changes and listen to the value real time
        () {
          return PageView.builder(
            physics: BouncingScrollPhysics(),
            scrollDirection: Axis.vertical,
            itemCount: _videoController.videoList.length,
            controller: PageController(
              initialPage: _videoController.videoList.length - 1,
              viewportFraction: 1,
            ),
            itemBuilder: (context, index) {
              final data = _videoController.videoList.reversed.toList()[index];

              return Stack(
                children: [
                  GestureDetector(
                    // to detect the double click at the video when user click it
                    onDoubleTap: () => {
                      _videoController.likeVideo(
                        data.id,
                      ),
                      setState(() {
                        isLikeAnimating = true;
                      }),
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        VideoPlayerItem(videoUrl: data.videoUrl),
                        AnimatedOpacity(
                          opacity: isLikeAnimating ? 1 : 0,
                          duration: Duration(milliseconds: 200),
                          child: LikeAnimation(
                            child: Icon(
                              Icons.favorite,
                              color: Colors.white,
                              size: 120,
                            ),
                            isAnimating: isLikeAnimating,
                            duration: Duration(milliseconds: 400),
                            onEnd: () {
                              setState(() {
                                isLikeAnimating = false;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      SizedBox(height: 100),
                      Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.only(left: 20),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (builder) => ProfileScreen(
                                              uid: data.uid,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        data.username,
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      data.caption,
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.music_note,
                                          size: 15,
                                          color: Colors.white,
                                        ),
                                        Text(
                                          data.songName,
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              width: 80,
                              margin: EdgeInsets.only(top: size.height / 5),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  buildProfile(data.profilePhoto),
                                  Column(
                                    children: [
                                      InkWell(
                                        onTap: () => _videoController.likeVideo(
                                          data.id,
                                        ),
                                        child: Icon(
                                          Icons.favorite,
                                          size: 35,
                                          color: data.likes.contains(
                                                  authController.user.uid)
                                              ? Colors.red
                                              : Colors.white,
                                        ),
                                      ),
                                      SizedBox(height: 7),
                                      Text(
                                        '${data.likes.length.toString()} likes',
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.white,
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          // showModalBottomSheet(
                                          //   context: context,
                                          //   builder: (context) => Container(
                                          //     decoration: BoxDecoration(
                                          //       borderRadius: BorderRadius.only(
                                          //         topLeft: Radius.circular(20),
                                          //         topRight: Radius.circular(20),
                                          //       ),
                                          //     ),
                                          //     child: CommentScreen(
                                          //       id: data.id,
                                          //     ),
                                          //   ),
                                          // );
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (builder) =>
                                                  CommentScreen(id: data.id),
                                            ),
                                          );
                                        },
                                        child: Icon(
                                          Icons.comment,
                                          size: 35,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(height: 7),
                                      Text(
                                        data.commentCount.toString(),
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.white,
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {},
                                        child: Icon(
                                          Icons.star,
                                          size: 35,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(height: 7),
                                      Text(
                                        data.collectCount != null
                                            ? data.collectCount.toString()
                                            : '0',
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.white,
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {},
                                        child: Icon(
                                          Icons.reply,
                                          size: 35,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(height: 7),
                                      Text(
                                        data.shareCount.toString(),
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  CircleAnimation(
                                    child: buildMusicAlbum(data.profilePhoto),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  )
                ],
              );
            },
          );
        },
      ),
    );
  }
}
