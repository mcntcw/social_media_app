import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:post_repository/post_repository_library.dart';
part 'edit_post_event.dart';
part 'edit_post_state.dart';

class EditPostBloc extends Bloc<EditPostEvent, EditPostState> {
  final PostRepository _postRepository;

  EditPostBloc({
    required PostRepository postRepository,
  })  : _postRepository = postRepository,
        super(EditPostInitial()) {
    on<EditPost>((event, emit) async {
      emit(EditPostProcess());
      try {
        await _postRepository.editPost(event.post, event.editedContent);
        emit(EditPostSuccess());
      } catch (e) {
        emit(EditPostFailure());
      }
    });
  }
}
