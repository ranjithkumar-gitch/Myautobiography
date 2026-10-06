import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:myautobiography/browser_history.dart';
import 'package:myautobiography/onboardingscreen.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:myautobiography/register_screen.dart';
import 'package:myautobiography/success_screen2.dart';
import 'package:myautobiography/terms_conditions_screen.dart';
import 'package:myautobiography/terms_service.dart';

void main() {
  usePathUrlStrategy();
  // Make context.push() update the browser address bar (e.g. /terms-conditions).
  GoRouter.optionURLReflectsImperativeAPIs = true;
  setUpBrowserBackToHome();
  runApp(const MyApp());
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  // The browser's Back button always returns to onboarding.
  redirect: (context, state) =>
      takeBrowserBack() && state.uri.path != '/' ? '/' : null,
  routes: [
    // --- User/Customer Route ---
    GoRoute(path: '/', builder: (context, state) => const OnBoardingscreen()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/success',
      // Only reachable right after registering; a refresh has no names.
      redirect: (context, state) => state.extra is Map ? null : '/',
      builder: (context, state) {
        final names = state.extra as Map;
        return SuccessScreen2(
          firstName: names['firstName'] as String?,
          lastName: names['lastName'] as String?,
        );
      },
    ),
    GoRoute(
      path: '/terms-conditions',
      builder: (context, state) => const TermsConditionsScreen(),
    ),
    GoRoute(
      path: '/privacy-policy',
      builder: (context, state) =>
          const TermsConditionsScreen(
            title: 'Privacy Policy',
            fetch: TermsService.fetchPrivacyPolicy,
          ),
    ),
    // GoRoute(
    //   path: '/',
    //   builder: (context, state) => const RequestAsStarScreen(),
    // ),
  ],
  // Error page for 404s
  errorBuilder: (context, state) =>
      const Scaffold(body: Center(child: Text('Page not found!'))),
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      // Without this the country picker shows native names ("भारत"), so
      // searching "India" finds nothing.
      localizationsDelegates: const [
        CountryLocalizations.delegate,
        DefaultMaterialLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
      routerConfig: _router,
    );
  }
}
