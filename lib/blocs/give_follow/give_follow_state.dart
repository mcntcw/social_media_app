part of 'give_follow_bloc.dart';

sealed class GiveFollowState extends Equatable {
  const GiveFollowState();

  @override
  List<Object> get props => [];
}

final class GiveFollowInitial extends GiveFollowState {}

final class GiveFollowProcess extends GiveFollowState {}

final class GiveFollowSuccess extends GiveFollowState {}

final class GiveFollowFailure extends GiveFollowState {}
