/// Makes the browser's Back button lead to onboarding. No-op outside the web.
void setUpBrowserBackToHome() {}

/// Whether the current navigation came from the browser's Back button.
/// Always false outside the web.
bool takeBrowserBack() => false;

/// Steps back one entry in the browser history. No-op outside the web.
void browserHistoryBack() {}
