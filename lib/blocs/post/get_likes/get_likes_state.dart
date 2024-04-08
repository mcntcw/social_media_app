part of 'get_likes_bloc.dart';

sealed class GetLikesState extends Equatable {
  const GetLikesState();

  @override
  List<Object> get props => [];
}

final class GetLikesInitial extends GetLikesState {}

final class GetLikesProcess extends GetLikesState {}

final class GetLikesSuccess extends GetLikesState {
  final List<MyUser> likes;

  const GetLikesSuccess(this.likes);
}

final class GetLikesFailure extends GetLikesState {}
