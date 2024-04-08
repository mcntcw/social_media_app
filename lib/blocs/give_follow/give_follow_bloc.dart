import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:user_repository/user_repository_library.dart';

part 'give_follow_event.dart';
part 'give_follow_state.dart';

class GiveFollowBloc extends Bloc<GiveFollowEvent, GiveFollowState> {
  final UserRepository _userRepository;
  GiveFollowBloc({required UserRepository userRepository})
      : _userRepository = userRepository,
        super(GiveFollowInitial()) {
    on<GiveFollow>((event, emit) async {
      emit(GiveFollowProcess());
      try {
        await _userRepository.giveFollow(event.followGiver, event.followReceiver);
        emit(GiveFollowSuccess());
      } catch (e) {
        emit(GiveFollowFailure());
      }
    });
  }
}
