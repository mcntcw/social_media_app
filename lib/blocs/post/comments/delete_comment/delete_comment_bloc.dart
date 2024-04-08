import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:post_repository/post_repository_library.dart';
part 'delete_comment_event.dart';
part 'delete_comment_state.dart';

class DeleteCommentBloc extends Bloc<DeleteCommentEvent, DeleteCommentState> {
  final PostRepository _postRepository;
  DeleteCommentBloc({required PostRepository postRepository})
      : _postRepository = postRepository,
        super(DeleteCommentInitial()) {
    on<DeleteComment>((event, emit) async {
      emit(DeleteCommentProcess());
      try {
        await _postRepository.deleteCommentFromPost(event.post, event.comment);
        emit(DeleteCommentSuccess());
      } catch (e) {
        emit(DeleteCommentFailure());
      }
    });
  }
}
