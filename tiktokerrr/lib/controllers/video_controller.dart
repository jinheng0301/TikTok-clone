import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tiktokerrr/constants.dart';
import 'package:tiktokerrr/models/video.dart';

class VideoController extends GetxController {
  final Rx<List<Video>> _videoList = Rx<List<Video>>([]);
  List<Video> get videoList => _videoList.value;

  final RxBool isLoading = false.obs;
  bool _hasMore = true;
  DocumentSnapshot? _lastDocument;
  final int _pageSize = 10;

  @override
  void onInit() {
    super.onInit();
    print('🎮 VideoController initialized');
    print('Firestore instance: ${"Connected"}');
    print('Auth user: ${authController.user.uid}');
    loadInitialVideos();
  }

  Future<void> loadInitialVideos() async {
    print('========================================');
    print('🎬 loadInitialVideos() called');
    print('Current isLoading: ${isLoading.value}');

    if (isLoading.value) {
      print('⚠️ Already loading, returning early');
      return;
    }

    isLoading.value = true;
    print('✅ Set isLoading to true');

    try {
      print('📡 Attempting to fetch from Firestore...');
      print('Collection: videos');
      print('📊 Sorting: Latest videos first (by timestamp/id)');

      // Query with orderBy to get latest videos first
      // Note: You need to have a 'timestamp' field in your video documents
      // If you don't have timestamp, we'll sort by document ID descending
      QuerySnapshot querySnapshot = await firestore
          .collection('videos')
          .orderBy(FieldPath.documentId, descending: true)
          .limit(_pageSize)
          .get();

      print('📦 Query completed');
      print('Documents returned: ${querySnapshot.docs.length}');

      if (querySnapshot.docs.isEmpty) {
        print('❌ NO DOCUMENTS FOUND!');
        print('');
        print('⚠️ TROUBLESHOOTING CHECKLIST:');
        print('1. Check Firebase Console > Firestore > Data tab');
        print('2. Verify collection name is exactly "videos"');
        print('3. Confirm you have uploaded videos');
        print('4. Check Firestore Rules');
        print('5. Verify internet connection');
        print('');

        _hasMore = false;
        isLoading.value = false;

        Get.snackbar(
          'No Videos',
          'No videos found in database. Please upload some videos first.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.withOpacity(0.8),
          colorText: Colors.white,
          duration: Duration(seconds: 5),
        );
        return;
      }

      print('✅ Found ${querySnapshot.docs.length} videos');

      // Debug first document (should be the latest)
      var firstDoc = querySnapshot.docs.first;
      print('');
      print('📄 First Document Details (Latest Video):');
      print('  ID: ${firstDoc.id}');
      print(
          '  Username: ${(firstDoc.data() as Map<String, dynamic>)['username']}');
      print('');

      var lastDoc = querySnapshot.docs.last;
      print('📄 Last Document Details (Oldest in this batch):');
      print('  ID: ${lastDoc.id}');
      print(
          '  Username: ${(lastDoc.data() as Map<String, dynamic>)['username']}');
      print('');

      _lastDocument = querySnapshot.docs.last;

      List<Video> videos = [];
      for (var doc in querySnapshot.docs) {
        try {
          var data = doc.data() as Map<String, dynamic>;
          Video video = Video.fromSnap(doc);
          videos.add(video);
          print('  ✅ Added: ${doc.id} - ${data['username']}');
        } catch (e, stackTrace) {
          print('  ❌ Error parsing video ${doc.id}:');
          print('  Error: $e');
          print('  Stack: $stackTrace');
        }
      }

      if (videos.isEmpty) {
        print('❌ All videos failed to parse!');
        Get.snackbar(
          'Error',
          'Videos found but failed to load. Check Video model.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
        );
      } else {
        _videoList.value = videos;
        print('✅ Successfully loaded ${videos.length} videos');
        print('🔝 Order: Latest → Oldest');
      }
    } catch (e, stackTrace) {
      print('❌ CRITICAL ERROR:');
      print('Error: $e');
      print('Stack trace: $stackTrace');

      String errorMsg = e.toString();

      // Check if it's an index error
      if (errorMsg.contains('index') ||
          errorMsg.contains('FAILED_PRECONDITION')) {
        print('📑 INDEX REQUIRED!');
        print('');
        print('⚠️ You need to create a Firestore index:');
        print('1. Check the error message for the index creation link');
        print('2. Or manually create index in Firebase Console:');
        print('   Collection: videos');
        print('   Field: __name__ (Document ID)');
        print('   Order: Descending');
        print('');

        // Fallback: Try without ordering
        print('🔄 Attempting fallback query without ordering...');
        try {
          QuerySnapshot fallbackQuery =
              await firestore.collection('videos').limit(_pageSize).get();

          if (fallbackQuery.docs.isNotEmpty) {
            _lastDocument = fallbackQuery.docs.last;
            List<Video> videos =
                fallbackQuery.docs.map((doc) => Video.fromSnap(doc)).toList();

            // Sort in memory by document ID (descending for latest first)
            videos.sort((a, b) => b.id.compareTo(a.id));

            _videoList.value = videos;
            print(
                '✅ Loaded ${videos.length} videos with fallback (sorted in memory)');
            print(
                '⚠️ Please create the Firestore index for better performance');
          }
        } catch (fallbackError) {
          print('❌ Fallback also failed: $fallbackError');
        }

        // Get.snackbar(
        //   'Index Required',
        //   'Creating Firestore index... Using temporary sorting.',
        //   snackPosition: SnackPosition.BOTTOM,
        //   backgroundColor: Colors.orange.withOpacity(0.8),
        //   colorText: Colors.white,
        //   duration: Duration(seconds: 5),
        // );
      } else if (errorMsg.contains('PERMISSION_DENIED')) {
        print('🔒 PERMISSION DENIED - Check Firestore Rules!');
        Get.snackbar(
          'Permission Denied',
          'Cannot access Firestore. Check your security rules.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
          duration: Duration(seconds: 5),
        );
      } else if (errorMsg.contains('network') ||
          errorMsg.contains('UNAVAILABLE')) {
        print('🌐 NETWORK ERROR - Check internet connection');
        Get.snackbar(
          'Connection Error',
          'Cannot connect to Firebase. Check your internet.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
          duration: Duration(seconds: 5),
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to load videos: $errorMsg',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
          duration: Duration(seconds: 5),
        );
      }
    } finally {
      isLoading.value = false;
      print('🏁 loadInitialVideos() finished');
      print('Final video count: ${_videoList.value.length}');
      print('========================================');
    }
  }

