part of 'edit_user_data_bloc.dart';

sealed class EditUserDataEvent extends Equatable {
  const EditUserDataEvent();

  @override
  List<Object> get props => [];
}

class ChangeProfilePicture extends EditUserDataEvent {
  final String imageUrl;
  final String userId;

  const ChangeProfilePicture(this.imageUrl, this.userId);
}

class ChangeUsername extends EditUserDataEvent {
  final String newUsername;
  final String userId;

  const ChangeUsername(this.newUsername, this.userId);
}
