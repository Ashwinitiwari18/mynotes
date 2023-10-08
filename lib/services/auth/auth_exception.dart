
// login exception
class WrongPasswordAuthException implements Exception{}

class UserNotFoundAuthException implements Exception{}

// register exception
class WeakPasswordAuthException implements Exception{}

class EmailAlreadyInUseAuthException implements Exception{}

class InvalideEmailAuthException implements Exception{}

// generic exception
class GenericAuthException implements Exception{}

class UserNotLogInAuthException implements Exception{}