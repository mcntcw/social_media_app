part of 'delete_comment_bloc.dart';

sealed class DeleteCommentState extends Equatable {
  const DeleteCommentState();

  @override
  List<Object> get props => [];
}

final class DeleteCommentInitial extends DeleteCommentState {}

final class DeleteCommentProcess extends DeleteCommentState {}

final class DeleteCommentSuccess extends DeleteCommentState {}

final class DeleteCommentFailure extends DeleteCommentState {}
