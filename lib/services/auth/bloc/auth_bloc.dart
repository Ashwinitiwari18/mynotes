import 'package:bloc/bloc.dart';
import 'package:mynotes/services/auth/auth_provider.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';
import 'package:mynotes/services/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider)
      : super(const AuthStateUninitialized(isLoading: true)) {
    on<AuthEventShouldRegister>((event, emit) {
      emit(const AuthStateRegistering(
        exception: null,
        isLoading: false,
      ));
    });

    // forget password
    on<AuthEventForgetPassword>(
      (event, emit) async {
        emit(
          const AuthStateForgetPassword(
            exception: null,
            hasSendEmail: false,
            isLoading: false,
          ),
        );
        final email = event.email;
        if (email == null) {
          return; // user only want to go forget password
        }

        // user actualy want to sent forget password email
        emit(
          const AuthStateForgetPassword(
            exception: null,
            hasSendEmail: false,
            isLoading: true,
          ),
        );
        bool didSendEmail;
        Exception? exception;
        try {
          await provider.sendPasswordReset(toEmail: email);
          didSendEmail = true;
          exception = null;
        } on Exception catch (e) {
          didSendEmail = false;
          exception = e;
        }
        emit(
          AuthStateForgetPassword(
            exception: exception,
            hasSendEmail: didSendEmail,
            isLoading: false,
          ),
        );
      },
    );

    // send email verification
    on<AuthEventSendEmailVerification>((event, emit) async {
      await provider.sendEmailVerification();
      emit(state);
    });

    // register
    on<AuthEventRegister>((event, emit) async {
      final String email = event.email;
      final String password = event.password;
      try {
        await provider.createUser(
          email: email,
          password: password,
        );
        provider.sendEmailVerification();
        emit(const AuthStateNeedsVerification(isLoading: false));
      } on Exception catch (e) {
        emit(AuthStateRegistering(
          exception: e,
          isLoading: false,
        ));
      }
    });

    // initialize state
    on<AuthEventInitialize>((event, emit) async {
      await provider.initializer();
      final user = provider.currentUser;
      if (user == null) {
        emit(
          const AuthStateLoggedout(
            exception: null,
            isLoding: false,
            loadingText: 'Plase wait while I log you in.',
          ),
        );
      } else if (!user.isEmailVerified) {
        emit(const AuthStateNeedsVerification(isLoading: false));
      } else {
        emit(AuthStateLoggedIn(
          user: user,
          isLoading: false,
        ));
      }
    });

    // login state
    on<AuthEventLogIn>((event, emit) async {
      emit(
        const AuthStateLoggedout(
          exception: null,
          isLoding: true,
        ),
      );
      final email = event.email;
      final password = event.password;
      try {
        final user = await provider.logIn(
          email: email,
          password: password,
        );
        if (!user.isEmailVerified) {
          emit(
            const AuthStateLoggedout(
              exception: null,
              isLoding: false,
            ),
          );
          emit(const AuthStateNeedsVerification(isLoading: false));
        } else {
          emit(
            const AuthStateLoggedout(
              exception: null,
              isLoding: false,
            ),
          );
          emit(AuthStateLoggedIn(user: user, isLoading: false));
        }
      } on Exception catch (e) {
        emit(
          AuthStateLoggedout(
            exception: e,
            isLoding: false,
          ),
        );
      }
    });

    // logout
    on<AuthEventLogOut>((event, emit) async {
      try {
        await provider.logOut();
        emit(
          const AuthStateLoggedout(
            exception: null,
            isLoding: false,
          ),
        );
      } on Exception catch (e) {
        emit(
          AuthStateLoggedout(
            exception: e,
            isLoding: false,
          ),
        );
      }
    });
  }
}
