import 'package:equatable/equatable.dart';
import '../repositories/user_search_repository.dart';

abstract class UserSearchEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class UserSearchQueryChanged extends UserSearchEvent {
  final String query;
  UserSearchQueryChanged(this.query);
  @override
  List<Object?> get props => [query];
}

abstract class UserSearchState extends Equatable {
  @override
  List<Object?> get props => [];
}

class UserSearchInitial extends UserSearchState {}

class UserSearchLoading extends UserSearchState {}

class UserSearchLoaded extends UserSearchState {
  final List<UserSearchResult> results;
  UserSearchLoaded(this.results);
  @override
  List<Object?> get props => [results];
}

class UserSearchError extends UserSearchState {
  final String message;
  UserSearchError(this.message);
  @override
  List<Object?> get props => [message];
}
