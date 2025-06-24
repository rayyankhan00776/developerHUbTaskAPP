import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/other_user_profile_model.dart';
import '../repository/other_user_profile_repository.dart';
import 'package:client/features/dashboard/repositories/feed_repository.dart';

// Events
abstract class OtherUserProfileEvent {}

class LoadOtherUserProfileEvent extends OtherUserProfileEvent {
  final String userId;
  LoadOtherUserProfileEvent(this.userId);
}

class LikeOtherUserProfilePostEvent extends OtherUserProfileEvent {
  final String postId;
  LikeOtherUserProfilePostEvent(this.postId);
}

class FollowOrUnfollowOtherUserEvent extends OtherUserProfileEvent {
  final String userId;
  FollowOrUnfollowOtherUserEvent(this.userId);
}

// States
abstract class OtherUserProfileState {}

class OtherUserProfileInitial extends OtherUserProfileState {}

class OtherUserProfileLoading extends OtherUserProfileState {}

class OtherUserProfileLoaded extends OtherUserProfileState {
  final OtherUserProfileModel profile;
  OtherUserProfileLoaded(this.profile);
}

class OtherUserProfileError extends OtherUserProfileState {
  final String message;
  OtherUserProfileError(this.message);
}

class OtherUserProfileBloc
    extends Bloc<OtherUserProfileEvent, OtherUserProfileState> {
  final OtherUserProfileRepository repository;
  final FeedRepository feedRepository = FeedRepository();
  OtherUserProfileBloc(this.repository) : super(OtherUserProfileInitial()) {
    on<LoadOtherUserProfileEvent>((event, emit) async {
      emit(OtherUserProfileLoading());
      try {
        final profile = await repository.getOtherUserProfile(event.userId);
        emit(OtherUserProfileLoaded(profile));
      } catch (e) {
        emit(OtherUserProfileError(e.toString()));
      }
    });
    on<LikeOtherUserProfilePostEvent>((event, emit) async {
      if (state is OtherUserProfileLoaded) {
        final currentState = state as OtherUserProfileLoaded;
        final posts = List<Post>.from(currentState.profile.posts);
        final postIndex = posts.indexWhere((p) => p.id == event.postId);
        if (postIndex != -1) {
          try {
            final liked = await repository.likeOrUnlikePost(event.postId);
            final oldPost = posts[postIndex];
            final newTotalLikes =
                liked
                    ? oldPost.totalLikes + 1
                    : (oldPost.totalLikes > 0 ? oldPost.totalLikes - 1 : 0);
            posts[postIndex] = Post(
              id: oldPost.id,
              content: oldPost.content,
              mediaUrl: oldPost.mediaUrl,
              createdAt: oldPost.createdAt,
              totalLikes: newTotalLikes,
              profilePicUrl: oldPost.profilePicUrl,
              comments: oldPost.comments,
              likedByUser: liked,
            );
            final updatedProfile = OtherUserProfileModel(
              id: currentState.profile.id,
              username: currentState.profile.username,
              profilePicUrl: currentState.profile.profilePicUrl,
              posts: posts,
              followersCount: currentState.profile.followersCount,
              followingCount: currentState.profile.followingCount,
              isFollowing: currentState.profile.isFollowing,
            );
            emit(OtherUserProfileLoaded(updatedProfile));
          } catch (e) {
            emit(OtherUserProfileError(e.toString()));
            emit(currentState); // revert to previous state
          }
        }
      }
    });
    on<FollowOrUnfollowOtherUserEvent>((event, emit) async {
      if (state is OtherUserProfileLoaded) {
        final currentState = state as OtherUserProfileLoaded;
        try {
          final following = await repository.followOrUnfollowUser(event.userId);
          final updatedProfile = OtherUserProfileModel(
            id: currentState.profile.id,
            username: currentState.profile.username,
            profilePicUrl: currentState.profile.profilePicUrl,
            posts: currentState.profile.posts,
            followersCount:
                following
                    ? currentState.profile.followersCount + 1
                    : (currentState.profile.followersCount > 0
                        ? currentState.profile.followersCount - 1
                        : 0),
            followingCount: currentState.profile.followingCount,
            isFollowing: following,
          );
          emit(OtherUserProfileLoaded(updatedProfile));
        } catch (e) {
          emit(OtherUserProfileError(e.toString()));
          emit(currentState); // revert to previous state
        }
      }
    });
  }
}
