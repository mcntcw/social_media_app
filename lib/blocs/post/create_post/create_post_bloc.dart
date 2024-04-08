import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:post_repository/post_repository_library.dart';
part 'create_post_event.dart';
part 'create_post_state.dart';

class CreatePostBloc extends Bloc<CreatePostEvent, CreatePostState> {
  final PostRepository _postRepository;

  CreatePostBloc({required PostRepository postRepository})
      : _postRepository = postRepository,
        super(CreatePostInitial()) {
    on<CreatePost>((event, emit) async {
      emit(CreatePostProcess());
      try {
        Post post = await _postRepository.createPost(event.post, event.imageUrl);
        emit(CreatePostSuccess(post));
      } catch (e) {
        emit(CreatePostFailure());
      }
    });
  }
}
