part of 'add_comment_bloc.dart';

sealed class AddCommentState extends Equatable {
  const AddCommentState();

  @override
  List<Object> get props => [];
}

final class AddCommentInitial extends AddCommentState {}

final class AddCommentProcess extends AddCommentState {}

final class AddCommentSuccess extends AddCommentState {
  final Comment comment;

  const AddCommentSuccess(this.comment);
}

final class AddCommentFailure extends AddCommentState {}
