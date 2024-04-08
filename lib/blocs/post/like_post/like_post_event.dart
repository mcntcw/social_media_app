part of 'like_post_bloc.dart';

sealed class LikePostEvent extends Equatable {
  const LikePostEvent();

  @override
  List<Object> get props => [];
}

class LikePost extends LikePostEvent {
  final Post post;
  final String likerId;

  const LikePost(this.post, this.likerId);
}
