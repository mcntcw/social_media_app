part of 'give_follow_bloc.dart';

sealed class GiveFollowEvent extends Equatable {
  const GiveFollowEvent();

  @override
  List<Object> get props => [];
}

class GiveFollow extends GiveFollowEvent {
  final MyUser followGiver;
  final MyUser followReceiver;

  const GiveFollow(this.followGiver, this.followReceiver);
}
