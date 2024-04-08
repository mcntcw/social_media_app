part of 'get_comment_likes_bloc.dart';

sealed class GetCommentLikesState extends Equatable {
  const GetCommentLikesState();

  @override
  List<Object> get props => [];
}

final class GetCommentLikesInitial extends GetCommentLikesState {}

final class GetCommentLikesProcess extends GetCommentLikesState {}

final class GetCommentLikesSuccess extends GetCommentLikesState {
  final List<MyUser> likes;

  const GetCommentLikesSuccess(this.likes);
}

final class GetCommentLikesFailure extends GetCommentLikesState {}
