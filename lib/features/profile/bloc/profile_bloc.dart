import 'dart:io';
import 'package:client/features/profile/models/profile_model.dart';
import 'package:client/features/profile/repository/profile_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Events
abstract class ProfileEvent {}

class LoadProfileEvent extends ProfileEvent {}

class UpdateProfilePictureEvent extends ProfileEvent {
  final File imageFile;
  UpdateProfilePictureEvent(this.imageFile);
}

class DeleteProfilePictureEvent extends ProfileEvent {}

class CreatePostEvent extends ProfileEvent {
  final String? content;
  final File? mediaFile;
  CreatePostEvent({this.content, this.mediaFile});
}

class LoadUserPostsEvent extends ProfileEvent {}

class LikePostEvent extends ProfileEvent {
  final String postId;
  LikePostEvent(this.postId);
}

class AddCommentEvent extends ProfileEvent {
  final String postId;
  final String commentText;
  AddCommentEvent(this.postId, this.commentText);
}

class LoadCommentsEvent extends ProfileEvent {
  final String postId;
  LoadCommentsEvent(this.postId);
}

class RefreshProfileEvent extends ProfileEvent {}

class LoadFollowersEvent extends ProfileEvent {}

class LoadFollowingEvent extends ProfileEvent {}

class FollowUserEvent extends ProfileEvent {
  final String userId;
  FollowUserEvent(this.userId);
}

class DeletePostEvent extends ProfileEvent {
  final String postId;
  DeletePostEvent(this.postId);
}

class UpdatePostEvent extends ProfileEvent {
  final String postId;
  final String? content;
  final String? mediaUrl;
  UpdatePostEvent({required this.postId, this.content, this.mediaUrl});
}

// States
abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final ProfileModel profile;
  ProfileLoaded(this.profile);
}

class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
}

class ProfilePictureUpdated extends ProfileState {
  final String profilePicUrl;
  ProfilePictureUpdated(this.profilePicUrl);
}

class ProfilePictureDeleted extends ProfileState {}

class PostCreated extends ProfileState {
  final Post post;
  PostCreated(this.post);
}

class UserPostsLoaded extends ProfileState {
  final List<Post> posts;
  UserPostsLoaded(this.posts);
}

class PostLiked extends ProfileState {
  final String postId;
  final bool isLiked;
  PostLiked(this.postId, this.isLiked);
}

class CommentAdded extends ProfileState {
  final String postId;
  final Comment comment;
  CommentAdded(this.postId, this.comment);
}

class CommentsLoaded extends ProfileState {
  final String postId;
  final List<Comment> comments;
  CommentsLoaded(this.postId, this.comments);
}

class FollowersLoaded extends ProfileState {
  final List<Map<String, dynamic>> followers;
  FollowersLoaded(this.followers);
}

class FollowingLoaded extends ProfileState {
  final List<Map<String, dynamic>> following;
  FollowingLoaded(this.following);
}

class FollowUserSuccess extends ProfileState {
  final String userId;
  final bool following;
  FollowUserSuccess(this.userId, this.following);
}

