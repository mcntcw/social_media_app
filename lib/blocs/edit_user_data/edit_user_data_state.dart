part of 'edit_user_data_bloc.dart';

sealed class EditUserDataState extends Equatable {
  const EditUserDataState();

  @override
  List<Object> get props => [];
}

final class EditUserDataInitial extends EditUserDataState {}

final class ChangeProfilePictureProcess extends EditUserDataState {}

final class ChangeProfilePictureSuccess extends EditUserDataState {
  final String imageUrl;

  const ChangeProfilePictureSuccess(this.imageUrl);
}

final class ChangeProfilePictureFailure extends EditUserDataState {}

//

final class ChangeUsernameProcess extends EditUserDataState {}

final class ChangeUsernameSuccess extends EditUserDataState {
  final String newUsername;

  const ChangeUsernameSuccess(this.newUsername);
}

final class ChangeUsernameFailure extends EditUserDataState {}
