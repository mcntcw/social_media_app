import 'package:social_media_app/blocs/authentication/authentication_bloc.dart';
import 'package:social_media_app/blocs/get_followers/get_followers_bloc.dart';
import 'package:social_media_app/blocs/get_following/get_following_bloc.dart';
import 'package:social_media_app/blocs/give_follow/give_follow_bloc.dart';
import 'package:social_media_app/blocs/my_user/my_user_bloc.dart';
import 'package:social_media_app/blocs/post/comments/add_comment/add_comment_bloc.dart';
import 'package:social_media_app/blocs/post/comments/delete_comment/delete_comment_bloc.dart';
import 'package:social_media_app/blocs/post/comments/like_comment/like_comment_bloc.dart';
import 'package:social_media_app/blocs/post/delete_post/delete_post_bloc.dart';
import 'package:social_media_app/blocs/post/edit_post/edit_post_bloc.dart';
import 'package:social_media_app/blocs/post/get_likes/get_likes_bloc.dart';
import 'package:social_media_app/blocs/post/get_posts/get_posts_bloc.dart';
import 'package:social_media_app/blocs/post/like_post/like_post_bloc.dart';
import 'package:social_media_app/screens/profile_screen.dart';
import 'package:social_media_app/widgets/comment_tile.dart';
import 'package:social_media_app/widgets/full_post.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart' as getx;
import 'package:post_repository/post_repository_library.dart';

class PostScreen extends StatefulWidget {
  final Post post;

