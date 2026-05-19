import 'package:flutter/foundation.dart';

class LandingPageBackHandler {
  void attach(VoidCallback onBackAttempt) {}

  void retainCurrentEntry() {}

  void detach() {}
}

LandingPageBackHandler createLandingPageBackHandler() {
  return LandingPageBackHandler();
}