// BLoC
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository repository;
  ProfileModel? _currentProfile;
  List<Post> _userPosts = [];

  ProfileBloc({required this.repository}) : super(ProfileInitial()) {
    on<LoadProfileEvent>(_onLoadProfile);
    on<UpdateProfilePictureEvent>(_onUpdateProfilePicture);
    on<DeleteProfilePictureEvent>(_onDeleteProfilePicture);
    on<CreatePostEvent>(_onCreatePost);
    on<LoadUserPostsEvent>(_onLoadUserPosts);
    on<LikePostEvent>(_onLikePost);
    on<AddCommentEvent>(_onAddComment);
    on<LoadCommentsEvent>(_onLoadComments);
    on<RefreshProfileEvent>(_onRefreshProfile);
    on<LoadFollowersEvent>((event, emit) async {
      try {
        emit(ProfileLoading());
        final followers = await repository.getFollowers();
        emit(FollowersLoaded(followers));
      } catch (e) {
        emit(ProfileError(e.toString()));
      }
    });
    on<LoadFollowingEvent>((event, emit) async {
      try {
        emit(ProfileLoading());
        final following = await repository.getFollowing();
        emit(FollowingLoaded(following));
      } catch (e) {
        emit(ProfileError(e.toString()));
      }
    });
    on<FollowUserEvent>((event, emit) async {
      try {
        emit(ProfileLoading());
        final following = await repository.followUser(event.userId);
        emit(FollowUserSuccess(event.userId, following));
      } catch (e) {
        emit(ProfileError(e.toString()));
      }
    });
    on<DeletePostEvent>(_onDeletePost);
    on<UpdatePostEvent>(_onUpdatePost);
  }

  Future<void> _onLoadProfile(
    LoadProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      emit(ProfileLoading());
      final profile = await repository.getCurrentUserProfile();
      _currentProfile = profile;
      _userPosts = profile.posts;
      emit(ProfileLoaded(profile));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onUpdateProfilePicture(
    UpdateProfilePictureEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      emit(ProfileLoading());
      final profilePicUrl = await repository.updateProfilePicture(
        event.imageFile,
      );

      if (_currentProfile != null) {
        _currentProfile = _currentProfile!.copyWith(
          profilePicUrl: profilePicUrl,
        );
        emit(ProfileLoaded(_currentProfile!));
      }

      emit(ProfilePictureUpdated(profilePicUrl));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onDeleteProfilePicture(
    DeleteProfilePictureEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      emit(ProfileLoading());
      await repository.deleteProfilePicture();

      if (_currentProfile != null) {
        _currentProfile = _currentProfile!.copyWith(profilePicUrl: null);
        emit(ProfileLoaded(_currentProfile!));
      }

      emit(ProfilePictureDeleted());
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onCreatePost(
    CreatePostEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      emit(ProfileLoading());
      final post = await repository.createPost(
        content: event.content,
        mediaFile: event.mediaFile,
      );

      _userPosts.insert(0, post); // Add new post at the beginning

      if (_currentProfile != null) {
        _currentProfile = _currentProfile!.copyWith(posts: _userPosts);
        emit(ProfileLoaded(_currentProfile!));
      }

      emit(PostCreated(post));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onLoadUserPosts(
    LoadUserPostsEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      emit(ProfileLoading());
      final posts = await repository.getUserPosts();
      _userPosts = posts;

      if (_currentProfile != null) {
        _currentProfile = _currentProfile!.copyWith(posts: posts);
        emit(ProfileLoaded(_currentProfile!));
      }

      emit(UserPostsLoaded(posts));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onLikePost(
    LikePostEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      // Find current post like state
      final currentPost = _userPosts.firstWhere(
        (post) => post.id == event.postId,
      );
      final wasLiked = currentPost.likedByUser;
      final originalLikes = currentPost.totalLikes;

      // Make API call and get new like state
      final isLiked = await repository.likePost(event.postId);

      // Only update if the like state actually changed
      int newLikes = originalLikes;
      if (wasLiked != isLiked) {
        newLikes =
            isLiked
                ? originalLikes + 1
                : (originalLikes > 0 ? originalLikes - 1 : 0);
      }

      _userPosts =
          _userPosts.map((post) {
            if (post.id == event.postId) {
              return post.copyWith(likedByUser: isLiked, totalLikes: newLikes);
            }
            return post;
          }).toList();

      _currentProfile = _currentProfile?.copyWith(posts: _userPosts);
      emit(ProfileLoaded(_currentProfile!));
      emit(PostLiked(event.postId, isLiked));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onAddComment(
    AddCommentEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      final comment = await repository.addComment(
        event.postId,
        event.commentText,
      );

      // Update the post in the local list
      _userPosts =
          _userPosts.map((post) {
            if (post.id == event.postId) {
              final updatedComments = [...post.comments, comment];
              return post.copyWith(comments: updatedComments);
            }
            return post;
          }).toList();

      if (_currentProfile != null) {
        _currentProfile = _currentProfile!.copyWith(posts: _userPosts);
        emit(ProfileLoaded(_currentProfile!));
      }

      emit(CommentAdded(event.postId, comment));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onLoadComments(
    LoadCommentsEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      final comments = await repository.getComments(event.postId);

      // Update the post in the local list
      _userPosts =
          _userPosts.map((post) {
            if (post.id == event.postId) {
              return post.copyWith(comments: comments);
            }
            return post;
          }).toList();

      if (_currentProfile != null) {
        _currentProfile = _currentProfile!.copyWith(posts: _userPosts);
        emit(ProfileLoaded(_currentProfile!));
      }

      emit(CommentsLoaded(event.postId, comments));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onRefreshProfile(
    RefreshProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      final profile = await repository.getCurrentUserProfile();
      _currentProfile = profile;
      _userPosts = profile.posts;
      emit(ProfileLoaded(profile));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onDeletePost(
    DeletePostEvent event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is ProfileLoaded) {
      final currentState = state as ProfileLoaded;
      try {
        await repository.deletePost(event.postId);
        final updatedPosts = List<Post>.from(currentState.profile.posts)
          ..removeWhere((p) => p.id == event.postId);
        final updatedProfile = ProfileModel(
          id: currentState.profile.id,
          name: currentState.profile.name,
          email: currentState.profile.email,
          profilePicUrl: currentState.profile.profilePicUrl,
          posts: updatedPosts,
          followersCount: currentState.profile.followersCount,
          followingCount: currentState.profile.followingCount,
        );
        emit(ProfileLoaded(updatedProfile));
      } catch (e) {
        emit(ProfileError(e.toString()));
        emit(currentState);
      }
    }
  }

  Future<void> _onUpdatePost(
    UpdatePostEvent event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is ProfileLoaded) {
      final currentState = state as ProfileLoaded;
      try {
        final updatedPost = await repository.updatePost(
          postId: event.postId,
          content: event.content,
          mediaUrl: event.mediaUrl,
        );
        final updatedPosts =
            currentState.profile.posts.map((p) {
              if (p.id == event.postId) {
                return updatedPost;
              }
              return p;
            }).toList();
        final updatedProfile = ProfileModel(
          id: currentState.profile.id,
          name: currentState.profile.name,
          email: currentState.profile.email,
          profilePicUrl: currentState.profile.profilePicUrl,
          posts: updatedPosts,
          followersCount: currentState.profile.followersCount,
          followingCount: currentState.profile.followingCount,
        );
        emit(ProfileLoaded(updatedProfile));
      } catch (e) {
        emit(ProfileError(e.toString()));
        emit(currentState);
      }
    }
  }

  // Getters for accessing current data
  ProfileModel? get currentProfile => _currentProfile;
  List<Post> get userPosts => _userPosts;
}
