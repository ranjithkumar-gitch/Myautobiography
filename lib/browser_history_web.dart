import 'dart:js_interop';

@JS('history')
external _History get _history;

extension type _History(JSObject _) implements JSObject {
  external void back();
  external void replaceState(JSAny? data, String unused, String url);
  external void pushState(JSAny? data, String unused, String url);
}

@JS('location')
external _Location get _location;

extension type _Location(JSObject _) implements JSObject {
  external String get pathname;
  external String get href;
}

@JS('window')
external _Window get _window;

extension type _Window(JSObject _) implements JSObject {
  external void addEventListener(
    String type,
    JSFunction listener,
    bool useCapture,
  );
}

bool _browserBackPending = false;
bool _ignoreNextPop = false;

/// Makes the browser's Back button lead to the onboarding page from anywhere.
/// Call once before runApp.
void setUpBrowserBackToHome() {
  // Opened directly on a deep link (e.g. /register): put the onboarding page
  // underneath it so Back lands there instead of leaving the site.
  if (_location.pathname != '/') {
    final url = _location.href;
    _history.replaceState(null, '', '/');
    _history.pushState(null, '', url);
  }
  // Capture phase so this runs before Flutter's own popstate listener and the
  // flag is set by the time go_router parses the new location.
  _window.addEventListener(
    'popstate',
    ((JSAny? _) {
      if (_ignoreNextPop) {
        _ignoreNextPop = false;
      } else {
        _browserBackPending = true;
      }
    }).toJS,
    true,
  );
}

/// Whether the current navigation came from the browser's Back/Forward
/// buttons. Clears the flag.
bool takeBrowserBack() {
  final pending = _browserBackPending;
  _browserBackPending = false;
  return pending;
}

/// Steps back one entry in the browser history, exactly like the browser's
/// Back button, so the current entry is not left behind in the back stack.
/// Unlike the browser's button, this goes to the previous page rather than
/// to onboarding.
void browserHistoryBack() {
  _ignoreNextPop = true;
  _history.back();
}
