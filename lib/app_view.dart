import 'package:social_media_app/blocs/authentication/authentication_bloc.dart';
import 'package:social_media_app/blocs/get_followers/get_followers_bloc.dart';
import 'package:social_media_app/blocs/get_following/get_following_bloc.dart';
import 'package:social_media_app/blocs/give_follow/give_follow_bloc.dart';
import 'package:social_media_app/blocs/my_user/my_user_bloc.dart';
import 'package:social_media_app/blocs/post/create_post/create_post_bloc.dart';
import 'package:social_media_app/blocs/post/delete_post/delete_post_bloc.dart';
import 'package:social_media_app/blocs/post/edit_post/edit_post_bloc.dart';
import 'package:social_media_app/blocs/post/get_likes/get_likes_bloc.dart';
import 'package:social_media_app/blocs/post/get_posts/get_posts_bloc.dart';
import 'package:social_media_app/blocs/post/like_post/like_post_bloc.dart';
import 'package:social_media_app/blocs/search_profiles/search_profiles_bloc.dart';
import 'package:social_media_app/blocs/sign_in/sign_in_bloc.dart';
import 'package:social_media_app/main.dart';
import 'package:social_media_app/screens/home_screen.dart';
import 'package:social_media_app/screens/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:post_repository/post_repository_library.dart';

class MyAppView extends StatelessWidget {
  const MyAppView({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ),
    );

    return GetMaterialApp(
      builder: (context, child) {
        return ScrollConfiguration(
          behavior: MyBehavior(),
          child: child!,
        );
      },
      debugShowCheckedModeBanner: false,
      title: 'SOMA',
      theme: ThemeData(
        colorScheme: const ColorScheme.dark(
          background: Color(0xFF151515),
          primary: Color(0xFFffde26),
          surface: Color(0xFF030303),
          secondary: Color(0xFFffe555),
          onBackground: Color(0xFFD5DBDB),
        ),
        fontFamily: 'InterSemiBold',
      ),
      home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
          if (state.status == AuthenticationStatus.authenticated) {
            return MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (context) => SignInBloc(userRepository: context.read<AuthenticationBloc>().userRepository),
                ),
                BlocProvider(
                  create: (context) => MyUserBloc(userRepository: context.read<AuthenticationBloc>().userRepository)
                    ..add(GetUserData(userId: context.read<AuthenticationBloc>().state.user!.uid)),
                ),
                BlocProvider<SearchProfilesBloc>(
                  create: (context) =>
                      SearchProfilesBloc(userRepository: context.read<AuthenticationBloc>().userRepository),
                ),
                BlocProvider<GiveFollowBloc>(
                  create: (context) =>
                      GiveFollowBloc(userRepository: context.read<AuthenticationBloc>().userRepository),
                ),
                BlocProvider(
                  create: (context) =>
                      GetFollowingBloc(userRepository: context.read<AuthenticationBloc>().userRepository)
                        ..add(GetFollowing(context.read<AuthenticationBloc>().state.user!.uid)),
                ),
                BlocProvider(
                  create: (context) =>
                      GetFollowersBloc(userRepository: context.read<AuthenticationBloc>().userRepository)
                        ..add(GetFollowers(context.read<AuthenticationBloc>().state.user!.uid)),
                ),
                BlocProvider<CreatePostBloc>(
                  create: (context) => CreatePostBloc(postRepository: FirebasePostRepository()),
                ),
                BlocProvider<EditPostBloc>(
                  create: (context) => EditPostBloc(postRepository: FirebasePostRepository()),
                ),
                BlocProvider<DeletePostBloc>(
                  create: (context) => DeletePostBloc(postRepository: FirebasePostRepository()),
                ),
                BlocProvider<LikePostBloc>(
                  create: (context) => LikePostBloc(postRepository: FirebasePostRepository()),
                ),
                BlocProvider<GetPostsBloc>(
                  create: (context) => GetPostsBloc(postRepository: FirebasePostRepository())..add(const GetPosts()),
                ),
                BlocProvider<GetLikesBloc>(
                  create: (context) => GetLikesBloc(postRepository: FirebasePostRepository()),
                ),
              ],
              child: const HomeScreen(),
            );
          } else {
            return MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (context) => SignInBloc(userRepository: context.read<AuthenticationBloc>().userRepository),
                ),
              ],
              child: const SignInScreen(),
            );
          }
        },
      ),
    );
  }
}
