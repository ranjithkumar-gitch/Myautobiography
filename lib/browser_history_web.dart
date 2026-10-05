import 'dart:js_interop';

@JS('history')
external _History get _history;

extension type _History(JSObject _) implements JSObject {
  external void back();
}

/// Steps back one entry in the browser history, exactly like the browser's
/// Back button, so the current entry is not left behind in the back stack.
void browserHistoryBack() => _history.back();
