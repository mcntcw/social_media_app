import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:post_repository/post_repository_library.dart';
import 'package:user_repository/user_repository_library.dart';

part 'get_comment_likes_event.dart';
part 'get_comment_likes_state.dart';

class GetCommentLikesBloc extends Bloc<GetCommentLikesEvent, GetCommentLikesState> {
  final PostRepository _postRepository;
  GetCommentLikesBloc({
    required PostRepository postRepository,
  })  : _postRepository = postRepository,
        super(GetCommentLikesInitial()) {
    on<GetCommentLikes>((event, emit) async {
      try {
        emit(GetCommentLikesProcess());
        List<MyUser> likes = await _postRepository.getCommentLikes(event.post, event.comment);
        emit(GetCommentLikesSuccess(likes));
      } catch (e) {
        emit(GetCommentLikesFailure());
      }
    });
  }
}
