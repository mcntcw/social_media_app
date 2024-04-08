import 'dart:io';
import 'dart:ui';

import 'package:social_media_app/blocs/authentication/authentication_bloc.dart';
import 'package:social_media_app/blocs/edit_user_data/edit_user_data_bloc.dart';
import 'package:social_media_app/blocs/get_followers/get_followers_bloc.dart';
import 'package:social_media_app/blocs/get_following/get_following_bloc.dart';
import 'package:social_media_app/blocs/give_follow/give_follow_bloc.dart';
import 'package:social_media_app/blocs/my_user/my_user_bloc.dart';
import 'package:social_media_app/blocs/post/comments/add_comment/add_comment_bloc.dart';
import 'package:social_media_app/blocs/post/comments/delete_comment/delete_comment_bloc.dart';
import 'package:social_media_app/blocs/post/comments/get_comment_likes/get_comment_likes_bloc.dart';
import 'package:social_media_app/blocs/post/comments/like_comment/like_comment_bloc.dart';
import 'package:social_media_app/blocs/post/create_post/create_post_bloc.dart';
import 'package:social_media_app/blocs/post/delete_post/delete_post_bloc.dart';
import 'package:social_media_app/blocs/post/edit_post/edit_post_bloc.dart';
import 'package:social_media_app/blocs/post/get_likes/get_likes_bloc.dart';
import 'package:social_media_app/blocs/post/get_posts/get_posts_bloc.dart';
import 'package:social_media_app/blocs/post/like_post/like_post_bloc.dart';
import 'package:social_media_app/blocs/search_profiles/search_profiles_bloc.dart';
import 'package:social_media_app/blocs/sign_in/sign_in_bloc.dart';
import 'package:social_media_app/screens/post_screen.dart';
import 'package:social_media_app/screens/profile_screen.dart';
import 'package:social_media_app/screens/settings_screen.dart';
import 'package:social_media_app/utils/image_handler.dart';
import 'package:social_media_app/utils/post_dialog.dart';
import 'package:social_media_app/utils/profiles_search_bottom_sheet.dart';
import 'package:social_media_app/widgets/post_from_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart' as getx;
import 'package:get/get.dart';
import 'package:post_repository/post_repository_library.dart';
import 'package:user_repository/user_repository_library.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImageHandler imageHandler = ImageHandler();
  String? addPostDialogImage = '';
  String? pickedImage;
  late Post post;
  final TextEditingController postContentsController = TextEditingController();
  bool profileMenuVisibility = false;
  bool postFieldVisibility = false;
  bool isLoading = false;
  bool allPosts = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();
  final PageStorageBucket _bucket = PageStorageBucket();
  final searchProfilesController = TextEditingController();
  List<MyUser> searchedProfiles = [];
  @override
  void initState() {
    post = Post.empty;
    super.initState();
  }

  double yourSavedOffset = 0.0;

  void _saveScrollPosition() {
    yourSavedOffset = _scrollController.offset;
  }

  void _restoreScrollPosition() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(yourSavedOffset);
    }
  }

  void scrollToTop() {
    _scrollController.animateTo(yourSavedOffset - yourSavedOffset,
        duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyUserBloc, MyUserState>(builder: (context, state) {
      if (state.status == MyUserStatus.success) {
        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: Theme.of(context).colorScheme.background,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            actions: [
              addPostButton(context, state),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () {
                  _scaffoldKey.currentState?.openEndDrawer();
                },
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.onBackground,
                    image: DecorationImage(
                      image: state.user!.picture == null || state.user!.picture == ""
                          ? const AssetImage('assets/images/logo.png')
                          : NetworkImage(
                              state.user!.picture.toString(),
                            ) as ImageProvider<Object>,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
            ],
            title: appBarTitleText(context),
          ),
          endDrawer: customDrawer(context, state),
          body: RefreshIndicator(
            onRefresh: () {
              yourSavedOffset = 0.0;
              context.read<MyUserBloc>().add(GetUserData(userId: state.user!.id));
              context.read<GetPostsBloc>().add(const GetPosts());
              return Future.value();
            },
            child: PageStorage(
              bucket: _bucket,
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  child: MultiBlocListener(
                    listeners: [
                      BlocListener<CreatePostBloc, CreatePostState>(
                        listener: (context, state) {
                          if (state is CreatePostSuccess) {
                            Navigator.pop(context);
                            setState(() {
                              isLoading = false;
                            });
                            addPostDialogImage = '';
                            postContentsController.clear();
                            context
                                .read<MyUserBloc>()
                                .add(GetUserData(userId: context.read<AuthenticationBloc>().state.user!.uid));
                            context.read<GetPostsBloc>().add(const GetPosts());
                            showSuccessSnackBar(context);
                            scrollToTop();
                          }
                          if (state is CreatePostProcess) {
                            setState(() {
                              isLoading = true;
                            });
                          }
                          if (state is CreatePostFailure) {
                            setState(() {
                              isLoading = false;
                            });
                          }
                        },
                      ),
                      BlocListener<DeletePostBloc, DeletePostState>(
                        listener: (context, state) {
                          if (state is DeletePostSuccess) {
                            Navigator.pop(context);
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
                      BlocListener<GetPostsBloc, GetPostsState>(
                        listener: (context, state) {
                          if (state is GetPostsSuccess) {
                            _restoreScrollPosition();
                          }
                        },
                      ),
                    ],
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      allPosts = true;
                                    });
                                    context
                                        .read<MyUserBloc>()
                                        .add(GetUserData(userId: context.read<AuthenticationBloc>().state.user!.uid));
                                    context.read<GetPostsBloc>().add(const GetPosts());
                                  },
                                  child: Container(
                                    width: 40,
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: allPosts
                                            ? Theme.of(context).colorScheme.onBackground
                                            : Theme.of(context).colorScheme.surface,
                                      ),
                                      borderRadius: const BorderRadius.all(Radius.circular(60)),
                                      color: Theme.of(context).colorScheme.surface,
                                    ),
                                    child: Center(
                                      child: Text(
                                        'All',
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.onBackground,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 3),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      allPosts = false;
                                    });
                                    context
                                        .read<MyUserBloc>()
                                        .add(GetUserData(userId: context.read<AuthenticationBloc>().state.user!.uid));
                                    context.read<GetPostsBloc>().add(const GetPosts());
                                  },
                                  child: Container(
                                    width: 100,
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: !allPosts
                                            ? Theme.of(context).colorScheme.onBackground
                                            : Theme.of(context).colorScheme.surface,
                                      ),
                                      borderRadius: const BorderRadius.all(Radius.circular(60)),
                                      color: Theme.of(context).colorScheme.surface,
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Following',
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.onBackground,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            GestureDetector(
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    backgroundColor: Colors.transparent,
                                    builder: (BuildContext ctx) {
                                      return BlocProvider(
                                        create: (context) => SearchProfilesBloc(
                                          userRepository: context.read<AuthenticationBloc>().userRepository,
                                        ),
                                        child: ProfilesSearchBottomSheet(
                                          searchProfilesController: searchProfilesController,
                                        ),
                                      );
                                    },
                                  );
                                },
                                child: Icon(
                                  Icons.search,
                                  color: Theme.of(context).colorScheme.onBackground,
                                )),
                          ],
                        ),
                        BlocBuilder<GetPostsBloc, GetPostsState>(
                          builder: (context, getPostsState) {
                            if (getPostsState is GetPostsSuccess) {
                              return BlocBuilder<GetLikesBloc, GetLikesState>(
                                builder: (context, getLikesState) {
                                  return postsList(getPostsState, state);
                                },
                              );
                            } else if (getPostsState is GetPostsProcess) {
                              return Align(
                                  alignment: Alignment.bottomCenter,
                                  child: CircularProgressIndicator(color: Theme.of(context).colorScheme.onBackground));
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
    });
  }

  void showSuccessSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.onBackground,
        behavior: SnackBarBehavior.floating,
        content: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.checkmark_alt_circle,
                  color: Colors.green.shade400,
                  size: 18,
                ),
                const SizedBox(width: 3),
                Text(
                  'Your post has been added successfully',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.background,
                  ),
                ),
              ],
            ),
          ),
        ),
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        margin: const EdgeInsets.all(50.0),
      ),
    );
  }

  Drawer customDrawer(BuildContext context, MyUserState state) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
            ),
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 50),
                  GestureDetector(
                    onTap: () {
                      getx.Get.to(
                        () => MultiBlocProvider(
                          providers: [
                            BlocProvider(
                              create: (context) {
                                final myUserBloc =
                                    MyUserBloc(userRepository: context.read<AuthenticationBloc>().userRepository);

                                Future.delayed(Duration.zero, () {
                                  myUserBloc
                                      .add(GetUserData(userId: context.read<AuthenticationBloc>().state.user!.uid));
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
                                    ..add(GetFollowers(context.read<AuthenticationBloc>().state.user!.uid)),
                            ),
                            BlocProvider(
                              create: (context) =>
                                  GetFollowingBloc(userRepository: context.read<AuthenticationBloc>().userRepository)
                                    ..add(GetFollowing(context.read<AuthenticationBloc>().state.user!.uid)),
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
                            userData: state.user!,
                          ),
                        ),
                        transition: getx.Transition.cupertino,
                        duration: const Duration(milliseconds: 750),
                      )!
                          .then((value) {
                        BlocProvider.of<GetPostsBloc>(context).add(const GetPosts());
                        getx.Get.back();
                      });
                    },
                    child: Column(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).colorScheme.onBackground,
                            image: DecorationImage(
                              image: state.user?.picture == null || state.user?.picture == ""
                                  ? const AssetImage('assets/images/logo.png')
                                  : NetworkImage(state.user!.picture.toString()) as ImageProvider<Object>,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          state.user!.name.toLowerCase(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                          textAlign: TextAlign.right,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          _saveScrollPosition();
                          Get.to(
                            () => MultiBlocProvider(
                              providers: [
                                BlocProvider(
                                  create: (context) =>
                                      MyUserBloc(userRepository: context.read<AuthenticationBloc>().userRepository)
                                        ..add(GetUserData(userId: context.read<AuthenticationBloc>().state.user!.uid)),
                                ),
                                BlocProvider(
                                  create: (context) => EditUserDataBloc(
                                      userRepository: context.read<AuthenticationBloc>().userRepository),
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
                              child: SettingsScreen(user: state.user!),
                            ),
                            transition: getx.Transition.cupertino,
                            duration: const Duration(milliseconds: 750),
                          )!
                              .then((value) {
                            context.read<MyUserBloc>().add(GetUserData(userId: state.user!.id));
                            context.read<GetPostsBloc>().add(const GetPosts());
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(width: 2, color: Theme.of(context).colorScheme.onBackground),
                            borderRadius: BorderRadius.circular(8),
                            color: Theme.of(context).colorScheme.background,
                          ),
                          child: Image.asset(
                            'assets/images/settings.png',
                            height: 20,
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () {
                          context.read<SignInBloc>().add(const SignOutRequired());
                          Get.back();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(width: 2, color: Theme.of(context).colorScheme.onBackground),
                            borderRadius: BorderRadius.circular(8),
                            color: Theme.of(context).colorScheme.background,
                          ),
                          child: Image.asset(
                            'assets/images/logout.png',
                            height: 20,
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  ListView postsList(GetPostsSuccess getPostsState, MyUserState userState) {
    //print(context.read<MyUserBloc>().state.user!.following);
    List<Post> postsFromFollowedUsers = getPostsState.posts.where((post) {
      return context.read<MyUserBloc>().state.user!.following.contains(post.author.id);
    }).toList();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      key: const PageStorageKey('home'),
      itemCount: allPosts ? getPostsState.posts.length : postsFromFollowedUsers.length,
      itemBuilder: (BuildContext context, int index) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) {
                final myUserBloc = MyUserBloc(userRepository: context.read<AuthenticationBloc>().userRepository);

                Future.delayed(Duration.zero, () {
                  myUserBloc.add(GetUserData(userId: context.read<AuthenticationBloc>().state.user!.uid));
                });

                return myUserBloc;
              },
            ),
            BlocProvider(
              create: (context) => GetFollowingBloc(userRepository: context.read<AuthenticationBloc>().userRepository)
                ..add(GetFollowing(context.read<AuthenticationBloc>().state.user!.uid)),
            ),
            BlocProvider(
              create: (context) => GetLikesBloc(postRepository: FirebasePostRepository())
                ..add(GetLikes(allPosts ? getPostsState.posts[index] : postsFromFollowedUsers[index])),
            ),
          ],
          child: PostFromList(
            key: UniqueKey(),
            post: allPosts ? getPostsState.posts[index] : postsFromFollowedUsers[index],
            onProfileAction: () {
              _saveScrollPosition();
              getx.Get.to(
                () => MultiBlocProvider(
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
                      create: (context) => GetFollowersBloc(
                          userRepository: context.read<AuthenticationBloc>().userRepository)
                        ..add(GetFollowers(
                            allPosts ? getPostsState.posts[index].author.id : postsFromFollowedUsers[index].author.id)),
                    ),
                    BlocProvider(
                      create: (context) => GetFollowingBloc(
                          userRepository: context.read<AuthenticationBloc>().userRepository)
                        ..add(GetFollowing(
                            allPosts ? getPostsState.posts[index].author.id : postsFromFollowedUsers[index].author.id)),
                    ),
                    BlocProvider(
                      create: (context) =>
                          GetPostsBloc(postRepository: FirebasePostRepository())..add(const GetPosts()),
                    ),
                    BlocProvider(
                      create: (context) => GetLikesBloc(postRepository: FirebasePostRepository())
                        ..add(GetLikes(allPosts ? getPostsState.posts[index] : postsFromFollowedUsers[index])),
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
                    userData: allPosts ? getPostsState.posts[index].author : postsFromFollowedUsers[index].author,
                  ),
                ),
                transition: getx.Transition.cupertino,
                duration: const Duration(milliseconds: 750),
              )!
                  .then((value) {
                BlocProvider.of<GetPostsBloc>(context).add(const GetPosts());
                BlocProvider.of<GetLikesBloc>(context).add(GetLikes(getPostsState.posts[0]));
                BlocProvider.of<MyUserBloc>(context)
                    .add(GetUserData(userId: context.read<AuthenticationBloc>().state.user!.uid));
              });
            },
            onContentsAction: () {
              _saveScrollPosition();
              getx.Get.to(
                () => MultiBlocProvider(
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
                            ..add(GetFollowers(getPostsState.posts[index].author.id)),
                    ),
                    BlocProvider(
                      create: (context) =>
                          GetFollowingBloc(userRepository: context.read<AuthenticationBloc>().userRepository)
                            ..add(GetFollowing(context.read<AuthenticationBloc>().state.user!.uid)),
                    ),
                    BlocProvider(
                      create: (context) =>
                          GetPostsBloc(postRepository: FirebasePostRepository())..add(const GetPosts()),
                    ),
                    BlocProvider(
                      create: (context) => GetLikesBloc(postRepository: FirebasePostRepository())
                        ..add(GetLikes(getPostsState.posts[index])),
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
                    BlocProvider(
                      create: (context) => AddCommentBloc(postRepository: FirebasePostRepository()),
                    ),
                    BlocProvider(
                      create: (context) => DeleteCommentBloc(postRepository: FirebasePostRepository()),
                    ),
                    BlocProvider(
                      create: (context) => LikeCommentBloc(postRepository: FirebasePostRepository()),
                    ),
                    BlocProvider(
                      create: (context) => GetCommentLikesBloc(postRepository: FirebasePostRepository()),
                    ),
                  ],
                  child: PostScreen(
                    post: allPosts ? getPostsState.posts[index] : postsFromFollowedUsers[index],
                  ),
                ),
                transition: getx.Transition.cupertino,
                duration: const Duration(milliseconds: 750),
              )!
                  .then((value) {
                BlocProvider.of<GetPostsBloc>(context).add(const GetPosts());
                BlocProvider.of<GetLikesBloc>(context)
                    .add(GetLikes(allPosts ? getPostsState.posts[index] : postsFromFollowedUsers[index]));
                BlocProvider.of<MyUserBloc>(context)
                    .add(GetUserData(userId: context.read<AuthenticationBloc>().state.user!.uid));
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
            isOnProfileScreen: false,
          ),
        );
      },
    );
  }

  GestureDetector appBarTitleText(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // context.read<MyUserBloc>().add(GetUserData(userId: context.read<AuthenticationBloc>().state.user!.uid));
        // context.read<GetFollowingBloc>().add(GetFollowing(context.read<AuthenticationBloc>().state.user!.uid));
        // context.read<GetPostsBloc>().add(const GetPosts());

        scrollToTop();
      },
      child: Text(
        "SOMA",
        style: TextStyle(
          fontFamily: 'Mantranaga',
          fontSize: 26,
          color: Theme.of(context).colorScheme.onBackground,
        ),
      ),
    );
  }

  GestureDetector addPostButton(BuildContext context, MyUserState state) {
    return GestureDetector(
      onTap: () {
        setState(() {
          postContentsController.clear();
        });
        showAddPostDialog(context, state);
      },
      child: Container(
        padding: const EdgeInsets.all(3),
        width: 70,
        margin: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          color: Theme.of(context).colorScheme.onBackground,
        ),
        child: Center(child: Image.asset('assets/images/feather.png')),
      ),
    );
  }

  Future<dynamic> showAddPostDialog(BuildContext ctx, MyUserState state) {
    return showDialog(
      barrierColor: Colors.transparent,
      barrierDismissible: true,
      context: ctx,
      builder: (BuildContext cntxt) {
        return StatefulBuilder(
          builder: (context, setState) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: PostDialog(
                user: state.user!,
                textController: postContentsController,
                onCancel: () {
                  Get.back();
                  setState(() {
                    pickedImage = '';
                  });
                },
                onImageAction: () async {
                  addPostDialogImage = await imageHandler.uploadPostPicture(ctx);
                  setState(() {
                    pickedImage = addPostDialogImage;
                  });
                },
                onAction: () {
                  if (postContentsController.text.isNotEmpty) {
                    setState(() {
                      post.likes = [];
                      post.contents = postContentsController.text;
                      post.author = state.user!;
                    });
                    ctx.read<CreatePostBloc>().add(CreatePost(post, addPostDialogImage.toString()));
                  }
                },
                actionText: 'Add',
                imageBody: Container(
                  height: pickedImage.toString() == '' || pickedImage == null ? 100 : null,
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Center(
                      child: pickedImage.toString() == '' || pickedImage == null
                          ? Icon(
                              Icons.add_a_photo_outlined,
                              color: Theme.of(ctx).colorScheme.background,
                              size: 40,
                            )
                          : Image.file(
                              File(pickedImage.toString()),
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                ),
                isLoading: isLoading,
              ),
            );
          },
        );
      },
    ).then((value) {
      setState(() {
        pickedImage = '';
      });
      getx.Get.back();
    });
  }
}
