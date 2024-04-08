part of 'get_likes_bloc.dart';

sealed class GetLikesEvent extends Equatable {
  const GetLikesEvent();

  @override
  List<Object> get props => [];
}

class GetLikes extends GetLikesEvent {
  final Post post;

  const GetLikes(this.post);
}
