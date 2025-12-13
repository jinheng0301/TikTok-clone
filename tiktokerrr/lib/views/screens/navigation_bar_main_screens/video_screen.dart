import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
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

  Widget buildProfile(String profilePhoto) {
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
                borderRadius: BorderRadius.circular(25),
                child: Image.network(
                  profilePhoto,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey,
                      child: const Icon(Icons.person, color: Colors.white),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMusicAlbum(String profilePhoto) {
    return SizedBox(
      width: 60,
      height: 60,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(11),
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.grey, Colors.white],
              ),
              borderRadius: BorderRadius.circular(25),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Image.network(
                profilePhoto,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey,
                    child: const Icon(Icons.music_note,
                        color: Colors.white, size: 20),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {},
                child: const Text('Following '),
              ),
              const Icon(Icons.vertical_align_center),
              GestureDetector(
                onTap: () {},
                child: const Text(' For You'),
              ),
            ],
          ),
        ),
      ),
      body: Obx(() {
        print('📺 Building VideoScreen UI');
        print('isLoading: ${_videoController.isLoading.value}');
        print('videoList length: ${_videoController.videoList.length}');

        // Show loading on initial load
        if (_videoController.isLoading.value &&
            _videoController.videoList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LoadingAnimationWidget.dotsTriangle(
                  color: Colors.red,
                  size: 40,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Loading videos...',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          );
        }

        // Show empty state
        if (_videoController.videoList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.video_library_outlined,
                  size: 80,
                  color: Colors.grey,
                ),
                const SizedBox(height: 20),
                const Text(
                  'No videos available',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Upload some videos to get started',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: () {
                    print('🔄 Refresh button pressed');
                    _videoController.refreshVideos();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // Show videos
        print('✅ Showing ${_videoController.videoList.length} videos');

        return PageView.builder(
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.vertical,
          itemCount: _videoController.videoList.length,
          controller: PageController(
            initialPage: 0,
            viewportFraction: 1,
          ),
          onPageChanged: (index) {
            print('📄 Page changed to index: $index');
            if (index >= _videoController.videoList.length - 2) {
              print('📥 Near end, loading more videos...');
              _videoController.loadMoreVideos();
            }
          },
          itemBuilder: (context, index) {
            final data = _videoController.videoList[index];
            print('🎬 Building video at index $index: ${data.username}');

            return Stack(
              children: [
                // Video player with double tap to like
                GestureDetector(
                  onDoubleTap: () {
                    print('❤️ Double tap on video: ${data.id}');
                    _videoController.likeVideo(data.id);
                    setState(() {
                      isLikeAnimating = true;
                    });
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      VideoPlayerItem(
                        videoUrl: data.videoUrl,
                        key: ValueKey(data.id),
                      ),
                      AnimatedOpacity(
                        opacity: isLikeAnimating ? 1 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: LikeAnimation(
                          isAnimating: isLikeAnimating,
                          duration: const Duration(milliseconds: 400),
                          onEnd: () {
                            setState(() {
                              isLikeAnimating = false;
                            });
                          },
                          child: const Icon(
                            Icons.favorite,
                            color: Colors.white,
                            size: 120,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Bottom info overlay - FIXED LAYOUT
                SafeArea(
                  child: Column(
                    children: [
                      const Spacer(),
                      // Bottom section with user info and actions
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Left side - User info
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 20),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                        style: const TextStyle(
                                          fontSize: 20,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      data.caption,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: Colors.white,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 5),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.music_note,
                                          size: 15,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 5),
                                        Expanded(
                                          child: Text(
                                            data.songName,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Right side - Action buttons
                            Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Profile photo
                                  buildProfile(data.profilePhoto),
                                  const SizedBox(height: 20),

                                  // Like button
                                  InkWell(
                                    onTap: () =>
                                        _videoController.likeVideo(data.id),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.favorite,
                                          size: 35,
                                          color: data.likes.contains(
                                                  authController.user.uid)
                                              ? Colors.red
                                              : Colors.white,
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          data.likes.length.toString(),
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  // Comment button
                                  InkWell(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (builder) => CommentScreen(
                                            id: data.id,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.comment,
                                          size: 35,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          data.commentCount.toString(),
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  // Collect/Save button
                                  InkWell(
                                    onTap: () {},
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.star,
                                          size: 35,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          data.collectCount?.toString() ?? '0',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  // Share button
                                  InkWell(
                                    onTap: () {},
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.reply,
                                          size: 35,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          data.shareCount.toString(),
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  // Music album animation
                                  CircleAnimation(
                                    child: buildMusicAlbum(data.profilePhoto),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      }),
    );
  }
}
