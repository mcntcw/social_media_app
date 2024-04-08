part of 'get_following_bloc.dart';

sealed class GetFollowingEvent extends Equatable {
  const GetFollowingEvent();

  @override
  List<Object> get props => [];
}

class GetFollowing extends GetFollowingEvent {
  final String userId;

  const GetFollowing(this.userId);
}
