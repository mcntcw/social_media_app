import 'package:social_media_app/blocs/authentication/authentication_bloc.dart';
import 'package:social_media_app/blocs/get_followers/get_followers_bloc.dart';
import 'package:social_media_app/blocs/get_following/get_following_bloc.dart';
import 'package:social_media_app/blocs/give_follow/give_follow_bloc.dart';
import 'package:social_media_app/blocs/my_user/my_user_bloc.dart';
import 'package:social_media_app/blocs/post/delete_post/delete_post_bloc.dart';
import 'package:social_media_app/blocs/post/edit_post/edit_post_bloc.dart';
import 'package:social_media_app/blocs/post/get_likes/get_likes_bloc.dart';
import 'package:social_media_app/blocs/post/get_posts/get_posts_bloc.dart';
import 'package:social_media_app/blocs/post/like_post/like_post_bloc.dart';
import 'package:social_media_app/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:post_repository/post_repository_library.dart';
import 'package:user_repository/user_repository_library.dart';

class UsersListBottomSheet extends StatelessWidget {
  final String listName;
  final List<MyUser> listUsers;
  final Post post;
  const UsersListBottomSheet({super.key, required this.listName, required this.listUsers, required this.post});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => MyUserBloc(userRepository: context.read<AuthenticationBloc>().userRepository),
        ),
        BlocProvider(
          create: (context) => GetPostsBloc(postRepository: FirebasePostRepository()),
        ),
        BlocProvider(
          create: (context) => GetLikesBloc(postRepository: FirebasePostRepository()),
        ),
      ],
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25.0),
            topRight: Radius.circular(25.0),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                padding: EdgeInsets.zero,
                height: 5,
                width: 100,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onBackground.withOpacity(0.3),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(60),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                listName,
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onBackground, fontSize: 18, fontFamily: 'InterBold'),
              ),
              const SizedBox(height: 15),
              ListView.builder(
                shrinkWrap: true,
                itemCount: listUsers.length,
                itemBuilder: (BuildContext context, int index) {
                  return Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) => MultiBlocProvider(
                                providers: [
                                  BlocProvider(
                                    create: (context) {
                                      final myUserBloc =
                                          MyUserBloc(userRepository: context.read<AuthenticationBloc>().userRepository);

                                      Future.delayed(Duration.zero, () {
                                        myUserBloc.add(
                                            GetUserData(userId: context.read<AuthenticationBloc>().state.user!.uid));
                                      });

                                      return myUserBloc;
                                    },
                                  ),
                                  BlocProvider(
                                    create: (context) => GiveFollowBloc(
                                        userRepository: context.read<AuthenticationBloc>().userRepository),
                                  ),
                                  BlocProvider(
                                    create: (context) => GetFollowersBloc(
                                        userRepository: context.read<AuthenticationBloc>().userRepository)
                                      ..add(GetFollowers(listUsers[index].id)),
                                  ),
                                  BlocProvider(
                                    create: (context) => GetFollowingBloc(
                                        userRepository: context.read<AuthenticationBloc>().userRepository)
                                      ..add(GetFollowing(listUsers[index].id)),
                                  ),
                                  BlocProvider(
                                    create: (context) =>
                                        GetPostsBloc(postRepository: FirebasePostRepository())..add(const GetPosts()),
                                  ),
                                  BlocProvider(
                                    create: (context) => EditPostBloc(postRepository: FirebasePostRepository()),
                                  ),
                                  BlocProvider(
                                    create: (context) => DeletePostBloc(postRepository: FirebasePostRepository()),
                                  ),
                                  BlocProvider(
                                    create: (context) => LikePostBloc(postRepository: FirebasePostRepository()),
                                  ),
                                ],
                                child: ProfileScreen(
                                  userData: listUsers[index],
                                ),
                              ),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                const begin = Offset(1.0, 0.0);
                                const end = Offset.zero;
                                const curve = Curves.easeInOutQuart;
                                var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                var offsetAnimation = animation.drive(tween);

                                return SlideTransition(position: offsetAnimation, child: child);
                              },
                              transitionDuration: const Duration(milliseconds: 750),
                              reverseTransitionDuration: const Duration(milliseconds: 750),
                            ),
                          );
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 35,
                              height: 35,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme.of(context).colorScheme.onBackground,
                                image: DecorationImage(
                                  image: listUsers[index].picture == null || listUsers[index].picture == ""
                                      ? const AssetImage('assets/images/logo.png')
                                      : NetworkImage(listUsers[index].picture.toString()) as ImageProvider<Object>,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              listUsers[index].name.toLowerCase(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Theme.of(context).colorScheme.onBackground,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
