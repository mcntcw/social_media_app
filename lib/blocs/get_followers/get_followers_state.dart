part of 'get_followers_bloc.dart';

sealed class GetFollowersState extends Equatable {
  const GetFollowersState();

  @override
  List<Object> get props => [];
}

final class GetFollowersInitial extends GetFollowersState {}

final class GetFollowersProcess extends GetFollowersState {}

final class GetFollowersSuccess extends GetFollowersState {
  final List<MyUser> followers;

  const GetFollowersSuccess(this.followers);
}

final class GetFollowersFailure extends GetFollowersState {}
