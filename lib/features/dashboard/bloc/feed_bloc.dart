import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/post.dart';
import '../repositories/feed_repository.dart';

// Events
abstract class FeedEvent {}

class LoadFeedEvent extends FeedEvent {}

class LikePostEvent extends FeedEvent {
  final String postId;
  LikePostEvent(this.postId);
}

class AddCommentEvent extends FeedEvent {
  final String postId;
  final String comment;
  AddCommentEvent(this.postId, this.comment);
}

// States
abstract class FeedState {}

class FeedInitial extends FeedState {}

class FeedLoading extends FeedState {}

class FeedLoaded extends FeedState {
  final List<Post> posts;
  FeedLoaded(this.posts);
}

class FeedError extends FeedState {
  final String message;
  FeedError(this.message);
}

// BLoC
class FeedBloc extends Bloc<FeedEvent, FeedState> {
  final FeedRepository repository;

  FeedBloc({required this.repository}) : super(FeedInitial()) {
    on<LoadFeedEvent>(_onLoadFeed);
    on<LikePostEvent>(_onLikePost);
    on<AddCommentEvent>(_onAddComment);
  }

  Future<void> _onLoadFeed(LoadFeedEvent event, Emitter<FeedState> emit) async {
    try {
      emit(FeedLoading());
      final posts = await repository.getFeedPosts();
      emit(FeedLoaded(posts));
    } catch (e) {
      emit(FeedError(e.toString()));
    }
  }

  Future<void> _onLikePost(LikePostEvent event, Emitter<FeedState> emit) async {
    try {
      if (state is FeedLoaded) {
        await repository.likePost(event.postId);
        // Refresh feed after liking
        add(LoadFeedEvent());
      }
    } catch (e) {
      emit(FeedError(e.toString()));
    }
  }

  Future<void> _onAddComment(
    AddCommentEvent event,
    Emitter<FeedState> emit,
  ) async {
    try {
      if (state is FeedLoaded) {
        await repository.addComment(event.postId, event.comment);
        // Refresh feed after commenting
        add(LoadFeedEvent());
      }
    } catch (e) {
      emit(FeedError(e.toString()));
    }
  }
}
