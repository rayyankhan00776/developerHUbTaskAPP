import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/user_search_repository.dart';
import 'user_search_event_state.dart';

class UserSearchBloc extends Bloc<UserSearchEvent, UserSearchState> {
  final UserSearchRepository repository;
  UserSearchBloc(this.repository) : super(UserSearchInitial()) {
    on<UserSearchQueryChanged>(_onQueryChanged);
  }

  Future<void> _onQueryChanged(
    UserSearchQueryChanged event,
    Emitter<UserSearchState> emit,
  ) async {
    if (event.query.isEmpty) {
      emit(UserSearchInitial());
      return;
    }
    emit(UserSearchLoading());
    try {
      final results = await repository.searchUsers(event.query);
      emit(UserSearchLoaded(results));
    } catch (e) {
      emit(UserSearchError(e.toString()));
    }
  }
}
