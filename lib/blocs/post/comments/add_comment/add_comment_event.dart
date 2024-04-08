part of 'add_comment_bloc.dart';

sealed class AddCommentEvent extends Equatable {
  const AddCommentEvent();

  @override
  List<Object> get props => [];
}

class AddComment extends AddCommentEvent {
  final Post post;
  final Comment comment;

  const AddComment(this.post, this.comment);
}
