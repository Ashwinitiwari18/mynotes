import 'package:flutter/foundation.dart' show immutable;

typedef CloseLodingScreen = bool Function();
typedef UpdateLodingScreen = bool Function(String text);

@immutable
class LodingScreenController {
  final CloseLodingScreen close;
  final UpdateLodingScreen update;
  const LodingScreenController({
    required this.close,
    required this.update,
  });
}
