import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_media_app/blocs/authentication/authentication_bloc.dart';
import 'package:social_media_app/blocs/get_following/get_following_bloc.dart';
import 'package:social_media_app/blocs/give_follow/give_follow_bloc.dart';
import 'package:social_media_app/blocs/my_user/my_user_bloc.dart';
import 'package:social_media_app/blocs/post/delete_post/delete_post_bloc.dart';
import 'package:social_media_app/blocs/post/edit_post/edit_post_bloc.dart';
import 'package:social_media_app/blocs/post/get_likes/get_likes_bloc.dart';
import 'package:social_media_app/blocs/post/get_posts/get_posts_bloc.dart';
import 'package:social_media_app/blocs/post/like_post/like_post_bloc.dart';
import 'package:social_media_app/utils/post_dialog.dart';
import 'package:social_media_app/utils/users_list_bottom_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart' as getx;
import 'package:post_repository/post_repository_library.dart';

class PostFromList extends StatefulWidget {
  final Post post;
  final VoidCallback onProfileAction;
  final VoidCallback onContentsAction;
  final VoidCallback saveScrollPosition;
  final TextEditingController textController;
  final User? currentUser;
  final MyUserBloc myUserBloc;
  final GetPostsBloc getPostsBloc;
  final DeletePostBloc deletePostBloc;
  final EditPostBloc editPostBloc;
  final LikePostBloc likePostBloc;
  final bool isOnProfileScreen;

  const PostFromList({
    Key? key,
    required this.post,
    required this.onProfileAction,
    required this.onContentsAction,
    required this.currentUser,
    required this.textController,
    required this.myUserBloc,
    required this.getPostsBloc,
    required this.deletePostBloc,
    required this.editPostBloc,
    required this.likePostBloc,
    required this.isOnProfileScreen,
    required this.saveScrollPosition,
  }) : super(key: key);

  @override
  State<PostFromList> createState() => _PostFromListState();
}

class _PostFromListState extends State<PostFromList> {
  int likes = 0;
  bool isLiked = false;
  Color likeColor = Colors.transparent;
  Color likeCountTextColor = Colors.transparent;
  IconData likeIcon = CupertinoIcons.burst;
  bool isFirstLoad = true;
  bool isFollowed = false;

