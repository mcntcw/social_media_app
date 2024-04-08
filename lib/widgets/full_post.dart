import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_media_app/blocs/authentication/authentication_bloc.dart';
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
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:post_repository/post_repository_library.dart';

// ignore: must_be_immutable
class FullPost extends StatefulWidget {
  final Post post;
  final VoidCallback clickToProfile;
  final TextEditingController postController;
  final TextEditingController commentController;
  bool isFirstLoad;
  final User? currentUser;
  final MyUserBloc myUserBloc;
  final GetPostsBloc getPostsBloc;
  final DeletePostBloc deletePostBloc;
  final EditPostBloc editPostBloc;
  final LikePostBloc likePostBloc;

  FullPost(
      {super.key,
      required this.post,
      required this.clickToProfile,
      required this.currentUser,
      required this.deletePostBloc,
      required this.postController,
      required this.isFirstLoad,
      required this.myUserBloc,
      required this.getPostsBloc,
      required this.editPostBloc,
      required this.commentController,
      required this.likePostBloc});

  @override
  State<FullPost> createState() => _FullPostState();
}

class _FullPostState extends State<FullPost> {
  FirebasePostRepository postRepository = FirebasePostRepository();

  int likes = 0;
  bool isLiked = false;
  Color likeColor = Colors.transparent;
  IconData likeIcon = CupertinoIcons.burst;
  Color likeCountTextColor = Colors.transparent;

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
    return BlocListener<LikePostBloc, LikePostState>(
      listener: (context, state) {
        if (state is LikePostSuccess) {
          context.read<GetLikesBloc>().add(GetLikes(widget.post));
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: widget.clickToProfile,
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
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
                        const SizedBox(width: 10),
                        Text(
                          widget.post.author.name.toLowerCase(),
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 22,
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                        ),
                      ],
                    ),
                  ),
                  moreAction(context),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                widget.post.contents,
                style: TextStyle(
                  fontFamily: 'InterMedium',
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
              const SizedBox(height: 15),
              Center(
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: widget.post.picture == "" ? double.infinity : MediaQuery.of(context).size.height * 0.6,
                  ),
                  child: widget.post.picture == ""
                      ? Container()
                      : InteractiveViewer(
                          child: CachedNetworkImage(
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
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BlocBuilder<GetLikesBloc, GetLikesState>(
                builder: (context, state) {
                  if (state is GetLikesSuccess) {
                    //print(likes);
                    if (widget.isFirstLoad) {
                      likeCountTextColor = Theme.of(context).colorScheme.onBackground;
                      likeColor = state.likes.contains(widget.myUserBloc.state.user)
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onBackground;
                      likeIcon = widget.post.likes.contains(widget.myUserBloc.state.user!.id)
                          ? CupertinoIcons.burst_fill
                          : CupertinoIcons.burst;
                      isLiked = state.likes.contains(widget.myUserBloc.state.user);
                      likes = state.likes.length;
                      widget.isFirstLoad = false;
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
                              context
                                  .read<MyUserBloc>()
                                  .add(GetUserData(userId: context.read<AuthenticationBloc>().state.user!.uid));
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

                            widget.likePostBloc.add(LikePost(widget.post, widget.myUserBloc.state.user!.id));
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
                    if (widget.isFirstLoad) {
                      likeCountTextColor = Theme.of(context).colorScheme.onBackground;
                      likeColor = widget.post.likes.contains(widget.myUserBloc.state.user!.id)
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onBackground;
                      likeIcon = widget.post.likes.contains(widget.myUserBloc.state.user!.id)
                          ? CupertinoIcons.burst_fill
                          : CupertinoIcons.burst;
                      isLiked = widget.post.likes.contains(widget.myUserBloc.state.user!.id);
                      likes = widget.post.likes.length;
                      widget.isFirstLoad = false;
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

                            widget.likePostBloc.add(LikePost(widget.post, widget.myUserBloc.state.user!.id));
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
              Text(
                DateFormat('dd.MM.yyyy HH:mm').format(widget.post.createdAt),
                style: TextStyle(
                  fontFamily: 'InterMedium',
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ],
      ),
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
                      widget.postController.text = widget.post.contents;
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
                      Get.back();
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
            textController: widget.postController,
            onCancel: () {
              widget.postController.clear();
              Get.back();
            },
            onAction: () {
              if (widget.postController.text.isNotEmpty) {
                setState(() {
                  widget.editPostBloc.add(EditPost(widget.post, widget.postController.text));
                });
              }
              widget.postController.clear();
              Get.back();
              Get.back();
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
                    Get.back();
                    Get.back();
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
                    Get.back();
                    Get.back();
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
