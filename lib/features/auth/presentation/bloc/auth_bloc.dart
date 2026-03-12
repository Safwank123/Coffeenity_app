import 'package:coffeenity/core/utils/api_response_handler.dart';
import 'package:coffeenity/features/auth/data/models/register_request.dart';
import 'package:coffeenity/features/auth/data/models/user_preference_request.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repository/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  AuthBloc(this._authRepository) : super(AuthState()) {
    on<Login>(_onLogin);
    on<Register>(_onRegister);
    on<UserPreferenceUpdate>(_onUserPreferenceUpdate);
  }

  void _onLogin(Login event, Emitter<AuthState> emit) async {
    emit(state.copyWith(emitState: AuthEmitState.loading));
    final login = await _authRepository.login(email: event.email, password: event.password);
    if (login.success) emit(state.copyWith(emitState: AuthEmitState.loggedIn));
    emit(state.copyWith(emitState: AuthEmitState.success));
  }

  void _onRegister(Register event, Emitter<AuthState> emit) async {
    emit(state.copyWith(emitState: AuthEmitState.loading));
    ApiResponse register = ApiResponse();
    if (!event.isEdit) {
      register = await _authRepository.register(registerRequest: event.registerRequest);
    } else {
      register = await _authRepository.updateUser(registerRequest: event.registerRequest);
    }
    if (register.success) {
      final login = await _authRepository.userPreference(userData: event.userPreferenceRequest);
      if (login.success) {
        emit(state.copyWith(emitState: event.isEdit ? AuthEmitState.updated : AuthEmitState.registered));
      }
    }
    emit(state.copyWith(emitState: AuthEmitState.success));
  }

  void _onUserPreferenceUpdate(UserPreferenceUpdate event, Emitter<AuthState> emit) async {
    emit(state.copyWith(emitState: AuthEmitState.loading));
    final login = await _authRepository.userPreference(userData: event.request);
    if (login.success) emit(state.copyWith(emitState: AuthEmitState.userPreferenceUpdated));
    emit(state.copyWith(emitState: AuthEmitState.success));
  }
}
