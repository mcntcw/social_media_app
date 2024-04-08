import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:user_repository/src/entities/entities.dart';
import 'package:user_repository/src/models/user_model.dart';
import 'package:user_repository/src/abstract_user_repository.dart';

class FirebaseUserRepository implements UserRepository {
  final FirebaseAuth _firebaseAuth;
  final usersCollection = FirebaseFirestore.instance.collection('users');

  FirebaseUserRepository({
    FirebaseAuth? firebaseAuth,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;
  @override
  Stream<User?> get user {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      return firebaseUser;
    });
  }

  @override
  Future<MyUser> signUp(MyUser myUser, String password) async {
    try {
      UserCredential user = await _firebaseAuth.createUserWithEmailAndPassword(
        email: myUser.email,
        password: password,
      );

      myUser = myUser.copyWith(id: user.user!.uid, followers: [], following: []);

      return myUser;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> signIn(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> setUserData(MyUser myUser) async {
    try {
      await usersCollection.doc(myUser.id).set(myUser.toEntity().toDocument());
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<MyUser> getUserData(String userId) async {
    try {
      return usersCollection
          .doc(userId)
          .get()
          .then((value) => MyUser.fromEntity(MyUserEntity.fromDocument(value.data()!)));
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<String> changeProfilePicture(String file, String userId) async {
    try {
      File imageFile = File(file);
      Reference firebaseStoreRef = FirebaseStorage.instance.ref().child('$userId/avatar/${userId}_avatar');
      await firebaseStoreRef.putFile(
        imageFile,
      );
      String url = await firebaseStoreRef.getDownloadURL();
      await usersCollection.doc(userId).update({'picture': url});
      return url;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<String> changeUsername(String newUsername, String userId) async {
    try {
      QuerySnapshot querySnapshot = await usersCollection.where('name', isEqualTo: newUsername).get();
      if (querySnapshot.docs.isNotEmpty) {
        throw Exception('Username already taken. Please choose a different one.');
      }

      await usersCollection.doc(userId).update({'name': newUsername});

      return 'Username changed successfully';
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> giveFollow(MyUser followGiver, MyUser followReceiver) async {
    try {
      // Sprawdź, czy followGiver i followReceiver nie są tą samą osobą
      if (followGiver.id != followReceiver.id) {
        final followGiverDoc = await usersCollection.doc(followGiver.id).get();
        final followReceiverDoc = await usersCollection.doc(followReceiver.id).get();

        if (followGiverDoc.exists && followReceiverDoc.exists) {
          final followGiverMap = followGiverDoc.data() as Map<String, dynamic>;
          final followReceiverMap = followReceiverDoc.data() as Map<String, dynamic>;

          final List<dynamic> followingDataGiver = followGiverMap['following'] ?? [];

          if (followingDataGiver.contains(followReceiver.id)) {
            await usersCollection.doc(followGiver.id).update({
              'following': FieldValue.arrayRemove([followReceiver.id]),
            });
          } else {
            await usersCollection.doc(followGiver.id).update({
              'following': FieldValue.arrayUnion([followReceiver.id]),
            });
          }
          final List<dynamic> followersDataReceiver = followReceiverMap['followers'] ?? [];

          if (followersDataReceiver.contains(followGiver.id)) {
            await usersCollection.doc(followReceiver.id).update({
              'followers': FieldValue.arrayRemove([followGiver.id]),
            });
          } else {
            await usersCollection.doc(followReceiver.id).update({
              'followers': FieldValue.arrayUnion([followGiver.id]),
            });
          }
        }
      } else {}
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<List<MyUser>> getFollowing(String userId) async {
    try {
      final userDoc = await usersCollection.doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        if (userData.containsKey('following')) {
          final followingIds = userData['following'];
          if (followingIds != null && followingIds is List) {
            List<MyUser> following = await Future.wait(followingIds.map(
              (followingId) async {
                final followingDoc = await usersCollection.doc(followingId).get();
                if (followingDoc.exists) {
                  MyUser followingUser = MyUser.fromEntity(MyUserEntity.fromDocument(followingDoc.data() ?? {}));
                  followingUser.picture = followingDoc.get('picture');
                  followingUser.name = followingDoc.get('name');
                  return followingUser;
                } else {
                  return MyUser.empty;
                }
              },
            ));

            return following;
          }
        }
      }

      return [];
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<List<MyUser>> getFollowers(String userId) async {
    try {
      final userDoc = await usersCollection.doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        if (userData.containsKey('followers')) {
          final followersIds = userData['followers'];
          if (followersIds != null && followersIds is List<dynamic>) {
            List<MyUser> followers = await Future.wait(followersIds.map(
              (followerId) async {
                if (followerId is String) {
                  final followerDoc = await usersCollection.doc(followerId).get();
                  if (followerDoc.exists) {
                    MyUser follower = MyUser.fromEntity(MyUserEntity.fromDocument(followerDoc.data() ?? {}));
                    follower.picture = followerDoc.get('picture');
                    follower.name = followerDoc.get('name');
                    return follower;
                  } else {
                    return MyUser.empty;
                  }
                } else {
                  return MyUser.empty;
                }
              },
            ));

            return followers;
          }
        }
      }

      return [];
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<List<MyUser>> searchProfilesByName(String name) async {
    if (name.length < 3) {
      return [];
    }

    String lowerCaseName = name.toLowerCase();

    QuerySnapshot snapshot = await usersCollection
        .where('name', isGreaterThanOrEqualTo: lowerCaseName)
        .where('name', isLessThanOrEqualTo: '$lowerCaseName\uf8ff')
        .get();
    List<MyUser> profiles = [];

    for (DocumentSnapshot doc in snapshot.docs) {
      Map<String, dynamic> userData = doc.data()! as Map<String, dynamic>;

      MyUser profile = MyUser.fromEntity(MyUserEntity.fromDocument(userData));

      profiles.add(profile);
    }

    if (profiles.isNotEmpty) {}

    return profiles;
  }
}
