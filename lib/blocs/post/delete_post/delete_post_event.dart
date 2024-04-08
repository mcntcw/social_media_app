part of 'delete_post_bloc.dart';

sealed class DeletePostEvent extends Equatable {
  const DeletePostEvent();

  @override
  List<Object> get props => [];
}

class DeletePost extends DeletePostEvent {
  final Post post;

  const DeletePost(this.post);
}
