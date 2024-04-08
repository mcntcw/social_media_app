part of 'my_user_bloc.dart';

sealed class MyUserEvent extends Equatable {
  const MyUserEvent();

  @override
  List<Object> get props => [];
}

class GetUserData extends MyUserEvent {
  final String userId;

  const GetUserData({required this.userId});

  @override
  List<Object> get props => [userId];
}
