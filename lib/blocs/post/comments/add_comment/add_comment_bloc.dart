import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:post_repository/post_repository_library.dart';

part 'add_comment_event.dart';
part 'add_comment_state.dart';

class AddCommentBloc extends Bloc<AddCommentEvent, AddCommentState> {
  final PostRepository _postRepository;
  AddCommentBloc({required PostRepository postRepository})
      : _postRepository = postRepository,
        super(AddCommentInitial()) {
    on<AddComment>((event, emit) async {
      emit(AddCommentProcess());
      try {
        Comment comment = await _postRepository.addCommentToPost(event.post, event.comment);
        emit(AddCommentSuccess(comment));
      } catch (e) {
        emit(AddCommentFailure());
      }
    });
  }
}
