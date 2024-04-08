import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:user_repository/user_repository_library.dart';

part 'search_profiles_event.dart';
part 'search_profiles_state.dart';

class SearchProfilesBloc extends Bloc<SearchProfilesEvent, SearchProfilesState> {
  final UserRepository _userRepository;
  SearchProfilesBloc({required UserRepository userRepository})
      : _userRepository = userRepository,
        super(SearchProfilesInitial()) {
    on<SearchProfiles>((event, emit) async {
      emit(SearchProfilesProcess());
      try {
        List<MyUser> profiles = await _userRepository.searchProfilesByName(event.searchingText);
        emit(SearchProfilesSuccess(profiles));
      } catch (e) {
        emit(SearchProfilesFailure());
      }
    });
  }
}
