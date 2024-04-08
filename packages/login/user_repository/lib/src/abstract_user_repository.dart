import 'package:firebase_auth/firebase_auth.dart';
import 'package:user_repository/src/models/models.dart';

abstract class UserRepository {
  Stream<User?> get user;
  Future<MyUser> signUp(MyUser user, String password);
  Future<void> setUserData(MyUser user);
  Future<void> signIn(String email, String password);
  Future<void> signOut();
  Future<MyUser> getUserData(String userId);
  Future<String> changeProfilePicture(String imageUrl, String userId);
  Future<String> changeUsername(String newUsername, String userId);
  Future<void> giveFollow(MyUser followGiver, MyUser followReceiver);
  Future<List<MyUser>> getFollowers(String userId);
  Future<List<MyUser>> getFollowing(String userId);
  Future<List<MyUser>> searchProfilesByName(String name);
}
