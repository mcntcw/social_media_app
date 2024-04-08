import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:post_repository/post_repository_library.dart';
import 'package:user_repository/user_repository_library.dart';

part 'get_likes_event.dart';
part 'get_likes_state.dart';

class GetLikesBloc extends Bloc<GetLikesEvent, GetLikesState> {
  final PostRepository _postRepository;
  GetLikesBloc({
    required PostRepository postRepository,
  })  : _postRepository = postRepository,
        super(GetLikesInitial()) {
    on<GetLikes>((event, emit) async {
      try {
        emit(GetLikesProcess());
        List<MyUser> likes = await _postRepository.getLikes(event.post);
        //print("from bloc: ${likes.length}");
        emit(GetLikesSuccess(likes));
      } catch (e) {
        emit(GetLikesFailure());
      }
    });
  }
}
