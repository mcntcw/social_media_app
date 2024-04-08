part of 'delete_comment_bloc.dart';

sealed class DeleteCommentEvent extends Equatable {
  const DeleteCommentEvent();

  @override
  List<Object> get props => [];
}

class DeleteComment extends DeleteCommentEvent {
  final Post post;
  final Comment comment;

  const DeleteComment(this.post, this.comment);
}
