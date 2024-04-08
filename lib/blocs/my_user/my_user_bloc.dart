import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:user_repository/user_repository_library.dart';
part 'my_user_event.dart';
part 'my_user_state.dart';

class MyUserBloc extends Bloc<MyUserEvent, MyUserState> {
  final UserRepository _userRepository;
  MyUserBloc({required UserRepository userRepository})
      : _userRepository = userRepository,
        super(const MyUserState.process()) {
    on<GetUserData>((event, emit) async {
      try {
        MyUser user = await _userRepository.getUserData(event.userId);
        emit(MyUserState.success(user));
      } catch (e) {
        emit(const MyUserState.failure());
        log(e.toString());
      }
    });
  }
}
