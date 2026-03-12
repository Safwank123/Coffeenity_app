part of 'auth_bloc.dart';

class AuthState extends Equatable {
  const AuthState({this.emitState = AuthEmitState.success});
  final AuthEmitState emitState;

  AuthState copyWith({AuthEmitState? emitState}) => AuthState(emitState: emitState ?? this.emitState);
  
  @override
  List<Object> get props => [emitState];
}

enum AuthEmitState { loading, success, loggedIn, registered, userPreferenceUpdated, updated }
