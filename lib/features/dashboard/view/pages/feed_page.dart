import 'package:client/core/themes/pallete.dart';
import 'package:client/features/profile/bloc/profile_bloc.dart';
import 'package:client/features/profile/view/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/feed_post_widget.dart';
import '../../bloc/feed_bloc.dart';
import '../../bloc/user_search_bloc.dart';
import '../../bloc/user_search_event_state.dart';
import '../../repositories/user_search_repository.dart';
import 'package:client/core/constants/api.dart';
import '../../repositories/feed_repository.dart';
import '../../bloc/notification_bloc.dart';
import '../../bloc/notification_event_state.dart';
import '../../repositories/notification_repository.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  @override
  void initState() {
    super.initState();
    _loadFeed();
  }

  void _loadFeed() {
    context.read<FeedBloc>().add(LoadFeedEvent());
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<FeedBloc>(
          create: (context) => FeedBloc(repository: FeedRepository()),
        ),
        BlocProvider<UserSearchBloc>(
          create:
              (context) =>
                  UserSearchBloc(UserSearchRepository(baseUrl: baseUrl)),
        ),
      ],
      child: _FeedPageBody(),
    );
  }
}

class _FeedPageBody extends StatefulWidget {
  @override
  State<_FeedPageBody> createState() => _FeedPageBodyState();
}

class _FeedPageBodyState extends State<_FeedPageBody> {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey _notifKey = GlobalKey();
  OverlayEntry? _notifOverlay;

  void _showNotificationsDropdown(BuildContext context) {
    if (_notifOverlay != null) return;
    final renderBox =
        _notifKey.currentContext?.findRenderObject() as RenderBox?;
    final offset = renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
    final size = renderBox?.size ?? Size.zero;
    _notifOverlay = OverlayEntry(
      builder:
          (context) => Positioned(
            top: offset.dy + size.height + 8,
            right: 16,
            width: 320,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(12),
              child: BlocProvider.value(
                value:
                    context.read<NotificationBloc>()..add(FetchNotifications()),
                child: BlocBuilder<NotificationBloc, NotificationState>(
                  builder: (context, state) {
                    if (state is NotificationLoading) {
                      return const SizedBox(
                        height: 200,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    } else if (state is NotificationLoaded) {
                      if (state.notifications.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('No notifications.'),
                        );
                      }
                      return SizedBox(
                        height: 300,
                        child: ListView.builder(
                          itemCount: state.notifications.length,
                          itemBuilder: (context, index) {
                            final notif = state.notifications[index];
                            return ListTile(
                              leading: Icon(
                                notif.type == 'like'
                                    ? Icons.thumb_up
                                    : Icons.message,
                                color:
                                    notif.isRead ? Colors.grey : Colors.green,
                              ),
                              title: Text(notif.message),
                              subtitle:
                                  notif.data != null
                                      ? Text(notif.data.toString())
                                      : null,
                              trailing:
                                  notif.isRead
                                      ? null
                                      : Icon(
                                        Icons.circle,
                                        color: Colors.green,
                                        size: 12,
                                      ),
                              onTap: () {
                                context.read<NotificationBloc>().add(
                                  MarkNotificationsRead([notif.id]),
                                );
                                _notifOverlay?.remove();
                                _notifOverlay = null;
                              },
                            );
                          },
                        ),
                      );
                    } else if (state is NotificationError) {
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text('Error: [38;5;9m${state.message}[0m'),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
            ),
          ),
    );
    Overlay.of(context).insert(_notifOverlay!);
  }

  void _hideNotificationsDropdown() {
    _notifOverlay?.remove();
    _notifOverlay = null;
  }

  void _loadFeed() {
    context.read<FeedBloc>().add(LoadFeedEvent());
  }

  @override
  void initState() {
    super.initState();
    _loadFeed();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Feed',
          style: TextStyle(
            color: Pallete.blackColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          BlocProvider(
            create:
                (_) =>
                    NotificationBloc(NotificationRepository(baseUrl: baseUrl)),
            child: Builder(
              builder:
                  (context) => IconButton(
                    key: _notifKey,
                    icon: const Icon(
                      Icons.notifications_none,
                      color: Pallete.blackColor,
                    ),
                    onPressed: () {
                      if (_notifOverlay == null) {
                        _showNotificationsDropdown(context);
                      } else {
                        _hideNotificationsDropdown();
                      }
                    },
                  ),
            ),
          ),
          Builder(
            builder: (context) {
              String? profilePicUrl;
              final state = context.watch<ProfileBloc>().state;
              if (state is ProfileLoaded) {
                profilePicUrl = state.profile.profilePicUrl;
              }
              return IconButton(
                icon:
                    (profilePicUrl != null && profilePicUrl.isNotEmpty)
                        ? CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: NetworkImage(profilePicUrl),
                        )
                        : const Icon(Icons.person, color: Pallete.blackColor),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ProfilePage()),
                  );
                },
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SizedBox(
              height: 40,
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  context.read<UserSearchBloc>().add(
                    UserSearchQueryChanged(value),
                  );
                },
                style: const TextStyle(color: Pallete.blackColor),
                decoration: InputDecoration(
                  hintText: 'Search users...',
                  hintStyle: const TextStyle(color: Pallete.blackColor),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Pallete.blackColor,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 12,
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
            ),
          ),
        ),
      ),
      body: BlocBuilder<UserSearchBloc, UserSearchState>(
        builder: (context, state) {
          if (_searchController.text.isNotEmpty) {
            if (state is UserSearchLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is UserSearchLoaded) {
              if (state.results.isEmpty) {
                return const Center(child: Text('No users found.'));
              }
              return ListView.builder(
                itemCount: state.results.length,
                itemBuilder: (context, index) {
                  final user = state.results[index];
                  return ListTile(
                    leading:
                        user.profilePicUrl.isNotEmpty
                            ? CircleAvatar(
                              backgroundImage: NetworkImage(user.profilePicUrl),
                            )
                            : const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(
                      user.username,
                      style: const TextStyle(color: Pallete.blackColor),
                    ),
                    onTap: () {
                      // TODO: Navigate to user profile
                    },
                  );
                },
              );
            } else if (state is UserSearchError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            return const SizedBox();
          }

          return BlocBuilder<FeedBloc, FeedState>(
            builder: (context, state) {
              if (state is FeedLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is FeedLoaded) {
                if (state.posts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'No posts yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: _loadFeed,
                          child: const Text('Refresh'),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => _loadFeed(),
                  child: ListView.builder(
                    itemCount: state.posts.length,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    itemBuilder: (context, index) {
                      return FeedPostWidget(post: state.posts[index]);
                    },
                  ),
                );
              }

              if (state is FeedError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error: ${state.message}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadFeed,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              return const Center(child: CircularProgressIndicator());
            },
          );
        },
      ),
    );
  }
}
