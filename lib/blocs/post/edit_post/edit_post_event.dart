part of 'edit_post_bloc.dart';

sealed class EditPostEvent extends Equatable {
  const EditPostEvent();

  @override
  List<Object> get props => [];
}

class EditPost extends EditPostEvent {
  final Post post;
  final String editedContent;

  const EditPost(this.post, this.editedContent);
}
