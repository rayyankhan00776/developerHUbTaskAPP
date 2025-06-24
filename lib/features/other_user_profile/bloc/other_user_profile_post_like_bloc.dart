import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:client/features/dashboard/repositories/feed_repository.dart';

// Events
abstract class OtherUserProfilePostLikeEvent {}

class LikeOtherUserPostEvent extends OtherUserProfilePostLikeEvent {
  final String postId;
  LikeOtherUserPostEvent(this.postId);
}

// States
abstract class OtherUserProfilePostLikeState {}

class OtherUserProfilePostLikeInitial extends OtherUserProfilePostLikeState {}

class OtherUserProfilePostLikeLoading extends OtherUserProfilePostLikeState {}

class OtherUserProfilePostLiked extends OtherUserProfilePostLikeState {
  final String postId;
  final bool likedByUser;
  final int totalLikes;
  OtherUserProfilePostLiked(this.postId, this.likedByUser, this.totalLikes);
}

class OtherUserProfilePostLikeError extends OtherUserProfilePostLikeState {
  final String message;
  OtherUserProfilePostLikeError(this.message);
}

class OtherUserProfilePostLikeBloc
    extends Bloc<OtherUserProfilePostLikeEvent, OtherUserProfilePostLikeState> {
  final FeedRepository feedRepository;
  OtherUserProfilePostLikeBloc(this.feedRepository)
    : super(OtherUserProfilePostLikeInitial()) {
    on<LikeOtherUserPostEvent>((event, emit) async {
      emit(OtherUserProfilePostLikeLoading());
      try {
        final liked = await feedRepository.likePost(event.postId);
        // You may want to fetch the updated like count from backend if needed
        emit(OtherUserProfilePostLiked(event.postId, liked, -1));
      } catch (e) {
        emit(OtherUserProfilePostLikeError(e.toString()));
      }
    });
  }
}
