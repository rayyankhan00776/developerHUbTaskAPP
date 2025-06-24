import 'package:client/features/auth/repository/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/user_model.dart';

// Events
abstract class AuthEvent {}

class SignupEvent extends AuthEvent {
  final UserModel user;
  SignupEvent(this.user);
}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;
  LoginEvent(this.email, this.password);
}

class ChangePasswordEvent extends AuthEvent {
  final String email;
  final String currentPassword;
  final String newPassword;
  ChangePasswordEvent(this.email, this.currentPassword, this.newPassword);
}

class ForgotPasswordSendCodeEvent extends AuthEvent {
  final String email;
  ForgotPasswordSendCodeEvent(this.email);
}

class ForgotPasswordVerifyCodeEvent extends AuthEvent {
  final String email;
  final String code;
  final String newPassword;
  ForgotPasswordVerifyCodeEvent(this.email, this.code, this.newPassword);
}

// States
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {}

class PasswordChangeSuccess extends AuthState {}

class ForgotPasswordCodeSent extends AuthState {}

class ForgotPasswordSuccess extends AuthState {}

class AuthFailure extends AuthState {
  final String message;
  AuthFailure(this.message);
}

// Bloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;
  AuthBloc(this.repository) : super(AuthInitial()) {
    on<SignupEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        await repository.signup(event.user);
        emit(AuthSuccess());
        emit(AuthInitial()); // Reset state for next actions
      } catch (e) {
        emit(AuthFailure(e.toString()));
        emit(AuthInitial());
      }
    });

    on<LoginEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        await repository.login(event.email, event.password);
        emit(AuthSuccess());
        emit(AuthInitial());
      } catch (e) {
        emit(AuthFailure(e.toString()));
        emit(AuthInitial());
      }
    });

    on<ChangePasswordEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        await repository.changePassword(
          event.email,
          event.currentPassword,
          event.newPassword,
        );
        emit(PasswordChangeSuccess());
        emit(AuthInitial());
      } catch (e) {
        emit(AuthFailure(e.toString()));
        emit(AuthInitial());
      }
    });

    on<ForgotPasswordSendCodeEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        await repository.forgotPasswordSendCode(event.email);
        emit(ForgotPasswordCodeSent());
        emit(AuthInitial());
      } catch (e) {
        emit(AuthFailure(e.toString()));
        emit(AuthInitial());
      }
    });

    on<ForgotPasswordVerifyCodeEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        await repository.forgotPasswordVerifyCode(
          event.email,
          event.code,
          event.newPassword,
        );
        emit(ForgotPasswordSuccess());
        emit(AuthInitial());
      } catch (e) {
        emit(AuthFailure(e.toString()));
        emit(AuthInitial());
      }
    });
  }
}
