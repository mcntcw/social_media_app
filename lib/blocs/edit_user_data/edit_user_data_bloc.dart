import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:user_repository/user_repository_library.dart';

part 'edit_user_data_event.dart';
part 'edit_user_data_state.dart';

class EditUserDataBloc extends Bloc<EditUserDataEvent, EditUserDataState> {
  final UserRepository _userRepository;
  EditUserDataBloc({required UserRepository userRepository})
      : _userRepository = userRepository,
        super(EditUserDataInitial()) {
    on<ChangeProfilePicture>((event, emit) async {
      emit(ChangeProfilePictureProcess());
      try {
        String userImage = await _userRepository.changeProfilePicture(event.imageUrl, event.userId);
        emit(ChangeProfilePictureSuccess(userImage));
      } catch (e) {
        emit(ChangeProfilePictureFailure());
      }
    });
    on<ChangeUsername>((event, emit) async {
      emit(ChangeUsernameProcess());
      try {
        String userImage = await _userRepository.changeUsername(event.newUsername, event.userId);
        emit(ChangeUsernameSuccess(userImage));
      } catch (e) {
        emit(ChangeUsernameFailure());
      }
    });
  }
}
