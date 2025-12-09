import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sazon_recetas/core/core.dart';
import 'package:sazon_recetas/features/features.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  final AuthTokenStorage _tokenStorage;

  AuthCubit({
    required AuthRepository authRepository,
    required AuthTokenStorage tokenStorage,
  }) : _authRepository = authRepository,
       _tokenStorage = tokenStorage,
       super(const AuthState());

  Future<void> checkSession() async {
    final token = await _tokenStorage.getToken();
    if (token != null && token.isNotEmpty) {
      emit(state.copyWith(status: AuthStatus.authenticated));
    } else {
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> login(String email, String password) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final data = await _authRepository.login(
        email: email,
        password: password,
      );
      final token = data['token'] as String?;
      if (token != null) {
        await _tokenStorage.saveToken(token);
        emit(
          state.copyWith(status: AuthStatus.authenticated, isLoading: false),
        );
      } else {
        emit(state.copyWith(isLoading: false, errorMessage: 'Invalid token'));
      }
    } catch (e) {
      emit(
        state.copyWith(isLoading: false, errorMessage: 'Invalid credentials'),
      );
    }
  }

  Future<void> register(String name, String email, String password) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final data = await _authRepository.register(
        name: name,
        email: email,
        password: password,
      );
      final token = data['token'] as String?;
      if (token != null) {
        await _tokenStorage.saveToken(token);
        emit(
          state.copyWith(status: AuthStatus.authenticated, isLoading: false),
        );
      } else {
        emit(state.copyWith(isLoading: false, errorMessage: 'Invalid token'));
      }
    } catch (e) {
      emit(
        state.copyWith(isLoading: false, errorMessage: 'Registration failed'),
      );
    }
  }

  Future<void> logout() async {
    await _tokenStorage.clearToken();
    emit(state.copyWith(status: AuthStatus.unauthenticated));
  }
}