  String getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return "Now";
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes} m";
    } else if (difference.inHours < 24) {
      return "${difference.inHours} h";
    } else if (difference.inDays < 30) {
      return "${difference.inDays} d";
    } else {
      final months = (difference.inDays / 30).round();
      return "$months months";
    }
  }

  @override
  Widget build(BuildContext context) {
    //print('przebudowa');
    return BlocBuilder<GetLikesBloc, GetLikesState>(
      builder: (context, state) {
        return BlocListener<LikePostBloc, LikePostState>(
          listener: (context, state) {
            if (state is LikePostSuccess) {
              context.read<GetLikesBloc>().add(GetLikes(widget.post));
            }
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: Theme.of(context).colorScheme.surface,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: widget.onProfileAction,
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Theme.of(context).colorScheme.onBackground,
                                  image: DecorationImage(
                                    image: widget.post.author.picture == null || widget.post.author.picture == ""
                                        ? const AssetImage('assets/images/logo.png')
                                        : NetworkImage(widget.post.author.picture.toString()) as ImageProvider<Object>,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        widget.post.author.name.toLowerCase(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 18,
                                          color: Theme.of(context).colorScheme.onBackground,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      widget.myUserBloc.state.user!.following.contains(widget.post.author.id) ||
                                              widget.myUserBloc.state.user!.id == widget.post.author.id ||
                                              widget.isOnProfileScreen == true
                                          ? Container()
                                          : BlocBuilder<GetFollowingBloc, GetFollowingState>(
                                              builder: (context, state) {
                                                return GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      isFollowed = !isFollowed;
                                                    });
                                                    BlocProvider.of<GiveFollowBloc>(context).add(
                                                        GiveFollow(widget.myUserBloc.state.user!, widget.post.author));
                                                  },
                                                  child: Container(
                                                    width: 80,
                                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: Theme.of(context).colorScheme.primary, width: 2),
                                                      borderRadius: BorderRadius.circular(24),
                                                      color: isFollowed == false
                                                          ? Theme.of(context).colorScheme.background
                                                          : Theme.of(context).colorScheme.primary,
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        isFollowed == false ? 'Follow' : 'Followed!',
                                                        style: TextStyle(
                                                          fontFamily:
                                                              isFollowed == false ? 'InterSemiBold' : 'InterBold',
                                                          fontSize: 11,
                                                          color: isFollowed == false
                                                              ? Theme.of(context).colorScheme.primary
                                                              : Theme.of(context).colorScheme.background,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                    ],
                                  ),
                                  Text(
                                    getTimeAgo(widget.post.createdAt),
                                    style: TextStyle(
                                      fontFamily: 'InterBold',
                                      fontSize: 13,
                                      color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        moreAction(context),
                      ],
                    ),
                    const SizedBox(height: 14),
                    GestureDetector(
                      onTap: widget.onContentsAction,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.post.contents,
                            style: TextStyle(
                              fontFamily: 'InterMedium',
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: Container(
                              constraints: BoxConstraints(
                                maxHeight: widget.post.picture == ""
                                    ? double.infinity
                                    : MediaQuery.of(context).size.height * 0.6,
                              ),
                              child: widget.post.picture == ""
                                  ? Container()
                                  : CachedNetworkImage(
                                      imageUrl: widget.post.picture,
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
                          ),
                          const SizedBox(height: 12),
                          BlocBuilder<GetLikesBloc, GetLikesState>(
                            builder: (context, state) {
                              //print("BlocBuilder Rebuilt with state: $state");
                              if (state is GetLikesSuccess) {
                                //print("likes in success: ${state.likes.length}");
                                if (isFirstLoad) {
                                  likeCountTextColor = Theme.of(context).colorScheme.onBackground;
                                  likeColor = state.likes.contains(widget.myUserBloc.state.user)
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.onBackground;
                                  likeIcon = widget.post.likes.contains(widget.myUserBloc.state.user!.id)
                                      ? CupertinoIcons.burst_fill
                                      : CupertinoIcons.burst;
                                  isLiked = state.likes.contains(widget.myUserBloc.state.user);
                                  likes = state.likes.length;
                                  isFirstLoad = false;
                                }
                                return Row(
                                  children: [
                                    GestureDetector(
                                      child: Icon(
                                        likeIcon,
                                        size: 20,
                                        color: likeColor,
                                      ),
                                      onLongPress: () {
                                        widget.saveScrollPosition();
                                        showModalBottomSheet(
                                          context: context,
                                          backgroundColor: Colors.transparent,
                                          builder: (BuildContext context) {
                                            return UsersListBottomSheet(
                                              listName: 'Likes',
                                              listUsers: state.likes,
                                              post: widget.post,
                                            );
                                          },
                                        ).then((value) {
                                          context.read<MyUserBloc>().add(
                                              GetUserData(userId: context.read<AuthenticationBloc>().state.user!.uid));
                                          context.read<GetPostsBloc>().add(const GetPosts());
                                          context.read<GetLikesBloc>().add(GetLikes(widget.post));
                                        });
                                      },
                                      onTap: () {
                                        setState(() {
                                          if (isLiked) {
                                            likeColor = Theme.of(context).colorScheme.onBackground;
                                            likeIcon = CupertinoIcons.burst;
                                            likes--;
                                          } else {
                                            likeColor = Theme.of(context).colorScheme.primary;
                                            likeIcon = CupertinoIcons.burst_fill;
                                            likes++;
                                          }
                                          isLiked = !isLiked;
                                        });

                                        widget.likePostBloc
                                            .add(LikePost(widget.post, widget.myUserBloc.state.user!.id));
                                      },
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      likes.toString(),
                                      style: TextStyle(
                                        fontFamily: 'InterMedium',
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                        color: likeCountTextColor,
                                      ),
                                    ),
                                  ],
                                );
                              } else if (state is GetLikesProcess) {
                                if (isFirstLoad) {
                                  likeCountTextColor = Theme.of(context).colorScheme.onBackground;
                                  likeColor = widget.post.likes.contains(widget.myUserBloc.state.user!.id)
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.onBackground;
                                  likeIcon = widget.post.likes.contains(widget.myUserBloc.state.user!.id)
                                      ? CupertinoIcons.burst_fill
                                      : CupertinoIcons.burst;
                                  isLiked = widget.post.likes.contains(widget.myUserBloc.state.user!.id);
                                  likes = widget.post.likes.length;
                                  isFirstLoad = false;
                                  //print("likes in process: $likes");
                                }
                                return Row(
                                  children: [
                                    GestureDetector(
                                      child: Icon(
                                        likeIcon,
                                        size: 20,
                                        color: likeColor,
                                      ),
                                      onTap: () {
                                        setState(() {
                                          if (isLiked) {
                                            likeColor = Theme.of(context).colorScheme.onBackground;
                                            likeIcon = CupertinoIcons.burst;
                                            likes--;
                                          } else {
                                            likeColor = Theme.of(context).colorScheme.primary;
                                            likeIcon = CupertinoIcons.burst_fill;
                                            likes++;
                                          }
                                          isLiked = !isLiked;
                                        });

                                        widget.likePostBloc
                                            .add(LikePost(widget.post, widget.myUserBloc.state.user!.id));
                                      },
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      likes.toString(),
                                      style: TextStyle(
                                        fontFamily: 'InterMedium',
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                        color: likeCountTextColor,
                                      ),
                                    ),
                                  ],
                                );
                              } else {
                                return Row(
                                  children: [
                                    GestureDetector(
                                      child: Icon(
                                        likeIcon,
                                        size: 20,
                                        color: likeColor,
                                      ),
                                      onTap: () {},
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      '',
                                      style: TextStyle(
                                        fontFamily: 'InterMedium',
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                        color: likeCountTextColor,
                                      ),
                                    ),
                                  ],
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  PopupMenuButton<dynamic> moreAction(BuildContext context) {
    return PopupMenuButton(
      padding: EdgeInsets.zero,
      elevation: 0,
      color: Theme.of(context).colorScheme.onBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14.0),
      ),
      itemBuilder: widget.post.author.id == widget.currentUser!.uid
          ? (BuildContext context) {
              return <PopupMenuEntry>[
                PopupMenuItem(
                  child: GestureDetector(
                    onTap: () {
                      widget.saveScrollPosition();
                      widget.textController.text = widget.post.contents;
                      showEditPostDialog(context);
                    },
                    child: Text(
                      'Edit',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.background,
                      ),
                    ),
                  ),
                ),
                PopupMenuItem(
                  child: GestureDetector(
                    onTap: () {
                      widget.saveScrollPosition();
                      onDeleteDialog(context);
                    },
                    child: Text(
                      'Delete',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.background,
                      ),
                    ),
                  ),
                ),
              ];
            }
          : (BuildContext context) {
              return <PopupMenuEntry>[
                PopupMenuItem(
                  child: GestureDetector(
                    onTap: () {
                      widget.saveScrollPosition();
                      getx.Get.back();
                    },
                    child: Text(
                      'Report',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.background,
                      ),
                    ),
                  ),
                ),
              ];
            },
      icon: Icon(
        Icons.more_vert_rounded,
        color: Theme.of(context).colorScheme.onBackground,
        size: 20,
      ),
    );
  }

  Future<dynamic> showEditPostDialog(BuildContext context) {
    return showDialog(
      barrierColor: Colors.transparent,
      barrierDismissible: true,
      context: context,
      builder: (BuildContext cntxt) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: PostDialog(
            user: widget.myUserBloc.state.user!,
            textController: widget.textController,
            onCancel: () {
              widget.textController.clear();
              getx.Get.back();
            },
            onAction: () {
              if (widget.textController.text.isNotEmpty) {
                setState(() {
                  widget.editPostBloc.add(EditPost(widget.post, widget.textController.text));
                });
              }
              widget.textController.clear();
              getx.Get.back();
              getx.Get.back();
            },
            onImageAction: () {},
            actionText: 'Update',
            imageBody: Container(
              width: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context).colorScheme.onBackground,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Center(
                  child: widget.post.picture == ''
                      ? Container()
                      : Image.network(
                          widget.post.picture.toString(),
                          fit: BoxFit.fill,
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<dynamic> onDeleteDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.0),
          ),
          elevation: 0,
          backgroundColor: Theme.of(context).colorScheme.onBackground,
          content: Text(
            "Are you sure?",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.background,
              fontSize: 22,
            ),
          ),
          actions: [
            ButtonBar(
              buttonPadding: EdgeInsets.zero,
              children: [
                TextButton(
                  onPressed: () {
                    getx.Get.back();
                    getx.Get.back();
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.background,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    widget.deletePostBloc.add(DeletePost(widget.post));
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.only(top: 6, bottom: 6, left: 18, right: 18),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.background,
                      borderRadius: BorderRadius.circular(60),
                    ),
                    child: Text(
                      'Delete',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onBackground,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        );
      },
    );
  }
}
