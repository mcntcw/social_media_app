part of 'get_comment_likes_bloc.dart';

sealed class GetCommentLikesEvent extends Equatable {
  const GetCommentLikesEvent();

  @override
  List<Object> get props => [];
}

class GetCommentLikes extends GetCommentLikesEvent {
  final Post post;
  final Comment comment;

  const GetCommentLikes(this.post, this.comment);
}
