import 'package:cached_network_image/cached_network_image.dart';
import 'package:social_media_app/blocs/authentication/authentication_bloc.dart';
import 'package:social_media_app/blocs/get_followers/get_followers_bloc.dart';
import 'package:social_media_app/blocs/get_following/get_following_bloc.dart';
import 'package:social_media_app/blocs/give_follow/give_follow_bloc.dart';
import 'package:social_media_app/blocs/my_user/my_user_bloc.dart';
import 'package:social_media_app/blocs/post/comments/add_comment/add_comment_bloc.dart';
import 'package:social_media_app/blocs/post/comments/delete_comment/delete_comment_bloc.dart';
import 'package:social_media_app/blocs/post/comments/get_comment_likes/get_comment_likes_bloc.dart';
import 'package:social_media_app/blocs/post/comments/like_comment/like_comment_bloc.dart';
import 'package:social_media_app/blocs/post/delete_post/delete_post_bloc.dart';
import 'package:social_media_app/blocs/post/edit_post/edit_post_bloc.dart';
import 'package:social_media_app/blocs/post/get_likes/get_likes_bloc.dart';
import 'package:social_media_app/blocs/post/get_posts/get_posts_bloc.dart';
import 'package:social_media_app/blocs/post/like_post/like_post_bloc.dart';
import 'package:social_media_app/screens/post_screen.dart';
import 'package:social_media_app/utils/users_list_bottom_sheet.dart';
import 'package:social_media_app/widgets/post_from_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart' as getx;
import 'package:post_repository/post_repository_library.dart';
import 'package:user_repository/user_repository_library.dart';

class ProfileScreen extends StatefulWidget {
  final MyUser userData;

