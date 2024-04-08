import 'package:social_media_app/blocs/authentication/authentication_bloc.dart';
import 'package:social_media_app/blocs/post/delete_post/delete_post_bloc.dart';
import 'package:social_media_app/blocs/post/like_post/like_post_bloc.dart';
import 'package:social_media_app/blocs/search_profiles/search_profiles_bloc.dart';
import 'package:social_media_app/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/blocs/get_followers/get_followers_bloc.dart';
import 'package:social_media_app/blocs/get_following/get_following_bloc.dart';
import 'package:social_media_app/blocs/give_follow/give_follow_bloc.dart';
import 'package:social_media_app/blocs/my_user/my_user_bloc.dart';
import 'package:social_media_app/blocs/post/edit_post/edit_post_bloc.dart';
import 'package:social_media_app/blocs/post/get_posts/get_posts_bloc.dart';
import 'package:post_repository/post_repository_library.dart';

class ProfilesSearchBottomSheet extends StatelessWidget {
  final TextEditingController searchProfilesController;

  const ProfilesSearchBottomSheet({
    Key? key,
    required this.searchProfilesController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SearchProfilesBloc(userRepository: context.read<AuthenticationBloc>().userRepository),
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
          child: BlocBuilder<SearchProfilesBloc, SearchProfilesState>(
            builder: (context, state) {
              return Column(
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
                  TextFormField(
                    controller: searchProfilesController,
                    onChanged: (text) {
                      context.read<SearchProfilesBloc>().add(SearchProfiles(text));
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildProfileList(state),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProfileList(SearchProfilesState state) {
    if (state is SearchProfilesSuccess) {
      return ListView.builder(
        shrinkWrap: true,
        itemCount: state.profiles.length,
        itemBuilder: (context, index) {
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
                                myUserBloc.add(GetUserData(userId: context.read<AuthenticationBloc>().state.user!.uid));
                              });

                              return myUserBloc;
                            },
                          ),
                          BlocProvider(
                            create: (context) =>
                                GiveFollowBloc(userRepository: context.read<AuthenticationBloc>().userRepository),
                          ),
                          BlocProvider(
                            create: (context) =>
                                GetFollowersBloc(userRepository: context.read<AuthenticationBloc>().userRepository)
                                  ..add(GetFollowers(state.profiles[index].id)),
                          ),
                          BlocProvider(
                            create: (context) =>
                                GetFollowingBloc(userRepository: context.read<AuthenticationBloc>().userRepository)
                                  ..add(GetFollowing(state.profiles[index].id)),
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
                          userData: state.profiles[index],
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
                          image: state.profiles[index].picture == null || state.profiles[index].picture == ""
                              ? const AssetImage('assets/images/logo.png')
                              : NetworkImage(state.profiles[index].picture.toString()) as ImageProvider<Object>,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      state.profiles[index].name.toLowerCase(),
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
      );
    } else if (state is SearchProfilesSuccess) {
      return Container(
        width: 12,
        height: 12,
        margin: const EdgeInsets.symmetric(horizontal: 10),
        child: const CircularProgressIndicator(
          strokeWidth: 1.5,
        ),
      );
    } else {
      return Container();
    }
  }
}
