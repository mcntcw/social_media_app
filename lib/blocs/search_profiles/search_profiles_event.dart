part of 'search_profiles_bloc.dart';

sealed class SearchProfilesEvent extends Equatable {
  const SearchProfilesEvent();

  @override
  List<Object> get props => [];
}

class SearchProfiles extends SearchProfilesEvent {
  final String searchingText;

  const SearchProfiles(this.searchingText);
}
