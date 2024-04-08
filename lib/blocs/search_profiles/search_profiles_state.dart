part of 'search_profiles_bloc.dart';

sealed class SearchProfilesState extends Equatable {
  const SearchProfilesState();

  @override
  List<Object> get props => [];
}

final class SearchProfilesInitial extends SearchProfilesState {}

final class SearchProfilesProcess extends SearchProfilesState {}

final class SearchProfilesSuccess extends SearchProfilesState {
  final List<MyUser> profiles;

  const SearchProfilesSuccess(this.profiles);
}

final class SearchProfilesFailure extends SearchProfilesState {}
