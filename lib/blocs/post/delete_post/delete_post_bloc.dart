import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:post_repository/post_repository_library.dart';
part 'delete_post_event.dart';
part 'delete_post_state.dart';

class DeletePostBloc extends Bloc<DeletePostEvent, DeletePostState> {
  final PostRepository _postRepository;
  DeletePostBloc({required PostRepository postRepository})
      : _postRepository = postRepository,
        super(DeletePostInitial()) {
    on<DeletePost>((event, emit) async {
      emit(DeletePostProcess());
      try {
        await _postRepository.deletePost(event.post);
        emit(DeletePostSuccess());
      } catch (e) {
        emit(DeletePostFailure());
      }
    });
  }
}
