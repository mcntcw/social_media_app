part of 'get_following_bloc.dart';

sealed class GetFollowingState extends Equatable {
  const GetFollowingState();

  @override
  List<Object> get props => [];
}

final class GetFollowingInitial extends GetFollowingState {}

final class GetFollowingProcess extends GetFollowingState {}

final class GetFollowingSuccess extends GetFollowingState {
  final List<MyUser> following;

  const GetFollowingSuccess(this.following);
}

final class GetFollowingFailure extends GetFollowingState {}
