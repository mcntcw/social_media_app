import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:user_repository/user_repository_library.dart';
part 'get_followers_event.dart';
part 'get_followers_state.dart';

class GetFollowersBloc extends Bloc<GetFollowersEvent, GetFollowersState> {
  final UserRepository _userRepository;
  GetFollowersBloc({required UserRepository userRepository})
      : _userRepository = userRepository,
        super(GetFollowersInitial()) {
    on<GetFollowers>((event, emit) async {
      emit(GetFollowersProcess());
      try {
        List<MyUser> followers = await _userRepository.getFollowers(event.userId);
        emit(GetFollowersSuccess(followers));
      } catch (e) {
        emit(GetFollowersFailure());
      }
    });
  }
}
