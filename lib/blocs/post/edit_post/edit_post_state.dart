part of 'edit_post_bloc.dart';

sealed class EditPostState extends Equatable {
  const EditPostState();

  @override
  List<Object> get props => [];
}

final class EditPostInitial extends EditPostState {}

final class EditPostProcess extends EditPostState {}

final class EditPostSuccess extends EditPostState {}

final class EditPostFailure extends EditPostState {}
