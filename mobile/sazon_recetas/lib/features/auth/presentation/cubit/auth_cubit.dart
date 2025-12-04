import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(const AuthState());

  void setAuthenticated() {
    emit(const AuthState(status: AuthStatus.authenticated));
  }

  void setUnauthenticated() {
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  void reset() {
    emit(const AuthState(status: AuthStatus.unknown));
  }
}
