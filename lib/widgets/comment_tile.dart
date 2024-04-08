import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_media_app/blocs/my_user/my_user_bloc.dart';
import 'package:social_media_app/blocs/post/comments/delete_comment/delete_comment_bloc.dart';
import 'package:social_media_app/blocs/post/comments/get_comment_likes/get_comment_likes_bloc.dart';
import 'package:social_media_app/blocs/post/comments/like_comment/like_comment_bloc.dart';
import 'package:social_media_app/blocs/post/get_posts/get_posts_bloc.dart';
import 'package:social_media_app/utils/users_list_bottom_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:post_repository/post_repository_library.dart';
import 'package:get/get.dart' as getx;

class CommentTile extends StatefulWidget {
  final Comment comment;
  final Post post;
  final TextEditingController commentController;
  final User? currentUser;
  final VoidCallback onProfileAction;
  final MyUserBloc myUserBloc;
  final GetPostsBloc getPostsBloc;
  final DeleteCommentBloc deleteCommentBloc;
  final LikeCommentBloc likeCommentBloc;

  const CommentTile(
      {super.key,
      required this.myUserBloc,
      required this.getPostsBloc,
      required this.commentController,
      required this.comment,
      required this.currentUser,
      required this.deleteCommentBloc,
      required this.post,
      required this.likeCommentBloc,
      required this.onProfileAction});

  @override
  State<CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends State<CommentTile> {
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

  int likes = 0;
  bool isLiked = false;
  Color likeColor = Colors.white;
  IconData likeIcon = CupertinoIcons.burst;
  Color likeCountTextColor = Colors.white;
  bool isFirstLoad = true;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetCommentLikesBloc(postRepository: FirebasePostRepository())
        ..add(GetCommentLikes(widget.post, widget.comment)),
      child: BlocListener<LikeCommentBloc, LikeCommentState>(
        listener: (context, state) {
          if (state is LikeCommentSuccess) {
            context.read<GetCommentLikesBloc>().add(GetCommentLikes(widget.post, widget.comment));
          }
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(36),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: widget.onProfileAction,
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
                          image: widget.comment.author.picture == null || widget.comment.author.picture == ""
                              ? const AssetImage('assets/images/logo.png')
                              : NetworkImage(widget.comment.author.picture.toString()) as ImageProvider<Object>,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            widget.comment.author.name.toLowerCase(),
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                          ),
                          Text(
                            getTimeAgo(widget.comment.createdAt),
                            style: TextStyle(
                              fontFamily: 'InterBold',
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width: 43),
                  Expanded(
                    child: Text(
                      widget.comment.contents,
                      style: TextStyle(
                        fontFamily: 'InterMedium',
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  BlocBuilder<GetCommentLikesBloc, GetCommentLikesState>(
                    builder: (context, state) {
                      if (state is GetCommentLikesSuccess) {
                        if (isFirstLoad) {
                          likeCountTextColor = Theme.of(context).colorScheme.onBackground;
                          likeColor = state.likes.contains(widget.myUserBloc.state.user)
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onBackground;
                          likeIcon = state.likes.contains(widget.myUserBloc.state.user)
                              ? CupertinoIcons.burst_fill
                              : CupertinoIcons.burst;
                          isLiked = state.likes.contains(widget.myUserBloc.state.user);
                          likes = state.likes.length;
                          isFirstLoad = false;
                        }
                        return Column(
                          children: [
                            GestureDetector(
                              child: Icon(
                                likeIcon,
                                size: 12,
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
                                );
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

                                widget.likeCommentBloc
                                    .add(LikeComment(widget.post, widget.comment, widget.myUserBloc.state.user!.id));
                              },
                            ),
                            const SizedBox(width: 2),
                            Text(
                              likes.toString(),
                              style: TextStyle(
                                fontFamily: 'InterMedium',
                                fontWeight: FontWeight.w500,
                                fontSize: 10,
                                color: likeCountTextColor,
                              ),
                            ),
                          ],
                        );
                      } else if (state is GetCommentLikesProcess) {
                        if (isFirstLoad) {
                          likeCountTextColor = Theme.of(context).colorScheme.onBackground;
                          likeColor = widget.comment.likes.contains(widget.myUserBloc.state.user!.id)
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onBackground;
                          likeIcon = widget.comment.likes.contains(widget.myUserBloc.state.user!.id)
                              ? CupertinoIcons.burst_fill
                              : CupertinoIcons.burst;
                          isLiked = widget.comment.likes.contains(widget.myUserBloc.state.user!.id);
                          likes = widget.comment.likes.length;
                          isFirstLoad = false;
                        }
                        return Column(
                          children: [
                            GestureDetector(
                              child: Icon(
                                likeIcon,
                                size: 12,
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

                                widget.likeCommentBloc
                                    .add(LikeComment(widget.post, widget.comment, widget.myUserBloc.state.user!.id));
                              },
                            ),
                            const SizedBox(width: 2),
                            Text(
                              likes.toString(),
                              style: TextStyle(
                                fontFamily: 'InterMedium',
                                fontWeight: FontWeight.w500,
                                fontSize: 10,
                                color: likeCountTextColor,
                              ),
                            ),
                          ],
                        );
                      } else {
                        return Container();
                      }
                    },
                  ),
                  moreAction(context),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  PopupMenuButton<dynamic> moreAction(BuildContext context) {
    return PopupMenuButton(
      splashRadius: 2,
      padding: EdgeInsets.zero,
      elevation: 0,
      color: Theme.of(context).colorScheme.onBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14.0),
      ),
      itemBuilder: widget.comment.author.id == widget.currentUser!.uid
          ? (BuildContext context) {
              return <PopupMenuEntry>[
                PopupMenuItem(
                  child: GestureDetector(
                    onTap: () {
                      onDeleteDialog(context);
                    },
                    child: Text(
                      'Delete',
                      style: TextStyle(
                        fontSize: 13,
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
                      getx.Get.back();
                    },
                    child: Text(
                      'Report',
                      style: TextStyle(
                        fontSize: 13,
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
        size: 16,
      ),
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
                    widget.deleteCommentBloc.add(DeleteComment(widget.post, widget.comment));
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
