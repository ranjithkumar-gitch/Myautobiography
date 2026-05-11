import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myautobiography/star_app_colors.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);

// Define light theme
final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  scaffoldBackgroundColor: kwhiteColor,
  primaryColor: kgoldColor,
  secondaryHeaderColor: kwhiteColor,
  dividerColor: kgreyColor,
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: kblackColor),
    bodyMedium: TextStyle(color: kblackColor),
    bodySmall: TextStyle(color: kblackColor),
    labelLarge: TextStyle(color: kblackColor),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: kwhiteColor,
    foregroundColor: kwhiteColor,
    shadowColor: Colors.transparent,
  ),
  extensions: <ThemeExtension<dynamic>>[StarAppColors.light],
  // bottomAppBarTheme: const BottomAppBarTheme(
  //   backgroundColor: kLightSurfaceColor,
  //   color: kLightTextColor,
  // ),
);

// Define dark theme
final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: kblackColor,
  primaryColor: kgoldColor,
  secondaryHeaderColor: kgreyColor,
  dividerColor: kgreyColor,
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: kwhiteColor),
    bodyMedium: TextStyle(color: kwhiteColor),
    bodySmall: TextStyle(color: kwhiteColor),
    labelLarge: TextStyle(color: kwhiteColor),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: kblackColor,
    foregroundColor: kblackColor,
  ),
  extensions: <ThemeExtension<dynamic>>[StarAppColors.dark],
  // bottomAppBarTheme: const BottomAppBarTheme(
  //   backgroundColor: kDarkSurfaceColor,
  //   color: kDarkTextColor,
  // ),
);

const kgoldColor = Color(0xFFc09d41);
const ksilverColor = Colors.grey;
const kbronzeColor = CupertinoColors.systemBrown;

const kwhiteColor = Color(0xFFFFFFFF);
const kwhiteopacityColor = Color(0x3DFFFFFF);

const kgreyColor = Color(0xFF9AA9BA);
const korangeBordercolor = Color(0xFFFF892F);
const kblackColor = Color(0xFF000000);
const kfillgreyColor = Color(0xFF1A1A1A);
const kdarkgreyColor = Color(0xFF333333);
