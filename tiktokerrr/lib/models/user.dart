import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  late String name;
  // late String profilePhoto;
  late String email;
  late String uid;

  User({
    required this.email,
    required this.name,
    // required this.profilePhoto,
    required this.uid,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        // 'profilePhoto': profilePhoto,
        'email': email,
        'uid': uid,
      };

  static User fromSnap(DocumentSnapshot snap) {
    // take the document snapshot that we will pass in the future while retrieving the values
    // then it will convert to user model
    var snapshot = snap.data() as Map<String, dynamic>;
    return User(
      email: snapshot['email'],
      // profilePhoto: snapshot['profilePhoto'],
      uid: snapshot['uid'],
      name: snapshot['name'],
    );
  }
}
