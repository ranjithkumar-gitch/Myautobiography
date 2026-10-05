// Browser history access on web; a no-op on other platforms.
export 'browser_history_stub.dart'
    if (dart.library.js_interop) 'browser_history_web.dart';
