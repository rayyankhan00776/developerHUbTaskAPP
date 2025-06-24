import 'package:equatable/equatable.dart';
import '../repositories/notification_repository.dart';

abstract class NotificationEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchNotifications extends NotificationEvent {}

class MarkNotificationsRead extends NotificationEvent {
  final List<int> ids;
  MarkNotificationsRead(this.ids);
  @override
  List<Object?> get props => [ids];
}

abstract class NotificationState extends Equatable {
  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List<NotificationModel> notifications;
  NotificationLoaded(this.notifications);
  @override
  List<Object?> get props => [notifications];
}

class NotificationError extends NotificationState {
  final String message;
  NotificationError(this.message);
  @override
  List<Object?> get props => [message];
}
