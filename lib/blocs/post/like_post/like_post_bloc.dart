import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:post_repository/post_repository_library.dart';
part 'like_post_event.dart';
part 'like_post_state.dart';

class LikePostBloc extends Bloc<LikePostEvent, LikePostState> {
  final PostRepository _postRepository;
  LikePostBloc({required PostRepository postRepository})
      : _postRepository = postRepository,
        super(LikePostInitial()) {
    on<LikePost>((event, emit) async {
      emit(LikePostProcess());
      try {
        await _postRepository.likePost(event.post, event.likerId);
        emit(LikePostSuccess());
      } catch (e) {
        emit(LikePostFailure());
      }
    });
  }
}
