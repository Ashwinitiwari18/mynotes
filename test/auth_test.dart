import 'dart:math';

import 'package:mynotes/services/auth/auth_exception.dart';
import 'package:mynotes/services/auth/auth_provider.dart';
import 'package:mynotes/services/auth/auth_user.dart';
import 'package:test/test.dart';

void main() {
  group('Mock Authentication', () {
    final provider = MockAuthProvider();
    test('Should not be able to initalize to begin with', () {
      expect(provider.isInitialized, false);
    });

    test('Cannot log out if not initalize', () {
      expect(
        provider.logOut(),
        throwsA(const TypeMatcher<NotInitializeException>()),
      );
    });

    test('Should be able to initalize', () async {
      await provider.initializer();
      expect(provider.isInitialized, true);
    });

    test('User should be null after initalization', () {
      expect(provider.currentUser, null);
    });

    test(
      'Should be able to initalize in less than 2 seconds',
      () async {
        await provider.initializer();
        expect(provider.isInitialized, true);
      },
      timeout: const Timeout(Duration(seconds: 2)),
    );

    test('Create user should delegate to logIn function', () async {
      final badEmail = provider.createUser(
        email: 'ayush@gmail.com',
        password: 'anypassword',
      );
      expect(
        badEmail,
        throwsA(const TypeMatcher<UserNotFoundAuthException>()),
      );
      final badpassword = provider.createUser(
        email: 'anyemail@gmail.com',
        password: '123456',
      );
      expect(badpassword,
          throwsA(const TypeMatcher<WrongPasswordAuthException>()));
      final user = provider.createUser(
        email: 'ayush',
        password: 'tiwari',
      );
      expect(provider.currentUser, user);
      // expect(user.isEmailVerified, false);
    });
    test('logged in user should be able to get verified', () {
      provider.sendEmailVerification();
      final user = provider.currentUser;
      expect(user, isNotNull);
      expect(user!.isEmailVerified, true);
    });
    test('Should be able to logout and login again', () async {
      await provider.logOut();
      await provider.logIn(
        email: 'email',
        password: 'password',
      );
      final user = provider.currentUser;
      expect(user, isNotNull);
    });
  });
}

class NotInitializeException {}

class MockAuthProvider implements AuthProvider {
  AuthUser? _user;
  var _isInitialized = false;
  bool get isInitialized => _isInitialized;

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    if (!isInitialized) throw NotInitializeException();
    await Future.delayed(const Duration(seconds: 1));
    return logIn(
      email: email,
      password: password,
    );
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initializer() async {
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized = true;
  }

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) {
    if (!isInitialized) throw NotInitializeException();
    if (email == 'ayush@gmai.com') throw UserNotFoundAuthException();
    if (password == '123456') throw WrongPasswordAuthException();
    const user = AuthUser(
      id: 'my_id',
      isEmailVerified: false,
      email: 'ayush@tiwari.com',
    );
    _user = user;
    return Future(() => user);
  }

  @override
  Future<void> logOut() async {
    if (!isInitialized) throw NotInitializeException();
    if (_user == null) throw UserNotFoundAuthException();
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!isInitialized) throw NotInitializeException();
    final user = _user;
    if (user == null) throw UserNotFoundAuthException();
    final newUser = AuthUser(
      id: 'my_id',
      isEmailVerified: true,
      email: 'ayush@tiwari.com',
    );
    _user = newUser;
  }
}
