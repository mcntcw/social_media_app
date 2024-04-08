part of 'get_followers_bloc.dart';

sealed class GetFollowersEvent extends Equatable {
  const GetFollowersEvent();

  @override
  List<Object> get props => [];
}

class GetFollowers extends GetFollowersEvent {
  final String userId;

  const GetFollowers(this.userId);
}
