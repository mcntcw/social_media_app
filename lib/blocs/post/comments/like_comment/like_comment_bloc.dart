import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:post_repository/post_repository_library.dart';
part 'like_comment_event.dart';
part 'like_comment_state.dart';

class LikeCommentBloc extends Bloc<LikeCommentEvent, LikeCommentState> {
  final PostRepository _postRepository;
  LikeCommentBloc({required PostRepository postRepository})
      : _postRepository = postRepository,
        super(LikeCommentInitial()) {
    on<LikeComment>((event, emit) async {
      emit(LikeCommentProcess());
      try {
        await _postRepository.likeComment(event.post, event.comment, event.likerId);
        emit(LikeCommentSuccess());
      } catch (e) {
        emit(LikeCommentFailure());
      }
    });
  }
}
