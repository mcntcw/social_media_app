import 'package:firebase_core/firebase_core.dart';
import 'package:social_media_app/app.dart';
import 'package:flutter/material.dart';
import 'package:user_repository/user_repository_library.dart';

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp(FirebaseUserRepository()));
}
