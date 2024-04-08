part of 'like_comment_bloc.dart';

sealed class LikeCommentState extends Equatable {
  const LikeCommentState();

  @override
  List<Object> get props => [];
}

final class LikeCommentInitial extends LikeCommentState {}

final class LikeCommentProcess extends LikeCommentState {}

final class LikeCommentSuccess extends LikeCommentState {}

final class LikeCommentFailure extends LikeCommentState {}
