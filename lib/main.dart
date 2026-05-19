import 'package:flutter/material.dart';
import 'package:myautobiography/admin/loginPage.dart';
import 'package:myautobiography/admin/dashboard.dart';
import 'package:myautobiography/onboardingscreen.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:myautobiography/request_as_star_screen.dart';

void main() {
  usePathUrlStrategy();
  runApp(const MyApp());
}

bool isAdminLoggedIn = false;
final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    // --- User/Customer Route ---
    GoRoute(path: '/', builder: (context, state) => const OnBoardingscreen()),
    // GoRoute(
    //   path: '/',
    //   builder: (context, state) => const RequestAsStarScreen(),
    // ),

    // --- Admin Route ---
    GoRoute(
      path: '/hvr/admin',
      builder: (context, state) => const AdminLoginPage(),
      redirect: (context, state) {
        if (isAdminLoggedIn) return '/hvr/admin/dashboard';
        return null;
      },
    ),
    GoRoute(
      path: '/hvr/admin/dashboard',
      builder: (context, state) => const DashboardPage(),
      redirect: (context, state) {
        if (!isAdminLoggedIn) return '/hvr/admin';
        return null;
      },
    ),
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
      routerConfig: _router,
    );
  }
}
