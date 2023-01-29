// Flutter imports:
import 'package:flutter/material.dart';

class AppTheme {
  static Color primaryColor = const Color(0xff4645B1);
  static Color primaryColorLight = const Color(0xff6160B1);

  static MaterialColor primarySwatch = MaterialColor(
    primaryColor.value,
    <int, Color>{
      50: primaryColor.withOpacity(.1),
      100: primaryColor.withOpacity(.2),
      200: primaryColor.withOpacity(.3),
      300: primaryColor.withOpacity(.4),
      400: primaryColor.withOpacity(.5),
      500: primaryColor.withOpacity(.6),
      600: primaryColor.withOpacity(.7),
      700: primaryColor.withOpacity(.8),
      800: primaryColor.withOpacity(.9),
      900: primaryColor.withOpacity(1),
    },
  );

  static Gradient mainGradiantColor = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primaryColor, primaryColorLight],
  );
  static Gradient buttonGradient = LinearGradient(
    colors: [primaryColor, primaryColorLight],
    end: Alignment.centerLeft,
    begin: Alignment.centerRight,
  );
}
