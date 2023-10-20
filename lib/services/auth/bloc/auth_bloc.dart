import 'package:bloc/bloc.dart';
import 'package:mynotes/services/auth/auth_provider.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';
import 'package:mynotes/services/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider) : super(const AuthStateLoding()) {
    // initialize state
    on<AuthEventInitialize>((event, emit) async {
      await provider.initializer();
      final user = provider.currentUser;
      if (user == null) {
        emit(const AuthStateLoggedout());
      } else if (!user.isEmailVerified) {
        emit(const AuthStateNeedsVerification());
      } else {
        emit(AuthStateLoggedIn(user));
      }
    });

    // login state
    on<AuthEventLogIn>((event, emit) async {
      try {
        emit(const AuthStateLoding());
        final email = event.email;
        final password = event.password;
        final user = await provider.logIn(
          email: email,
          password: password,
        );
        emit(AuthStateLoggedIn(user));
      } on Exception catch (e) {
        emit(AuthStateLoginFailure(e));
      }
    });

    // logout
    on<AuthEventLogOut>((event, emit) async {
      try {
        emit(const AuthStateLoding());
        await provider.logOut();
        emit(const AuthStateLoggedout());
      } on Exception catch (e) {
        emit(AuthStateLogoutFailure(e));
      }
    });
  }
}
