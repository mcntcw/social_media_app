part of 'like_comment_bloc.dart';

sealed class LikeCommentEvent extends Equatable {
  const LikeCommentEvent();

  @override
  List<Object> get props => [];
}

class LikeComment extends LikeCommentEvent {
  final Post post;
  final Comment comment;
  final String likerId;

  const LikeComment(this.post, this.comment, this.likerId);
}
