import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/notification_repository.dart';
import 'notification_event_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository repository;
  NotificationBloc(this.repository) : super(NotificationInitial()) {
    on<FetchNotifications>(_onFetch);
    on<MarkNotificationsRead>(_onMarkRead);
  }

  Future<void> _onFetch(
    FetchNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    try {
      final notifications = await repository.fetchNotifications();
      emit(NotificationLoaded(notifications));
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> _onMarkRead(
    MarkNotificationsRead event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await repository.markNotificationsRead(event.ids);
      add(FetchNotifications());
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }
}