  Future<void> loadMoreVideos() async {
    if (isLoading.value || !_hasMore || _lastDocument == null) {
      print(
          '⚠️ Cannot load more: isLoading=$isLoading, hasMore=$_hasMore, lastDoc=${_lastDocument != null}');
      return;
    }

    print('📥 Loading more videos...');
    print('📄 Starting after document: ${_lastDocument!.id}');
    isLoading.value = true;

    try {
      QuerySnapshot querySnapshot = await firestore
          .collection('videos')
          .orderBy(FieldPath.documentId, descending: true)
          .startAfterDocument(_lastDocument!)
          .limit(_pageSize)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print('✅ No more videos to load');
        _hasMore = false;
        isLoading.value = false;
        return;
      }

      _lastDocument = querySnapshot.docs.last;

      List<Video> newVideos =
          querySnapshot.docs.map((doc) => Video.fromSnap(doc)).toList();

      _videoList.value = [..._videoList.value, ...newVideos];
      print('✅ Loaded ${newVideos.length} more videos');
      print('📊 Total videos now: ${_videoList.value.length}');
    } catch (e) {
      print('❌ Error loading more videos: $e');

      // If index error, try fallback
      if (e.toString().contains('index')) {
        print('🔄 Trying fallback for pagination...');
        try {
          QuerySnapshot fallbackQuery = await firestore
              .collection('videos')
              .startAfterDocument(_lastDocument!)
              .limit(_pageSize)
              .get();

          if (fallbackQuery.docs.isNotEmpty) {
            _lastDocument = fallbackQuery.docs.last;
            List<Video> newVideos =
                fallbackQuery.docs.map((doc) => Video.fromSnap(doc)).toList();
            _videoList.value = [..._videoList.value, ...newVideos];
            print('✅ Loaded ${newVideos.length} more videos (fallback)');
          }
        } catch (fallbackError) {
          print('❌ Fallback pagination failed: $fallbackError');
        }
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> likeVideo(String id) async {
    try {
      var uid = authController.user.uid;
      print('❤️ Like video: $id by user: $uid');

      int videoIndex = _videoList.value.indexWhere((video) => video.id == id);
      if (videoIndex == -1) {
        print('❌ Video not found in list');
        return;
      }

      Video currentVideo = _videoList.value[videoIndex];
      List<String> updatedLikes = List.from(currentVideo.likes);

      if (updatedLikes.contains(uid)) {
        updatedLikes.remove(uid);
        print('💔 Removing like');
      } else {
        updatedLikes.add(uid);
        print('❤️ Adding like');
      }

      // Update UI immediately
      _videoList.value[videoIndex] = Video(
        username: currentVideo.username,
        uid: currentVideo.uid,
        id: currentVideo.id,
        likes: updatedLikes,
        commentCount: currentVideo.commentCount,
        shareCount: currentVideo.shareCount,
        songName: currentVideo.songName,
        caption: currentVideo.caption,
        videoUrl: currentVideo.videoUrl,
        profilePhoto: currentVideo.profilePhoto,
        thumbnail: currentVideo.thumbnail,
        collectCount: currentVideo.collectCount,
      );
      _videoList.refresh();

      // Update Firestore
      DocumentSnapshot doc = await firestore.collection('videos').doc(id).get();

      if ((doc.data()! as dynamic)['likes'].contains(uid)) {
        await firestore.collection('videos').doc(id).update({
          'likes': FieldValue.arrayRemove([uid]),
        });
      } else {
        await firestore.collection('videos').doc(id).update({
          'likes': FieldValue.arrayUnion([uid]),
        });
      }

      print('✅ Like updated successfully');
    } catch (e) {
      print('❌ Error liking video: $e');
      Get.snackbar(
        'Error',
        'Failed to update like',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
        duration: Duration(seconds: 2),
      );
    }
  }

  Future<void> refreshVideos() async {
    print('🔄 Refreshing videos...');
    _videoList.value = [];
    _lastDocument = null;
    _hasMore = true;
    await loadInitialVideos();
  }

  @override
  void onClose() {
    super.onClose();
    print('🛑 VideoController closed');
  }
}
