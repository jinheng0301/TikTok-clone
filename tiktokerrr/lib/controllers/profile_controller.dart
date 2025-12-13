import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tiktokerrr/constants.dart';

class ProfileController extends GetxController {
  final Rx<Map<String, dynamic>> _user = Rx<Map<String, dynamic>>({});
  Map<String, dynamic> get user => _user.value;

  final RxBool isLoading = false.obs;
  Rx<String> _uid = "".obs;

  void updateUserId(String uid) {
    _uid.value = uid;
    getUserData();
  }

  void getUserData() async {
    if (_uid.value.isEmpty) {
      print('❌ ProfileController: UID is empty');
      return;
    }

    print('👤 ProfileController: Loading user data for ${_uid.value}');
    isLoading.value = true;

    try {
      // Use Future.wait to parallelize Firebase queries
      final results = await Future.wait([
        // Get user's videos
        firestore
            .collection('videos')
            .where('uid', isEqualTo: _uid.value)
            .get(),
        // Get user document
        firestore.collection('users').doc(_uid.value).get(),
        // Get followers count
        firestore
            .collection('users')
            .doc(_uid.value)
            .collection('followers')
            .get(),
        // Get following count
        firestore
            .collection('users')
            .doc(_uid.value)
            .collection('following')
            .get(),
        // Check if current user is following
        firestore
            .collection('users')
            .doc(_uid.value)
            .collection('followers')
            .doc(authController.user.uid)
            .get(),
      ]);

      final myVideos = results[0] as QuerySnapshot;
      final userDoc = results[1] as DocumentSnapshot;
      final followerDoc = results[2] as QuerySnapshot;
      final followingDoc = results[3] as QuerySnapshot;
      final isFollowingDoc = results[4] as DocumentSnapshot;

      print('📹 Found ${myVideos.docs.length} videos for user');

      if (!userDoc.exists) {
        print('❌ User document does not exist');
        Get.snackbar(
          'Error',
          'User not found',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
        );
        isLoading.value = false;
        return;
      }

      final userData = userDoc.data() as Map<String, dynamic>?;
      if (userData == null) {
        print('❌ User data is null');
        isLoading.value = false;
        return;
      }

      // Process thumbnails more efficiently
      List<String> thumbnails = myVideos.docs
          .map((doc) {
            try {
              final thumbnail = doc.data()?['thumbnail'];
              return thumbnail != null && thumbnail.isNotEmpty
                  ? thumbnail as String
                  : null;
            } catch (e) {
              print('⚠️ Error getting thumbnail: $e');
              return null;
            }
          })
          .where((thumbnail) => thumbnail != null)
          .cast<String>()
          .toList();

      // Calculate total likes efficiently
      int likes = myVideos.docs.fold<int>(0, (sum, doc) {
        try {
          final videoLikes = doc.data()['likes'];
          if (videoLikes is List) {
            return sum + videoLikes.length;
          }
        } catch (e) {
          print('⚠️ Error calculating likes: $e');
        }
        return sum;
      });

      String name = userData['name'] ?? 'Unknown User';
      String profilePhoto = userData['profilePhoto'] ?? '';
      int followers = followerDoc.docs.length;
      int following = followingDoc.docs.length;
      bool isFollowing = isFollowingDoc.exists;

      print('👥 Followers: $followers');
      print('👤 Following: $following');
      print('💙 Is following: $isFollowing');

      _user.value = {
        'followers': followers.toString(),
        'following': following.toString(),
        'isFollowing': isFollowing,
        'likes': likes.toString(),
        'profilePhoto': profilePhoto,
        'name': name,
        'thumbnails': thumbnails,
      };

      print('✅ Profile data loaded successfully');
      // Remove update() call - not needed with Rx
    } catch (e, stackTrace) {
      print('❌ Critical error in getUserData: $e');
      print('Stack trace: $stackTrace');

      String errorMsg = e.toString();
      if (errorMsg.contains('PERMISSION_DENIED')) {
        Get.snackbar(
          'Permission Denied',
          'Cannot access user data. Check Firestore security rules.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
          duration: Duration(seconds: 5),
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to load profile: $errorMsg',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  void followUser() async {
    if (_uid.value.isEmpty) {
      print('❌ Cannot follow: UID is empty');
      return;
    }

    if (_uid.value == authController.user.uid) {
      Get.snackbar(
        'Invalid Action',
        'You cannot follow yourself',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }

    print('🔄 followUser called for ${_uid.value}');

    try {
      var doc = await firestore
          .collection('users')
          .doc(_uid.value)
          .collection('followers')
          .doc(authController.user.uid)
          .get();

      if (!doc.exists) {
        print('➕ Following user...');

        // Use batch write for atomic operations
        WriteBatch batch = firestore.batch();

        batch.set(
          firestore
              .collection('users')
              .doc(_uid.value)
              .collection('followers')
              .doc(authController.user.uid),
          {'timestamp': FieldValue.serverTimestamp()},
        );

        batch.set(
          firestore
              .collection('users')
              .doc(authController.user.uid)
              .collection('following')
              .doc(_uid.value),
          {'timestamp': FieldValue.serverTimestamp()},
        );

        await batch.commit();

        // Update local state
        final currentFollowers = int.parse(_user.value['followers'] ?? '0');
        _user.value = {
          ..._user.value,
          'followers': (currentFollowers + 1).toString(),
          'isFollowing': true,
        };

        print('✅ Successfully followed user');

        Get.snackbar(
          'Success',
          'You are now following ${_user.value['name']}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
          duration: Duration(seconds: 2),
        );
      } else {
        print('➖ Unfollowing user...');

        // Use batch write for atomic operations
        WriteBatch batch = firestore.batch();

        batch.delete(
          firestore
              .collection('users')
              .doc(_uid.value)
              .collection('followers')
              .doc(authController.user.uid),
        );

        batch.delete(
          firestore
              .collection('users')
              .doc(authController.user.uid)
              .collection('following')
              .doc(_uid.value),
        );

        await batch.commit();

        // Update local state
        final currentFollowers = int.parse(_user.value['followers'] ?? '0');
        _user.value = {
          ..._user.value,
          'followers': (currentFollowers - 1).toString(),
          'isFollowing': false,
        };

        print('✅ Successfully unfollowed user');

        Get.snackbar(
          'Success',
          'You unfollowed ${_user.value['name']}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.grey.withOpacity(0.8),
          colorText: Colors.white,
          duration: Duration(seconds: 2),
        );
      }

      // Remove update() call - not needed with Rx
    } catch (e, stackTrace) {
      print('❌ Error in followUser: $e');
      print('Stack trace: $stackTrace');

      String errorMsg = e.toString();
      if (errorMsg.contains('PERMISSION_DENIED')) {
        Get.snackbar(
          'Permission Denied',
          'Cannot follow/unfollow. Check Firestore security rules.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
          duration: Duration(seconds: 5),
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to update follow status',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
      }
    }
  }

  @override
  void onClose() {
    print('🛑 ProfileController closed');
    super.onClose();
  }
}

extension on Object? {
  operator [](String other) {}
}