  const ProfileScreen({
    super.key,
    required this.userData,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController postContentsController = TextEditingController();
  int followers = 0;
  int following = 0;
  bool isFollowed = false;
  bool isFirstLoad = true;
  Color followButtonColor = Colors.transparent;
  Color followTextColor = Colors.transparent;
  String followText = '';
  List<MyUser> followersList = [];
  List<MyUser> followingList = [];
  final ScrollController _scrollController = ScrollController();

  double yourSavedOffset = 0.0;

  void _saveScrollPosition() {
    yourSavedOffset = _scrollController.offset;
  }

  void _restoreScrollPosition() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(yourSavedOffset);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyUserBloc, MyUserState>(
      builder: (context, state) {
        if (state.status == MyUserStatus.success) {
          return MultiBlocListener(
            listeners: [
              BlocListener<GiveFollowBloc, GiveFollowState>(
                listener: (context, state) {
                  if (state is GiveFollowSuccess) {
                    context.read<GetFollowersBloc>().add(GetFollowers(widget.userData.id));
                    context.read<GetFollowingBloc>().add(GetFollowing(widget.userData.id));
                  }
                },
              ),
              BlocListener<GetPostsBloc, GetPostsState>(
                listener: (context, state) {
                  if (state is GetPostsSuccess) {
                    _restoreScrollPosition();
                  }
                },
              ),
            ],
            child: Scaffold(
              backgroundColor: Theme.of(context).colorScheme.background,
              appBar: AppBar(
                centerTitle: true,
                foregroundColor: Theme.of(context).colorScheme.onBackground,
                elevation: 0,
                backgroundColor: Colors.transparent,
                leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      getx.Get.back();
                    }),
              ),
              body: RefreshIndicator(
                onRefresh: () {
                  context.read<GetPostsBloc>().add(const GetPosts());
                  return Future.value();
                },
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                    child: Column(
                      children: [
                        SizedBox(
                          width: 150,
                          height: 150,
                          child: widget.userData.picture == ""
                              ? Image.asset(
                                  'assets/images/logo.png',
                                  fit: BoxFit.cover,
                                )
                              : CachedNetworkImage(
                                  imageUrl: widget.userData.picture.toString(),
                                  imageBuilder: (context, imageProvider) => ClipRRect(
                                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                                    child: Image(
                                      image: imageProvider,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  placeholder: (context, url) => CircularProgressIndicator(
                                    color: Theme.of(context).colorScheme.background,
                                  ),
                                  errorWidget: (context, url, error) => const Icon(Icons.error),
                                ),
                        ),
                        const SizedBox(height: 10),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            widget.userData.name.toLowerCase(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        BlocBuilder<GetFollowersBloc, GetFollowersState>(
                          builder: (context, followersState) {
                            if (followersState is GetFollowersSuccess) {
                              followersList = followersState.followers;
                              if (isFirstLoad) {
                                followers = followersState.followers.length;
                                isFollowed = followersState.followers.contains(state.user!);
                                followersState.followers.length;
                                followButtonColor = isFollowed
                                    ? Theme.of(context).colorScheme.surface
                                    : Theme.of(context).colorScheme.onBackground;
                                followText = isFollowed ? 'Unfollow' : 'Follow';
                                followTextColor = isFollowed
                                    ? Theme.of(context).colorScheme.onBackground
                                    : Theme.of(context).colorScheme.surface;
                                isFirstLoad = false;
                              }
                            }
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    showModalBottomSheet(
                                      context: context,
                                      backgroundColor: Colors.transparent,
                                      builder: (BuildContext context) {
                                        return UsersListBottomSheet(
                                          listName: 'Followers',
                                          listUsers: followersList,
                                          post: Post.empty,
                                        );
                                      },
                                    ).then((value) {
                                      context
                                          .read<MyUserBloc>()
                                          .add(GetUserData(userId: context.read<AuthenticationBloc>().state.user!.uid));
                                      context.read<GetPostsBloc>().add(const GetPosts());
                                    });
                                  },
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        followers.toString(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                          color: Theme.of(context).colorScheme.onBackground,
                                        ),
                                      ),
                                      Text(
                                        'Followers',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Theme.of(context).colorScheme.onBackground,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                widget.userData.id == state.user!.id
                                    ? Container(
                                        width: 80,
                                      )
                                    : GestureDetector(
                                        onTap: () {
                                          BlocProvider.of<GiveFollowBloc>(context)
                                              .add(GiveFollow(state.user!, widget.userData));
                                          setState(() {
                                            if (isFollowed) {
                                              followButtonColor = Theme.of(context).colorScheme.onBackground;
                                              followTextColor = Theme.of(context).colorScheme.surface;
                                              followText = 'Follow';
                                              followers--;
                                            } else {
                                              followButtonColor = Theme.of(context).colorScheme.surface;
                                              followTextColor = Theme.of(context).colorScheme.onBackground;
                                              followText = 'Unollow';
                                              followers++;
                                            }
                                            isFollowed = !isFollowed;
                                          });
                                        },
                                        child: Container(
                                          width: 80,
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(8),
                                            color: followButtonColor,
                                          ),
                                          child: Center(
                                            child: Text(
                                              followText,
                                              style: TextStyle(
                                                fontFamily: 'InterSemiBold',
                                                fontSize: 14,
                                                color: followTextColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                BlocBuilder<GetFollowingBloc, GetFollowingState>(builder: (context, followingState) {
                                  if (followingState is GetFollowingSuccess) {
                                    followingList = followingState.following;
                                    following = followingState.following.length;
                                  }
                                  return GestureDetector(
                                    onTap: () {
                                      showModalBottomSheet(
                                        context: context,
                                        backgroundColor: Colors.transparent,
                                        builder: (BuildContext context) {
                                          return UsersListBottomSheet(
                                            listName: 'Following',
                                            listUsers: followingList,
                                            post: Post.empty,
                                          );
                                        },
                                      );
                                    },
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          following.toString(),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                            color: Theme.of(context).colorScheme.onBackground,
                                          ),
                                        ),
                                        Text(
                                          'Following',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: Theme.of(context).colorScheme.onBackground,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 30),
                        BlocBuilder<GetPostsBloc, GetPostsState>(
                          builder: (context, state) {
                            if (state is GetPostsSuccess) {
                              final userPosts =
                                  state.posts.where((post) => post.author.id == widget.userData.id).toList();
                              return MultiBlocListener(
                                listeners: [
                                  BlocListener<DeletePostBloc, DeletePostState>(
                                    listener: (context, state) {
                                      if (state is DeletePostSuccess) {
                                        context.read<GetPostsBloc>().add(const GetPosts());
                                      }
                                    },
                                  ),
                                  BlocListener<EditPostBloc, EditPostState>(
                                    listener: (context, state) {
                                      if (state is EditPostSuccess) {
                                        context.read<GetPostsBloc>().add(const GetPosts());
                                      }
                                    },
                                  ),
                                ],
                                child: ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: userPosts.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    return MultiBlocProvider(
                                      providers: [
                                        BlocProvider(
                                          create: (context) {
                                            final myUserBloc = MyUserBloc(
                                                userRepository: context.read<AuthenticationBloc>().userRepository);

                                            Future.delayed(Duration.zero, () {
                                              myUserBloc.add(GetUserData(
                                                  userId: context.read<AuthenticationBloc>().state.user!.uid));
                                            });

                                            return myUserBloc;
                                          },
                                        ),
                                      ],
                                      child: PostFromList(
                                        post: userPosts[index],
                                        onProfileAction: () {},
                                        onContentsAction: () {
                                          Navigator.of(context)
                                              .push(
                                            PageRouteBuilder(
                                              pageBuilder: (context, animation, secondaryAnimation) =>
                                                  MultiBlocProvider(
                                                providers: [
                                                  BlocProvider(
                                                    create: (context) {
                                                      final myUserBloc = MyUserBloc(
                                                          userRepository:
                                                              context.read<AuthenticationBloc>().userRepository);
                                                      Future.delayed(Duration.zero, () {
                                                        myUserBloc.add(GetUserData(
                                                            userId:
                                                                context.read<AuthenticationBloc>().state.user!.uid));
                                                      });

                                                      return myUserBloc;
                                                    },
                                                  ),
                                                  BlocProvider(
                                                    create: (context) =>
                                                        GetPostsBloc(postRepository: FirebasePostRepository())
                                                          ..add(const GetPosts()),
                                                  ),
                                                  BlocProvider(
                                                    create: (context) =>
                                                        GetLikesBloc(postRepository: FirebasePostRepository())
                                                          ..add(GetLikes(userPosts[index])),
                                                  ),
                                                  BlocProvider(
                                                    create: (context) =>
                                                        EditPostBloc(postRepository: FirebasePostRepository()),
                                                  ),
                                                  BlocProvider(
                                                    create: (context) =>
                                                        DeletePostBloc(postRepository: FirebasePostRepository()),
                                                  ),
                                                  BlocProvider(
                                                    create: (context) =>
                                                        LikePostBloc(postRepository: FirebasePostRepository()),
                                                  ),
                                                  BlocProvider(
                                                    create: (context) =>
                                                        AddCommentBloc(postRepository: FirebasePostRepository()),
                                                  ),
                                                  BlocProvider(
                                                    create: (context) =>
                                                        DeleteCommentBloc(postRepository: FirebasePostRepository()),
                                                  ),
                                                  BlocProvider(
                                                    create: (context) =>
                                                        LikeCommentBloc(postRepository: FirebasePostRepository()),
                                                  ),
                                                  BlocProvider(
                                                    create: (context) =>
                                                        GetCommentLikesBloc(postRepository: FirebasePostRepository()),
                                                  ),
                                                ],
                                                child: PostScreen(
                                                  post: userPosts[index],
                                                ),
                                              ),
                                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                                const begin = Offset(1.0, 0.0);
                                                const end = Offset.zero;
                                                const curve = Curves.easeInOutQuart;

                                                var tween =
                                                    Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

                                                var offsetAnimation = animation.drive(tween);

                                                return SlideTransition(position: offsetAnimation, child: child);
                                              },
                                              transitionDuration: const Duration(milliseconds: 750),
                                              reverseTransitionDuration: const Duration(milliseconds: 750),
                                            ),
                                          )
                                              .then((value) {
                                            context.read<MyUserBloc>().add(GetUserData(
                                                userId: context.read<AuthenticationBloc>().state.user!.uid));
                                            context.read<GetPostsBloc>().add(const GetPosts());
                                            context
                                                .read<GetFollowersBloc>()
                                                .add(GetFollowers(userPosts[index].author.id));
                                            context
                                                .read<GetFollowingBloc>()
                                                .add(GetFollowing(userPosts[index].author.id));
                                          });
                                        },
                                        saveScrollPosition: () {
                                          _saveScrollPosition();
                                        },
                                        myUserBloc: BlocProvider.of<MyUserBloc>(context),
                                        getPostsBloc: BlocProvider.of<GetPostsBloc>(context),
                                        editPostBloc: BlocProvider.of<EditPostBloc>(context),
                                        deletePostBloc: BlocProvider.of<DeletePostBloc>(context),
                                        likePostBloc: BlocProvider.of<LikePostBloc>(context),
                                        currentUser: context.read<AuthenticationBloc>().state.user,
                                        textController: postContentsController,
                                        isOnProfileScreen: true,
                                      ),
                                    );
                                  },
                                ),
                              );
                            } else if (state is GetPostsProcess) {
                              return Center(
                                child: CircularProgressIndicator(color: Theme.of(context).colorScheme.onBackground),
                              );
                            } else {
                              return FutureBuilder<void>(
                                future: Future.delayed(const Duration(seconds: 3)),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.done) {
                                    return Center(
                                      child: Text(
                                        'Error',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 24,
                                          color: Theme.of(context).colorScheme.onBackground,
                                        ),
                                      ),
                                    );
                                  } else {
                                    return Container();
                                  }
                                },
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        } else {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.background,
            body: Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
          );
        }
      },
    );
  }
}