  const PostScreen({
    super.key,
    required this.post,
  });

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  late Comment comment;
  final TextEditingController postContentsController = TextEditingController();
  final TextEditingController commentContentsController = TextEditingController();
  bool isFirstLoad = true;
  @override
  void initState() {
    comment = Comment.empty;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyUserBloc, MyUserState>(
      builder: (context, state) {
        if (state.status == MyUserStatus.success) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            appBar: AppBar(
              elevation: 0,
              centerTitle: true,
              leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    getx.Get.back();
                    getx.Get.back();
                  }),
            ),
            body: RefreshIndicator(
              onRefresh: () {
                context.read<MyUserBloc>().add(GetUserData(userId: state.user!.id));
                context.read<GetPostsBloc>().add(const GetPosts());
                return Future.value();
              },
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  child: BlocBuilder<GetPostsBloc, GetPostsState>(
                    builder: (context, getPostsState) {
                      if (getPostsState is GetPostsSuccess) {
                        final currentPost = getPostsState.posts
                            .firstWhere((searchPost) => searchPost.id == widget.post.id, orElse: () => Post.empty);

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
                            BlocListener<AddCommentBloc, AddCommentState>(
                              listener: (context, state) {
                                if (state is AddCommentSuccess) {
                                  commentContentsController.clear();
                                  context
                                      .read<MyUserBloc>()
                                      .add(GetUserData(userId: context.read<AuthenticationBloc>().state.user!.uid));
                                  context.read<GetPostsBloc>().add(const GetPosts());
                                  // context.read<GetLikesBloc>().add(GetLikes(currentPost));
                                  // setState(() {
                                  //   isFirstLoad = true;
                                  // });

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      elevation: 0,
                                      backgroundColor: Theme.of(context).colorScheme.onBackground,
                                      behavior: SnackBarBehavior.floating,
                                      content: Padding(
                                        padding: const EdgeInsets.all(8.0),
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
                                                'Your comment has been added successfully',
                                                style: TextStyle(
                                                  fontSize: 11,
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
                              },
                            ),
                            BlocListener<DeleteCommentBloc, DeleteCommentState>(
                              listener: (context, state) {
                                if (state is DeleteCommentSuccess) {
                                  Navigator.pop(context);
                                  context.read<GetPostsBloc>().add(const GetPosts());
                                }
                              },
                            ),
                          ],
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
                                child: FullPost(
                                  post: currentPost,
                                  clickToProfile: () {
                                    Navigator.of(context)
                                        .push(
                                      PageRouteBuilder(
                                        pageBuilder: (context, animation, secondaryAnimation) => MultiBlocProvider(
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
                                            BlocProvider(
                                              create: (context) => GiveFollowBloc(
                                                  userRepository: context.read<AuthenticationBloc>().userRepository),
                                            ),
                                            BlocProvider(
                                              create: (context) => GetFollowersBloc(
                                                  userRepository: context.read<AuthenticationBloc>().userRepository)
                                                ..add(GetFollowers(currentPost.author.id)),
                                            ),
                                            BlocProvider(
                                              create: (context) => GetFollowingBloc(
                                                  userRepository: context.read<AuthenticationBloc>().userRepository)
                                                ..add(GetFollowing(currentPost.author.id)),
                                            ),
                                            BlocProvider(
                                              create: (context) =>
                                                  GetPostsBloc(postRepository: FirebasePostRepository())
                                                    ..add(const GetPosts()),
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
                                          ],
                                          child: ProfileScreen(
                                            userData: widget.post.author,
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
                                    )
                                        .then((value) {
                                      context.read<MyUserBloc>().add(GetUserData(userId: state.user!.id));
                                      context.read<GetPostsBloc>().add(const GetPosts());
                                      context.read<GetLikesBloc>().add(GetLikes(currentPost));
                                    });
                                  },
                                  myUserBloc: BlocProvider.of<MyUserBloc>(context),
                                  getPostsBloc: BlocProvider.of<GetPostsBloc>(context),
                                  editPostBloc: BlocProvider.of<EditPostBloc>(context),
                                  deletePostBloc: BlocProvider.of<DeletePostBloc>(context),
                                  likePostBloc: BlocProvider.of<LikePostBloc>(context),
                                  currentUser: context.read<AuthenticationBloc>().state.user,
                                  postController: postContentsController,
                                  commentController: commentContentsController,
                                  isFirstLoad: isFirstLoad,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(36),
                                  color: Theme.of(context).colorScheme.background.withOpacity(0.8),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Theme.of(context).colorScheme.onBackground,
                                        image: DecorationImage(
                                          image: NetworkImage(state.user!.picture.toString()),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: TextField(
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Theme.of(context).colorScheme.onBackground,
                                        ),
                                        controller: commentContentsController,
                                        maxLines: 1,
                                        maxLength: 150,
                                        decoration: InputDecoration(
                                          counterText: "",
                                          hintText: "Add comment...",
                                          border: InputBorder.none,
                                          hintStyle: TextStyle(
                                            fontSize: 14,
                                            color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
                                          ),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        if (commentContentsController.text.isNotEmpty) {
                                          setState(() {
                                            comment.author = state.user!;
                                            comment.contents = commentContentsController.text;
                                          });
                                          context.read<AddCommentBloc>().add(AddComment(currentPost, comment));
                                        }
                                      },
                                      child: Container(
                                        width: 25,
                                        height: 25,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Theme.of(context).colorScheme.onBackground,
                                        ),
                                        child: Icon(Icons.arrow_upward_rounded,
                                            color: Theme.of(context).colorScheme.background, size: 16),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: currentPost.comments.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return Column(
                                    children: [
                                      if (index == 0)
                                        const Divider(
                                          thickness: 0.4,
                                        ),
                                      CommentTile(
                                        onProfileAction: () {
                                          Navigator.of(context).push(
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
                                                    create: (context) => GiveFollowBloc(
                                                        userRepository:
                                                            context.read<AuthenticationBloc>().userRepository),
                                                  ),
                                                  BlocProvider(
                                                    create: (context) => GetFollowersBloc(
                                                        userRepository:
                                                            context.read<AuthenticationBloc>().userRepository)
                                                      ..add(GetFollowers(currentPost.comments[index].author.id)),
                                                  ),
                                                  BlocProvider(
                                                    create: (context) => GetFollowingBloc(
                                                        userRepository:
                                                            context.read<AuthenticationBloc>().userRepository)
                                                      ..add(GetFollowing(currentPost.comments[index].author.id)),
                                                  ),
                                                  BlocProvider(
                                                    create: (context) =>
                                                        GetPostsBloc(postRepository: FirebasePostRepository())
                                                          ..add(const GetPosts()),
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
                                                ],
                                                child: ProfileScreen(
                                                  userData: currentPost.comments[index].author,
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
                                          );
                                        },
                                        currentUser: context.read<AuthenticationBloc>().state.user,
                                        myUserBloc: BlocProvider.of<MyUserBloc>(context),
                                        getPostsBloc: BlocProvider.of<GetPostsBloc>(context),
                                        deleteCommentBloc: BlocProvider.of<DeleteCommentBloc>(context),
                                        likeCommentBloc: BlocProvider.of<LikeCommentBloc>(context),
                                        commentController: commentContentsController,
                                        comment: currentPost.comments[index],
                                        post: currentPost,
                                      ),
                                      const Divider(
                                        thickness: 0.4,
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      } else if (getPostsState is GetPostsProcess) {
                        return Column(
                          children: [
                            const SizedBox(height: 30),
                            Center(
                              child: CircularProgressIndicator(color: Theme.of(context).colorScheme.onBackground),
                            ),
                          ],
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
