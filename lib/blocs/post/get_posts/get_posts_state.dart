part of 'get_posts_bloc.dart';

sealed class GetPostsState extends Equatable {
  const GetPostsState();

  @override
  List<Object> get props => [];
}

final class GetPostsInitial extends GetPostsState {}

final class GetPostsProcess extends GetPostsState {}

final class GetPostsSuccess extends GetPostsState {
  final List<Post> posts;

  const GetPostsSuccess(this.posts);
}

final class GetPostsFailure extends GetPostsState {}
