import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:tiktokerrr/constants.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tiktokerrr/models/user.dart' as model;
import 'package:tiktokerrr/views/screens/home_screen.dart';
import 'package:tiktokerrr/views/screens/auth_screens/login_screen.dart';
// there are two user coming in this file

class AuthController extends GetxController {
  static AuthController instance = Get.find();
  late Rx<File?> _pickedImage; // observable
  late Rx<User?> _user;

  File? get profilePhoto => _pickedImage.value;
  // getter, as the _pickedIamge is private field
  User get user => _user.value!;


  @override
  void onReady() {
    super.onReady();

    _user = Rx<User?>(firebaseAuth.currentUser);
    _user.bindStream(
      firebaseAuth.authStateChanges().map((user) => user),
    );
    ever(_user, (callback) => _setInitialScreen(_user.value));
  }

  void _setInitialScreen(User? user) {
    if (user == null) {
      Get.offAll(
        () => LoginScreen(),
      );
    } else {
      Get.offAll(
        () => HomeScreen(),
      );
    }
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  // register user
  void registerUser(
    String username,
    String email,
    String password,
    File? image,
  ) async {
    try {
      if (username.isNotEmpty &&
          email.isNotEmpty &&
          password.isNotEmpty &&
          image != null) {
        // save out user to auth and firestore database
        UserCredential cred = await firebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        String downloadUrl = await _uploadToStorage(image);
        model.User user = model.User(
          name: username,
          email: email,
          uid: cred.user!.uid,
          profilePhoto: downloadUrl,
        );

        firestore.collection('users').doc(cred.user!.uid).set(user.toJson());

        print('sign up success');
      } else {
        Get.snackbar(
          'Error creating account',
          'Please enter all the fields.',
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error creating account',
        e.toString(),
      );
    }
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  // upload to firebase storage
  Future<String> _uploadToStorage(File image) async {
    try {
      if (firebaseAuth.currentUser != null) {
        Reference ref = firebaseStorage
            .ref()
            .child('profilePics')
            .child(firebaseAuth.currentUser!.uid);

        UploadTask _uploadTask = ref.putFile(image);
        TaskSnapshot snap = await _uploadTask;
        String downloadUrl = await snap.ref.getDownloadURL();
        return downloadUrl;
      } else {
        throw Exception("User is not authenticated.");
      }
    } catch (e) {
      print("Error uploading to storage: $e");
      throw e;
    }
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  //pick image from gallery
  void pickImage() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (pickedImage != null) {
      Get.snackbar(
        'Profile picture',
        'You have successfully choosed your profile picture.',
      );
      _pickedImage = Rx<File?>(File(pickedImage.path));
    }
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  // log in user
  void loginUser(String email, String password) async {
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        await firebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        print('log in success');
      } else {
        Get.snackbar(
          'Error logging in',
          'Please enter all the fields.',
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error logging in',
        e.toString(),
      );
    }
  }

  void signOut() async {
    await firebaseAuth.signOut();
  }
}
