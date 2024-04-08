import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:user_repository/user_repository_library.dart';
part 'get_following_event.dart';
part 'get_following_state.dart';

class GetFollowingBloc extends Bloc<GetFollowingEvent, GetFollowingState> {
  final UserRepository _userRepository;
  GetFollowingBloc({required UserRepository userRepository})
      : _userRepository = userRepository,
        super(GetFollowingInitial()) {
    on<GetFollowing>((event, emit) async {
      emit(GetFollowingProcess());
      try {
        List<MyUser> following = await _userRepository.getFollowing(event.userId);
        emit(GetFollowingSuccess(following));
      } catch (e) {
        emit(GetFollowingFailure());
      }
    });
  }
}
