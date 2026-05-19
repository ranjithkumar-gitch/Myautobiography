import 'dart:async';
import 'dart:html' as html;

import 'package:flutter/foundation.dart';

class LandingPageBackHandler {
  StreamSubscription<html.PopStateEvent>? _subscription;

  void attach(VoidCallback onBackAttempt) {
    retainCurrentEntry();
    _subscription ??= html.window.onPopState.listen((_) {
      onBackAttempt();
    });
  }

  void retainCurrentEntry() {
    html.window.history.pushState(null, '', html.window.location.href);
  }

  void detach() {
    _subscription?.cancel();
    _subscription = null;
  }
}

LandingPageBackHandler createLandingPageBackHandler() {
  return LandingPageBackHandler();
}
